import 'dart:collection';

import 'package:lengoal/features/chats/domain/entities/chat_message.dart';

typedef CachedThread = ({List<ChatMessage> messages, bool hasOlder});

// Messages of chats opened during this session, so reopening a chat shows
// them straight away (no spinner) while the usual refresh fetches anything
// new behind them. Memory only, and bounded: the [maxThreads] most recently
// used chats, each trimmed to its newest [maxMessages]. Cleared on sign-out
// so the next account never sees these messages.
class ChatThreadCache {
  new();

  static const int maxThreads = 20;
  static const int maxMessages = 200;

  final LinkedHashMap<String, CachedThread> _threads = LinkedHashMap();

  CachedThread? get(String classId) {
    final thread = _threads.remove(classId);
    if (thread == null) return null;
    _threads[classId] = thread;
    return thread;
  }

  void put(
    String classId, {
    required List<ChatMessage> messages,
    required bool hasOlder,
  }) {
    final trimmed = messages.length > maxMessages;
    _threads
      ..remove(classId)
      ..[classId] = (
        messages: List.unmodifiable(
          trimmed ? messages.sublist(messages.length - maxMessages) : messages,
        ),
        hasOlder: hasOlder || trimmed,
      );
    while (_threads.length > maxThreads) {
      _threads.remove(_threads.keys.first);
    }
  }

  void clear() => _threads.clear();
}
