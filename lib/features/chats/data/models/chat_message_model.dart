import 'package:lengoal/features/chats/domain/entities/chat_message.dart';

// ClassChatMessageDto. `chatId` is the class id.
class ChatMessageModel {
  const new();

  static ChatMessage fromJson(Map<String, dynamic> json, {String? classId}) {
    final user = json['user'] as Map<String, dynamic>?;
    return ChatMessage(
      id: json['id'] as String? ?? '',
      classId: json['chatId'] as String? ?? classId ?? '',
      clientMessageId: json['clientMessageId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      mediaUrl: _nonEmpty(json['mediaUrl']),
      createdOn: parseUtc(json['createdOn'] as String?),
      sender: user == null
          ? null
          : ChatSender(
              userId: user['userId'] as String? ?? '',
              name: user['name'] as String? ?? '',
              email: user['email'] as String? ?? '',
              photoUrl: _nonEmpty(user['photoUrl']),
            ),
    );
  }

  static bool isDeleted(Map<String, dynamic> json) =>
      json['isDeleted'] as bool? ?? false;

  // POST answers "2026-11-20T09:37:38.94Z" but GET drops the Z
  // ("2026-11-20T09:37:38.94"); both are UTC, and Dart would read the
  // second as local time.
  static DateTime parseUtc(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.now().toUtc();
    final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
    final parsed = DateTime.tryParse(hasZone ? raw : '${raw}Z');
    return (parsed ?? DateTime.now()).toUtc();
  }

  static String? _nonEmpty(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
