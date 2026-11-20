part of 'chat_list_cubit.dart';

enum ChatListStatus { loading, loaded, failure }

class ChatPreview extends Equatable {
  const new({
    required this.lengoalClass,
    required this.latest,
    required this.isLoaded,
  });

  final LengoalClass lengoalClass;

  // null when the chat is empty (or its preview couldn't be loaded).
  final ChatMessage? latest;
  final bool isLoaded;

  @override
  List<Object?> get props => [lengoalClass, latest, isLoaded];
}

class ChatListState extends Equatable {
  const new({
    this.status = ChatListStatus.loading,
    this.classes = const [],
    this.latest = const {},
    this.query = '',
    this.errorMessage,
  });

  final ChatListStatus status;

  // Every class the learner is enrolled in, across all goals.
  final List<LengoalClass> classes;

  // classId → newest message; a key with a null value is an empty chat,
  // a missing key a preview not loaded yet.
  final Map<String, ChatMessage?> latest;
  final String query;
  final String? errorMessage;

  bool get hasClasses => classes.isNotEmpty;

  // Matches on the class name, most recent conversation first; chats with
  // no messages keep the library's order after them.
  List<ChatPreview> get visible {
    final needle = query.trim().toLowerCase();
    final matches = [
      for (final c in classes)
        if (needle.isEmpty || c.cohortName.toLowerCase().contains(needle))
          ChatPreview(
            lengoalClass: c,
            latest: latest[c.id],
            isLoaded: latest.containsKey(c.id),
          ),
    ];
    final order = {for (var i = 0; i < classes.length; i++) classes[i].id: i};
    matches.sort((a, b) {
      final at = a.latest?.createdOn;
      final bt = b.latest?.createdOn;
      if (at != null && bt != null) return bt.compareTo(at);
      if (at != null) return -1;
      if (bt != null) return 1;
      return order[a.lengoalClass.id]!.compareTo(order[b.lengoalClass.id]!);
    });
    return matches;
  }

  ChatListState copyWith({
    ChatListStatus? status,
    List<LengoalClass>? classes,
    Map<String, ChatMessage?>? latest,
    String? query,
    String? Function()? errorMessage,
  }) {
    return ChatListState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      latest: latest ?? this.latest,
      query: query ?? this.query,
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    );
  }

  @override
  List<Object?> get props => [status, classes, latest, query, errorMessage];
}
