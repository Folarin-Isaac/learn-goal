import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lengoal/core/utils/logger.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_access.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_chat.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_people.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_signals.dart';
import 'package:livekit_client/livekit_client.dart';

enum LiveRoomConnection { connecting, connected, reconnecting, closed }

enum LiveRoomCloseKind { left, classEnded, dropped, failed, replaced, removed }

// A participant as the room UI draws it: their camera or shared screen,
// or null to fall back to an avatar.
class LiveRoomTile {
  const new({
    required this.participant,
    required this.track,
    this.isScreenShare = false,
  });

  final Participant participant;
  final VideoTrack? track;
  final bool isScreenShare;
}

// Owns the LiveKit Room for one visit to a live class: connects with the
// token from ClassRoom/join, applies the lobby's mic/camera choice, and
// turns room events into a connection state the page can draw. Room and
// its participants are ChangeNotifiers too, so the UI listens to them for
// membership and track changes.
class LiveRoomController extends ChangeNotifier {
  new({
    required this.access,
    required this.joinWithMic,
    required this.joinWithCamera,
    this.educatorId,
    Room? room,
  }) : room =
           room ??
           Room(
             roomOptions: const RoomOptions(
               adaptiveStream: true,
               dynacast: true,
               defaultAudioOutputOptions: AudioOutputOptions(speakerOn: true),
             ),
           );

  final LiveClassAccess access;
  final bool joinWithMic;
  final bool joinWithCamera;
  final String? educatorId;
  final Room room;

  late final EventsListener<RoomEvent> _events = room.createListener();

  LiveRoomConnection _connection = LiveRoomConnection.connecting;
  LiveRoomConnection get connection => _connection;

  LiveRoomCloseKind? _closeKind;
  LiveRoomCloseKind? get closeKind => _closeKind;

  String? _failure;
  String? get failure => _failure;

  bool _busy = false;
  bool get busy => _busy;

  CameraPosition _cameraPosition = CameraPosition.front;
  bool _disposed = false;

  // Raised hands by participant identity, with the time they went up. Kept
  // in sync with the web through LiveSignal messages.
  final Map<String, int> _raisedHands = {};

  final StreamController<LiveRoomMoment> _moments =
      StreamController<LiveRoomMoment>.broadcast();

  // Floating reactions and "raised their hand" toasts for the room to show.
  Stream<LiveRoomMoment> get moments => _moments.stream;

  bool get isRecording => room.isRecording;

  // Learners may be listen-only; the server decides through the token.
  bool get canPublish => room.localParticipant?.permissions.canPublish ?? false;

  // Hands and reactions are data messages, a separate permission from
  // publishing audio/video.
  bool get canSignal =>
      room.localParticipant?.permissions.canPublishData ?? false;

  bool get isMyHandRaised {
    final identity = room.localParticipant?.identity;
    return identity != null && _raisedHands.containsKey(identity);
  }

  bool isHandRaised(Participant participant) =>
      _raisedHands.containsKey(participant.identity);

  int get raisedHandCount => _raisedHands.length;

  static const int _maxChatMessages = 500;

  final List<LiveChatMessage> _chat = [];
  bool _chatOpen = false;
  int _unreadChat = 0;

  List<LiveChatMessage> get chatMessages => List.unmodifiable(_chat);

  // Messages from others that arrived while the chat panel was closed.
  // Cleared when the panel opens, like the web's Chat button badge.
  int get unreadChatCount => _unreadChat;

  // Closing never changes anything on screen, so it doesn't notify; that
  // keeps it safe to call from a widget's dispose.
  void setChatOpen({required bool open}) {
    _chatOpen = open;
    if (open && _unreadChat != 0) {
      _unreadChat = 0;
      _notify();
    }
  }

  Future<bool> sendChat(String text) async {
    final message = text.trim();
    final local = room.localParticipant;
    if (message.isEmpty || local == null || !canSignal) return false;
    final payload = LiveChatPayload(
      id: newChatId(),
      message: message,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      await local.publishData(
        payload.encode(),
        reliable: true,
        topic: LiveChatPayload.topic,
      );
    } on Object catch (e) {
      AppLogger.e('[live] chat send failed: $e');
      return false;
    }
    _addChat(
      LiveChatMessage(
        id: payload.id,
        message: payload.message,
        timestamp: payload.timestamp,
        fromIdentity: local.identity,
        fromName: _myName,
        isLocal: true,
      ),
    );
    return true;
  }

