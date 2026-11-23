import 'dart:async';

import 'package:lengoal/core/core.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_access.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_class_cubit.dart';
import 'package:lengoal/features/classes/presentation/bloc/live_class/live_room_controller.dart';
import 'package:lengoal/features/classes/presentation/models/live_class_session.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_reaction_picker.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_room_controls.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_room_moments_layer.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_room_participant_view.dart';
import 'package:lengoal/features/classes/presentation/widgets/live_class/live_room_top_bar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LiveClassRoom extends StatefulWidget {
  const new({
    required this.session,
    required this.access,
    required this.joinWithMic,
    required this.joinWithCamera,
    super.key,
  });

  final LiveClassSession session;
  final LiveClassAccess access;
  final bool joinWithMic;
  final bool joinWithCamera;

  @override
  State<LiveClassRoom> createState() => _LiveClassRoomState();
}

class _LiveClassRoomState extends State<LiveClassRoom> {
  late final LiveRoomController _controller;
  bool _handledClose = false;

  @override
  void initState() {
    super.initState();
    _controller = LiveRoomController(
      access: widget.access,
      joinWithMic: widget.joinWithMic,
      joinWithCamera: widget.joinWithCamera,
      educatorId: widget.session.educatorId,
    )..addListener(_onControllerChanged);
    unawaited(WakelockPlus.enable());
    unawaited(_controller.connect());
  }

  void _onControllerChanged() {
    if (_handledClose) return;
    if (_controller.connection != LiveRoomConnection.closed) return;
    _handledClose = true;
    if (!mounted) return;
    final cubit = context.read<LiveClassCubit>();
    switch (_controller.closeKind) {
      case LiveRoomCloseKind.left:
        context.pop();
      case LiveRoomCloseKind.classEnded:
        cubit.roomClosed(classEnded: true);
      case LiveRoomCloseKind.failed:
        cubit.roomFailed(context.l10n.liveClassConnectFailed);
      case LiveRoomCloseKind.dropped:
      case null:
        cubit.roomClosed(classEnded: false);
    }
  }

  Future<void> _confirmLeave() async {
    AppHaptics.selection();
    final l10n = context.l10n;
    final leave = await AppConfirmDialog.show(
      context,
      title: l10n.liveClassLeaveTitle,
      body: l10n.liveClassLeaveBody,
      cancelLabel: l10n.liveClassStay,
      confirmLabel: l10n.liveClassLeave,
      confirmColor: AppColors.errorRed,
    );
    if (leave ?? false) await _controller.leave();
  }

  Future<void> _toggleMic() async {
    final ok = await _controller.setMicrophone(enabled: !_controller.isMicOn);
    if (!ok && mounted) AppSnackbar.error(context.l10n.liveClassMicBlocked);
  }

  Future<void> _toggleCamera() async {
    final ok = await _controller.setCamera(enabled: !_controller.isCameraOn);
    if (!ok && mounted) AppSnackbar.error(context.l10n.liveClassCameraBlocked);
  }

  Future<void> _pickReaction() async {
    final reaction = await LiveReactionPicker.show(context);
    if (reaction == null || !mounted) return;
    await _controller.react(reaction);
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([_controller, _controller.room]),
            builder: (context, _) {
              final controller = _controller;
              return Column(
                children: [
                  LiveRoomTopBar(
                    topic: widget.session.topic,
                    isRecording: controller.isRecording,
                    participantCount: controller.participantCount,
                    onLeave: _confirmLeave,
                  ),
                  if (controller.connection == LiveRoomConnection.reconnecting)
                    const _ReconnectingBanner(),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ListenableBuilder(
                            listenable: Listenable.merge(
                              controller.participants,
                            ),
                            builder: (context, _) =>
                                _Stage(controller: controller),
                          ),
                        ),
                        Positioned.fill(
                          child: LiveRoomMomentsLayer(
                            moments: controller.moments,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.connection != LiveRoomConnection.connecting &&
                      (controller.canPublish || controller.canSignal))
                    LiveRoomControls(
                      showDevices: controller.canPublish,
                      showSignals: controller.canSignal,
                      micOn: controller.isMicOn,
                      cameraOn: controller.isCameraOn,
                      handRaised: controller.isMyHandRaised,
                      busy: controller.busy,
                      onMic: _toggleMic,
                      onCamera: _toggleCamera,
                      onFlipCamera: () => unawaited(controller.flipCamera()),
                      onHand: () => unawaited(controller.toggleHand()),
                      onReact: () => unawaited(_pickReaction()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const new({required this.controller});

  final LiveRoomController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.connection == LiveRoomConnection.connecting) {
      return _Waiting(
        message: context.l10n.liveClassConnecting,
        showSpinner: true,
      );
    }
    final stage = controller.stage;
    final filmstrip = controller.filmstrip(stage);
    final main = stage == null
        ? _Waiting(message: context.l10n.liveClassWaitingForEducator)
        : LiveRoomParticipantView(
            tile: stage,
            isLocal: false,
            isEducator: controller.isEducator(stage.participant),
            handRaised: controller.isHandRaised(stage.participant),
            large: true,
          );
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final strip = _Filmstrip(
      tiles: filmstrip,
      controller: controller,
      axis: landscape ? Axis.vertical : Axis.horizontal,
    );
    const pad = EdgeInsets.all(AppSpacing.s8);
    if (filmstrip.isEmpty) return Padding(padding: pad, child: main);
    if (landscape) {
      return Padding(
        padding: pad,
        child: Row(
          children: [
            Expanded(child: main),
            const Gap(AppSpacing.s8),
            SizedBox(width: 168, child: strip),
          ],
        ),
      );
    }
    return Padding(
      padding: pad,
      child: Column(
        children: [
          Expanded(child: main),
          const Gap(AppSpacing.s8),
          SizedBox(height: 112, child: strip),
        ],
      ),
    );
  }
}

class _Filmstrip extends StatelessWidget {
  const new({
    required this.tiles,
    required this.controller,
    required this.axis,
  });

  final List<LiveRoomTile> tiles;
  final LiveRoomController controller;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final local = controller.room.localParticipant;
    return ListView.separated(
      scrollDirection: axis,
      itemCount: tiles.length,
      separatorBuilder: (context, index) => const Gap(AppSpacing.s8),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        final view = LiveRoomParticipantView(
          tile: tile,
          isLocal: identical(tile.participant, local),
          isEducator: controller.isEducator(tile.participant),
          handRaised: controller.isHandRaised(tile.participant),
        );
        return axis == Axis.horizontal
            ? SizedBox(width: 150, child: view)
            : SizedBox(height: 112, child: view);
      },
    );
  }
}

class _Waiting extends StatelessWidget {
  const new({required this.message, this.showSpinner = false});

  final String message;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner)
              const SizedBox.square(
                dimension: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.person, size: 96, color: Colors.white24),
            const Gap(AppSpacing.s16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconnectingBanner extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF59E0B),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black87,
              ),
            ),
            const Gap(AppSpacing.s8),
            Expanded(
              child: Text(
                context.l10n.liveClassReconnecting,
                style: context.textTheme.labelMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
