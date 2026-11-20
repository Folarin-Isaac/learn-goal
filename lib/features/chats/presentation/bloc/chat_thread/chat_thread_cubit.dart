import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/domain/usecases/chat_usecases.dart';

part 'chat_thread_state.dart';

// One class's group chat. There is no realtime channel (the web shows no
// socket either), so while the chat is on screen the newest page is
// refetched every [pollEvery] and merged in: new messages appear, edits
// update, and messages someone deleted disappear.
class ChatThreadCubit extends Cubit<ChatThreadState> {
  new({
    required this.classId,
    required this._getMessages,
    required this._sendMessage,
    required this._editMessage,
    required this._deleteMessage,
    required this._getIdentity,
    this.pollEvery = const Duration(seconds: 5),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now,
       super(const ChatThreadState());

  final String classId;
  final Duration pollEvery;
  final GetChatMessagesUseCase _getMessages;
  final SendChatMessageUseCase _sendMessage;
  final EditChatMessageUseCase _editMessage;
  final DeleteChatMessageUseCase _deleteMessage;
  final GetChatIdentityUseCase _getIdentity;
  final DateTime Function() _now;

  static const int _pageSize = GetChatMessagesUseCase.pageSize;

  Timer? _timer;
  bool _polling = false;

  // Edits and deletes in flight: a poll answered mid-way could carry the
  // old text or the deleted message, so polls wait them out.
  int _mutations = 0;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: ChatThreadStatus.loading,
        errorMessage: () => null,
      ),
    );
    final identity = await _getIdentity();
    final result = await _getMessages(classId);
    if (isClosed) return;
    result.match(
      (failure) => emit(
        state.copyWith(
          status: ChatThreadStatus.failure,
          identity: identity,
          errorMessage: () => failure.message,
        ),
      ),
      (messages) {
        emit(
          state.copyWith(
            status: ChatThreadStatus.loaded,
            identity: identity,
            messages: messages,
            hasOlder: messages.length >= _pageSize,
          ),
        );
        resumePolling();
      },
    );
  }

  void resumePolling() {
    if (_timer != null || state.status != ChatThreadStatus.loaded) return;
    _timer = Timer.periodic(pollEvery, (_) => unawaited(refresh()));
  }

  void pausePolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() async {
    if (_polling || _mutations > 0 || state.status != ChatThreadStatus.loaded) {
      return;
    }
    _polling = true;
    final result = await _getMessages(classId);
    _polling = false;
    if (isClosed || _mutations > 0) return;
    final fresh = result.getRight().toNullable();
    if (fresh != null) emit(_merge(fresh));
  }

  // The fresh page is the newest [_pageSize] messages. Anything known that
  // falls inside the window it covers but is missing from it was deleted.
  ChatThreadState _merge(List<ChatMessage> fresh) {
    final freshIds = {for (final m in fresh) m.id};
    final windowStart = fresh.length < _pageSize || fresh.isEmpty
        ? null
        : fresh.first.createdOn;
    final kept = state.messages.where((m) {
      if (freshIds.contains(m.id)) return false;
      if (windowStart == null) return false;
      return m.createdOn.isBefore(windowStart);
    });
    final merged = [...kept, ...fresh]
      ..sort((a, b) => a.createdOn.compareTo(b.createdOn));
    final confirmed = {for (final m in fresh) m.clientMessageId};
    final pending = state.pending
        .where((p) => p.failed || !confirmed.contains(p.clientMessageId))
        .toList();
    final editing = state.editing;
    final stillThere = editing == null || merged.any((m) => m.id == editing.id);
    return state.copyWith(
      messages: merged,
      pending: pending,
      editing: stillThere ? null : () => null,
    );
  }

  Future<void> loadOlder() async {
    final oldest = state.messages.isEmpty ? null : state.messages.first;
    if (oldest == null || !state.hasOlder || state.isLoadingOlder) return;
    emit(state.copyWith(isLoadingOlder: true, loadOlderFailed: false));
    final result = await _getMessages(classId, before: oldest.createdOn);
    if (isClosed) return;
    result.match(
      (_) => emit(state.copyWith(isLoadingOlder: false, loadOlderFailed: true)),
      (older) {
        final known = {for (final m in state.messages) m.id};
        emit(
          state.copyWith(
            isLoadingOlder: false,
            hasOlder: older.length >= _pageSize,
            messages: [
              ...older.where((m) => !known.contains(m.id)),
              ...state.messages,
            ],
          ),
        );
      },
    );
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final message = PendingChatMessage(
      clientMessageId: _newClientMessageId(),
      text: trimmed,
      createdOn: _now().toUtc(),
    );
    emit(state.copyWith(pending: [...state.pending, message]));
    await _deliver(message);
  }

  Future<void> retry(String clientMessageId) async {
    final message = _pendingById(clientMessageId);
    if (message == null || !message.failed) return;
    final again = message.asFailed(failed: false);
    _replacePending(again);
    await _deliver(again);
  }

  void discard(String clientMessageId) {
    emit(
      state.copyWith(
        pending: state.pending
            .where((p) => p.clientMessageId != clientMessageId)
            .toList(),
      ),
    );
  }

  Future<void> _deliver(PendingChatMessage message) async {
    final result = await _sendMessage(
      classId: classId,
      clientMessageId: message.clientMessageId,
      text: message.text,
    );
    if (isClosed) return;
    result.match((_) => _replacePending(message.asFailed(failed: true)), (
      sent,
    ) {
      final known = state.messages.any((m) => m.id == sent.id);
      emit(
        state.copyWith(
          pending: state.pending
              .where((p) => p.clientMessageId != message.clientMessageId)
              .toList(),
          messages: known ? null : [...state.messages, sent],
        ),
      );
    });
  }

  PendingChatMessage? _pendingById(String clientMessageId) {
    for (final p in state.pending) {
      if (p.clientMessageId == clientMessageId) return p;
    }
    return null;
  }

  void _replacePending(PendingChatMessage message) {
    emit(
      state.copyWith(
        pending: state.pending
            .map(
              (p) => p.clientMessageId == message.clientMessageId ? message : p,
            )
            .toList(),
      ),
    );
  }

  void startEditing(ChatMessage message) {
    if (!state.identity.owns(message)) return;
    emit(state.copyWith(editing: () => message));
  }

  void cancelEditing() => emit(state.copyWith(editing: () => null));

  // Returns whether the edit was saved, so the composer knows to clear.
  Future<bool> saveEdit(String text) async {
    final editing = state.editing;
    final trimmed = text.trim();
    if (editing == null || trimmed.isEmpty || state.isSavingEdit) return false;
    if (trimmed == editing.text) {
      cancelEditing();
      return true;
    }
    _mutations++;
    emit(state.copyWith(isSavingEdit: true));
    final result = await _editMessage(
      classId: classId,
      messageId: editing.id,
      newText: trimmed,
    );
    _mutations--;
    if (isClosed) return false;
    return result.match<bool>(
      (failure) {
        emit(
          state
              .copyWith(isSavingEdit: false)
              .withEffect(ChatThreadEffect.error(failure.message)),
        );
        return false;
      },
      (saved) {
        emit(
          state.copyWith(
            isSavingEdit: false,
            editing: () => null,
            editedIds: {...state.editedIds, editing.id},
            messages: state.messages
                .map((m) => m.id == editing.id ? m.withText(saved) : m)
                .toList(),
          ),
        );
        return true;
      },
    );
  }

  Future<void> delete(ChatMessage message) async {
    if (!state.identity.owns(message) || state.deletingId != null) return;
    _mutations++;
    emit(state.copyWith(deletingId: () => message.id));
    final result = await _deleteMessage(
      classId: classId,
      messageId: message.id,
    );
    _mutations--;
    if (isClosed) return;
    result.match(
      (failure) => emit(
        state
            .copyWith(deletingId: () => null)
            .withEffect(ChatThreadEffect.error(failure.message)),
      ),
      (_) => emit(
        state
            .copyWith(
              deletingId: () => null,
              editing: state.editing?.id == message.id ? () => null : null,
              messages: state.messages
                  .where((m) => m.id != message.id)
                  .toList(),
            )
            .withEffect(const ChatThreadEffect.deleted()),
      ),
    );
  }

  @override
  Future<void> close() {
    pausePolling();
    return super.close();
  }

  static final Random _random = Random.secure();

  // RFC 4122 v4, like the web's crypto.randomUUID().
  static String _newClientMessageId() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