  void _onChatData(DataReceivedEvent event, {required bool isUpdate}) {
    final payload = LiveChatPayload.decode(event.data);
    if (payload == null) return;
    final identity = event.participant?.identity ?? event.participantIdentity;
    final existing = _chat.indexWhere(
      (m) => m.id == payload.id && m.fromIdentity == identity,
    );
    if (existing >= 0) {
      final old = _chat[existing];
      _chat[existing] = LiveChatMessage(
        id: old.id,
        message: payload.message,
        timestamp: old.timestamp,
        fromIdentity: old.fromIdentity,
        fromName: old.fromName,
        isLocal: old.isLocal,
        isEdited: isUpdate || old.isEdited,
      );
      _notify();
      return;
    }
    final name = event.participant?.name.trim() ?? '';
    if (!_chatOpen) _unreadChat++;
    _addChat(
      LiveChatMessage(
        id: payload.id,
        message: payload.message,
        timestamp: payload.timestamp,
        fromIdentity: identity,
        fromName: name.isNotEmpty ? name : identity,
        isLocal: false,
        isEdited: isUpdate,
      ),
    );
  }

  void _addChat(LiveChatMessage message) {
    _chat.add(message);
    if (_chat.length > _maxChatMessages) _chat.removeAt(0);
    _notify();
  }

  // Everyone in the room for the People list, in the web's order.
  List<LivePerson> get people {
    final local = room.localParticipant;
    return sortPeople([
      for (final participant in participants)
        LivePerson.from(
          participant,
          isLocal: identical(participant, local),
          isHost: _isEducator(participant),
          isHandRaised: isHandRaised(participant),
        ),
    ]);
  }

  String get _myName {
    final local = room.localParticipant;
    if (local == null) return '';
    return local.name.trim().isNotEmpty ? local.name : local.identity;
  }

  bool get isMicOn => room.localParticipant?.isMicrophoneEnabled() ?? false;

  bool get isCameraOn => room.localParticipant?.isCameraEnabled() ?? false;

  int get participantCount =>
      room.remoteParticipants.length + (room.localParticipant == null ? 0 : 1);

  List<Participant> get participants => [
    ...room.remoteParticipants.values,
    ?room.localParticipant,
  ];

  Future<void> connect() async {
    _events
      ..on<RoomReconnectingEvent>(
        (_) => _setConnection(LiveRoomConnection.reconnecting),
      )
      ..on<RoomReconnectedEvent>((_) {
        _setConnection(LiveRoomConnection.connected);
        // Hands raised or lowered while we were away weren't received;
        // ask again, as on joining.
        if (canSignal) unawaited(_send(const HandStateQuerySignal()));
      })
      ..on<RoomDisconnectedEvent>(_onDisconnected)
      ..on<RoomRecordingStatusChanged>((_) => _notify())
      ..on<TrackSubscribedEvent>((_) => _notify())
      ..on<TrackUnsubscribedEvent>((_) => _notify())
      ..on<TrackMutedEvent>((_) => _notify())
      ..on<TrackUnmutedEvent>((_) => _notify())
      ..on<LocalTrackPublishedEvent>((_) => _notify())
      ..on<LocalTrackUnpublishedEvent>((_) => _notify())
      ..on<ParticipantPermissionsUpdatedEvent>((_) => _notify())
      ..on<DataReceivedEvent>(_onData)
      ..on<ParticipantDisconnectedEvent>((event) {
        if (_raisedHands.remove(event.participant.identity) != null) {
          _notify();
        }
      });
    try {
      await room.connect(access.serverUrl, access.token);
    } on Object catch (e) {
      AppLogger.e('[live] connect failed: $e');
      _failure = e.toString();
      _closeKind = LiveRoomCloseKind.failed;
      _setConnection(LiveRoomConnection.closed);
      return;
    }
    AppLogger.d(
      '[live] connected: room=${room.name} '
      'canPublish=$canPublish remotes=${room.remoteParticipants.length}',
    );
    _setConnection(LiveRoomConnection.connected);
    if (canSignal) unawaited(_send(const HandStateQuerySignal()));
    if (!canPublish) return;
    if (joinWithMic) await setMicrophone(enabled: true);
    if (joinWithCamera) await setCamera(enabled: true);
  }

