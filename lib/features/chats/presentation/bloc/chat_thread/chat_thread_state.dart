part of 'chat_thread_cubit.dart';

enum ChatThreadStatus { loading, loaded, failure }

// A message typed on this device that the server hasn't confirmed yet.
class PendingChatMessage extends Equatable {
  const new({
    required this.clientMessageId,
    required this.text,
    required this.createdOn,
    this.failed = false,
    this.localPath,
    this.mediaUrl,
  });

  final String clientMessageId;
  final String text;
  final DateTime createdOn;
  final bool failed;

  // An attachment picked on this device: shown from [localPath] until the
  // server confirms the message. [mediaUrl] is set once the upload worked,
  // so a retry after a failed send doesn't upload the file again.
  final String? localPath;
  final String? mediaUrl;

  bool get isAttachment => localPath != null;

  PendingChatMessage copyWith({bool? failed, String? mediaUrl}) =>
      PendingChatMessage(
        clientMessageId: clientMessageId,
        text: text,
        createdOn: createdOn,
        failed: failed ?? this.failed,
        localPath: localPath,
        mediaUrl: mediaUrl ?? this.mediaUrl,
      );

  @override
  List<Object?> get props => [
    clientMessageId,
    text,
    createdOn,
    failed,
    localPath,
    mediaUrl,
  ];
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
    this.unreadAfter,
    this.localMedia = const {},
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

  // What the learner had seen before opening the chat this time; others'
  // messages after it get a "New messages" line above them.
  final DateTime? unreadAfter;

  // mediaUrl → the file on this device it was uploaded from, so the
  // learner's own just-sent photos keep showing the local copy instead of
  // being downloaded again (which also stops the bubble flickering).
  final Map<String, String> localMedia;
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
    DateTime? Function()? unreadAfter,
    Map<String, String>? localMedia,
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
      unreadAfter: unreadAfter == null ? this.unreadAfter : unreadAfter(),
      localMedia: localMedia ?? this.localMedia,
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
    unreadAfter: unreadAfter,
    localMedia: localMedia,
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
    unreadAfter,
    localMedia,
    errorMessage,
    effect,
    effectCount,
  ];
}
