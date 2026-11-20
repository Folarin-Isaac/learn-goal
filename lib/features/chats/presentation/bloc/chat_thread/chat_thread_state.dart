part of 'chat_thread_cubit.dart';

enum ChatThreadStatus { loading, loaded, failure }

// A message typed on this device that the server hasn't confirmed yet.
class PendingChatMessage extends Equatable {
  const new({
    required this.clientMessageId,
    required this.text,
    required this.createdOn,
    this.failed = false,
  });

  final String clientMessageId;
  final String text;
  final DateTime createdOn;
  final bool failed;

  PendingChatMessage asFailed({required bool failed}) => PendingChatMessage(
    clientMessageId: clientMessageId,
    text: text,
    createdOn: createdOn,
    failed: failed,
  );

  @override
  List<Object?> get props => [clientMessageId, text, createdOn, failed];
}

enum ChatThreadEffectKind { error, deleted }

class ChatThreadEffect extends Equatable {
  const new error(this.message) : kind = ChatThreadEffectKind.error;

  const new deleted() : kind = ChatThreadEffectKind.deleted, message = '';

  final ChatThreadEffectKind kind;
  final String message;

  @override
  List<Object?> get props => [kind, message];
}

class ChatThreadState extends Equatable {
  const new({
    this.status = ChatThreadStatus.loading,
    this.identity = const ChatIdentity(userId: '', email: ''),
    this.messages = const [],
    this.pending = const [],
    this.editedIds = const {},
    this.hasOlder = false,
    this.isLoadingOlder = false,
    this.loadOlderFailed = false,
    this.editing,
    this.isSavingEdit = false,
    this.deletingId,
    this.errorMessage,
    this.effect,
    this.effectCount = 0,
  });

  final ChatThreadStatus status;
  final ChatIdentity identity;

  // Confirmed messages, oldest first.
  final List<ChatMessage> messages;
  final List<PendingChatMessage> pending;

  // The API has no "edited" flag, so this only knows about edits made on
  // this device during this visit (the web behaves the same way).
  final Set<String> editedIds;
  final bool hasOlder;
  final bool isLoadingOlder;
  final bool loadOlderFailed;

  // The learner's own message being edited in the composer.
  final ChatMessage? editing;
  final bool isSavingEdit;
  final String? deletingId;
  final String? errorMessage;

  // One-off snackbar for the page; effectCount bumps on every emission so
  // repeats still reach the listener.
  final ChatThreadEffect? effect;
  final int effectCount;

  bool get isEmpty => messages.isEmpty && pending.isEmpty;

  ChatThreadState copyWith({
    ChatThreadStatus? status,
    ChatIdentity? identity,
    List<ChatMessage>? messages,
    List<PendingChatMessage>? pending,
    Set<String>? editedIds,
    bool? hasOlder,
    bool? isLoadingOlder,
    bool? loadOlderFailed,
    ChatMessage? Function()? editing,
    bool? isSavingEdit,
    String? Function()? deletingId,
    String? Function()? errorMessage,
  }) {
    return ChatThreadState(
      status: status ?? this.status,
      identity: identity ?? this.identity,
      messages: messages ?? this.messages,
      pending: pending ?? this.pending,
      editedIds: editedIds ?? this.editedIds,
      hasOlder: hasOlder ?? this.hasOlder,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      loadOlderFailed: loadOlderFailed ?? this.loadOlderFailed,
      editing: editing == null ? this.editing : editing(),
      isSavingEdit: isSavingEdit ?? this.isSavingEdit,
      deletingId: deletingId == null ? this.deletingId : deletingId(),
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
      effect: effect,
      effectCount: effectCount,
    );
  }

  ChatThreadState withEffect(ChatThreadEffect effect) => ChatThreadState(
    status: status,
    identity: identity,
    messages: messages,
    pending: pending,
    editedIds: editedIds,
    hasOlder: hasOlder,
    isLoadingOlder: isLoadingOlder,
    loadOlderFailed: loadOlderFailed,
    editing: editing,
    isSavingEdit: isSavingEdit,
    deletingId: deletingId,
    errorMessage: errorMessage,
    effect: effect,
    effectCount: effectCount + 1,
  );

  @override
  List<Object?> get props => [
    status,
    identity,
    messages,
    pending,
    editedIds,
    hasOlder,
    isLoadingOlder,
    loadOlderFailed,
    editing,
    isSavingEdit,
    deletingId,
    errorMessage,
    effect,
    effectCount,
  ];
}