  void _onDisconnected(RoomDisconnectedEvent event) {
    AppLogger.d('[live] disconnected: ${event.reason}');
    _closeKind ??= switch (event.reason) {
      DisconnectReason.clientInitiated => LiveRoomCloseKind.left,
      DisconnectReason.roomDeleted ||
      DisconnectReason.roomClosed => LiveRoomCloseKind.classEnded,
      // Same account joined the class elsewhere (e.g. the web).
      DisconnectReason.duplicateIdentity => LiveRoomCloseKind.replaced,
      // The educator removed this learner from the session.
      DisconnectReason.participantRemoved => LiveRoomCloseKind.removed,
      _ => LiveRoomCloseKind.dropped,
    };
    _setConnection(LiveRoomConnection.closed);
  }

  // Returns false when the device refused (usually a denied permission).
  Future<bool> setMicrophone({required bool enabled}) {
    return _run(() async {
      await room.localParticipant?.setMicrophoneEnabled(enabled);
    });
  }

  Future<bool> setCamera({required bool enabled}) {
    return _run(() async {
      await room.localParticipant?.setCameraEnabled(
        enabled,
        cameraCaptureOptions: CameraCaptureOptions(
          cameraPosition: _cameraPosition,
        ),
      );
    });
  }

  Future<bool> flipCamera() {
    return _run(() async {
      final track = _localCamera;
      if (track == null) return;
      final next = _cameraPosition.switched();
      await track.setCameraPosition(next);
      _cameraPosition = next;
    });
  }

  Future<void> toggleHand() async {
    final identity = room.localParticipant?.identity;
    if (identity == null) return;
    final raise = !isMyHandRaised;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (raise) {
      _raisedHands[identity] = now;
    } else {
      _raisedHands.remove(identity);
    }
    _notify();
    await _send(
      RaiseHandSignal(
        identity: identity,
        name: _myName,
        isRaised: raise,
        timestamp: now,
      ),
    );
  }

  Future<void> react(LiveReaction reaction) async {
    final name = _myName;
    _emit(ReactionMoment(emoji: reaction.emoji, name: name));
    await _send(
      ReactionSignal(
        reactionId: reaction.id,
        emoji: reaction.emoji,
        participantName: name,
      ),
    );
  }

  void _onData(DataReceivedEvent event) {
    switch (event.topic) {
      case LiveChatPayload.topic:
        _onChatData(event, isUpdate: false);
        return;
      case LiveChatPayload.updateTopic:
        _onChatData(event, isUpdate: true);
        return;
    }
    final signal = LiveSignal.decode(event.data);
    if (signal == null) return;
    final me = room.localParticipant?.identity;
    switch (signal) {
      case RaiseHandSignal(
        :final identity,
        :final isRaised,
        :final timestamp,
        :final name,
      ):
        if (isRaised) {
          final isNew = !_raisedHands.containsKey(identity);
          _raisedHands[identity] = timestamp;
          if (isNew && identity != me) {
            _emit(HandRaisedMoment(_nameFor(identity, name)));
          }
        } else {
          _raisedHands.remove(identity);
        }
      case LowerHandSignal(:final targetIdentity):
        final removed = _raisedHands.remove(targetIdentity) != null;
        if (removed && targetIdentity == me) {
          _emit(const HandLoweredMoment());
        }
      case LowerAllHandsSignal():
        final mine = me != null && _raisedHands.containsKey(me);
        _raisedHands.clear();
        if (mine) _emit(const HandLoweredMoment());
      case HandStateQuerySignal():
        final raisedAt = me == null ? null : _raisedHands[me];
        if (me != null && raisedAt != null) {
          unawaited(
            _send(
              RaiseHandSignal(
                identity: me,
                name: _myName,
                isRaised: true,
                timestamp: raisedAt,
              ),
            ),
          );
        }
        return;
      case ReactionSignal(:final emoji, :final participantName):
        final name = participantName.isNotEmpty
            ? participantName
            : _nameFor(event.participantIdentity, '');
        _emit(ReactionMoment(emoji: emoji, name: name));
        return;
    }
    _notify();
  }

