import 'dart:convert';
import 'dart:math';

class LiveChatMessage {
  const new({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.fromIdentity,
    required this.fromName,
    required this.isLocal,
    this.isEdited = false,
  });

  final String id;
  final String message;
  final int timestamp;
  final String fromIdentity;
  final String fromName;
  final bool isLocal;
  final bool isEdited;

  DateTime get sentAt => DateTime.fromMillisecondsSinceEpoch(timestamp);
}

class LiveChatPayload {
  const new({required this.id, required this.message, required this.timestamp});

  static const String topic = 'lk-chat-topic';
  static const String updateTopic = 'lk-chat-update-topic';

  final String id;
  final String message;
  final int timestamp;

  static LiveChatPayload? decode(List<int> data) {
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(data));
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final message = decoded['message'];
    if (message is! String || message.isEmpty) return null;
    final id = decoded['id'];
    final timestamp = decoded['timestamp'];
    return LiveChatPayload(
      id: id is String && id.isNotEmpty ? id : newChatId(),
      message: message,
      timestamp: timestamp is num
          ? timestamp.toInt()
          : DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<int> encode() => utf8.encode(
    jsonEncode({'id': id, 'message': message, 'timestamp': timestamp}),
  );
}

final Random _random = Random.secure();

String newChatId() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

// Same grouping as the web: the name is hidden when the previous message is
// from the same person; the time is hidden too if it was under a minute
// earlier.
({bool hideName, bool hideTime}) chatEntryMeta(
  List<LiveChatMessage> messages,
  int index,
) {
  if (index == 0) return (hideName: false, hideTime: false);
  final previous = messages[index - 1];
  final current = messages[index];
  final sameSender = previous.fromIdentity == current.fromIdentity;
  final withinMinute = current.timestamp - previous.timestamp < 60000;
  return (hideName: sameSender, hideTime: sameSender && withinMinute);
}
