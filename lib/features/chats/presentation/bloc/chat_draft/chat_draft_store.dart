import 'package:flutter/foundation.dart';

// Unsent text per class chat, kept for the app session so leaving a chat
// (or switching tabs) doesn't lose what was typed. The chat list shows it
// as a "Draft:" preview.
class ChatDraftStore {
  new();

  final ValueNotifier<Map<String, String>> drafts = ValueNotifier(const {});

  String of(String classId) => drafts.value[classId] ?? '';

  void save(String classId, String text) {
    final trimmed = text.trim();
    final current = drafts.value[classId];
    if (trimmed.isEmpty) {
      if (current == null) return;
      drafts.value = {...drafts.value}..remove(classId);
      return;
    }
    if (current == text) return;
    drafts.value = {...drafts.value, classId: text};
  }

  void clear() => drafts.value = const {};
}