  String _nameFor(String identity, String fallback) {
    if (fallback.trim().isNotEmpty) return fallback;
    final participant = room.remoteParticipants.values
        .where((p) => p.identity == identity)
        .firstOrNull;
    final name = participant?.name.trim() ?? '';
    return name.isNotEmpty ? name : identity;
  }

  Future<void> _send(LiveSignal signal) async {
    final local = room.localParticipant;
    if (local == null || !canSignal) return;
    try {
      await local.publishData(signal.encode(), reliable: true);
    } on Object catch (e) {
      AppLogger.e('[live] publishData failed: $e');
    }
  }

  void _emit(LiveRoomMoment moment) {
    if (!_disposed && !_moments.isClosed) _moments.add(moment);
  }

  Future<void> leave() async {
    _closeKind = LiveRoomCloseKind.left;
    await room.disconnect();
    _setConnection(LiveRoomConnection.closed);
  }

  // What fills the main area, in order: a shared screen (the educator's
  // slides), the educator, whoever is talking, then anyone else. The
  // educator is matched by identity, which LiveKit sets to the user id the
  // web sends with join; if that guess is wrong the later rules still pick
  // a sensible tile.
  LiveRoomTile? get stage {
    final remotes = room.remoteParticipants.values.toList();
    for (final participant in _educatorFirst(remotes)) {
      final screen = _video(participant, screenShare: true);
      if (screen != null) {
        return LiveRoomTile(
          participant: participant,
          track: screen,
          isScreenShare: true,
        );
      }
    }
    final educator = remotes.where(_isEducator).firstOrNull;
    final speaker = room.activeSpeakers
        .whereType<RemoteParticipant>()
        .firstOrNull;
    final withCamera = remotes
        .where((p) => _video(p, screenShare: false) != null)
        .firstOrNull;
    final pick = educator ?? speaker ?? withCamera ?? remotes.firstOrNull;
    if (pick == null) return null;
    return LiveRoomTile(
      participant: pick,
      track: _video(pick, screenShare: false),
    );
  }

  // Everyone not on the stage, the learner last. When a screen is on the
  // stage its presenter still gets a camera tile.
  List<LiveRoomTile> filmstrip(LiveRoomTile? stage) {
    return [
      for (final participant in participants)
        if (stage == null ||
            stage.isScreenShare ||
            participant.identity != stage.participant.identity)
          LiveRoomTile(
            participant: participant,
            track: _video(participant, screenShare: false),
          ),
    ];
  }

  bool isEducator(Participant participant) => _isEducator(participant);

  bool _isEducator(Participant participant) {
    final id = educatorId;
    return id != null &&
        id.isNotEmpty &&
        participant.identity.toLowerCase() == id.toLowerCase();
  }

  Iterable<RemoteParticipant> _educatorFirst(List<RemoteParticipant> remotes) =>
      [...remotes.where(_isEducator), ...remotes.where((p) => !_isEducator(p))];

  static VideoTrack? _video(
    Participant participant, {
    required bool screenShare,
  }) {
    for (final publication in participant.videoTrackPublications) {
      if (publication.isScreenShare != screenShare) continue;
      if (publication.muted) continue;
      final track = publication.track;
      if (track is VideoTrack) return track;
    }
    return null;
  }

  LocalVideoTrack? get _localCamera {
    final publications = room.localParticipant?.videoTrackPublications ?? [];
    for (final publication in publications) {
      if (publication.source != TrackSource.camera) continue;
      final track = publication.track;
      if (track is LocalVideoTrack) return track;
    }
    return null;
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_busy) return true;
    _busy = true;
    _notify();
    try {
      await action();
      return true;
    } on Object catch (e) {
      AppLogger.e('[live] device action failed: $e');
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  void _setConnection(LiveRoomConnection value) {
    if (_connection == value) return;
    _connection = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_moments.close());
    unawaited(_events.dispose());
    unawaited(_shutdown());
    super.dispose();
  }

  Future<void> _shutdown() async {
    if (room.connectionState != ConnectionState.disconnected) {
      await room.disconnect();
    }
    await room.dispose();
  }
}
