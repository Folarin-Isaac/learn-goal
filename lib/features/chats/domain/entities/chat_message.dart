import 'package:equatable/equatable.dart';

class ChatSender extends Equatable {
  const new({
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String userId;
  final String name;
  final String email;
  final String? photoUrl;

  @override
  List<Object?> get props => [userId, name, email, photoUrl];
}

// One message in a class's group chat. The chat id is the class id.
class ChatMessage extends Equatable {
  const new({
    required this.id,
    required this.classId,
    required this.clientMessageId,
    required this.text,
    required this.createdOn,
    this.mediaUrl,
    this.sender,
  });

  final String id;
  final String classId;
  final String clientMessageId;
  final String text;
  final String? mediaUrl;

  // Always UTC.
  final DateTime createdOn;
  final ChatSender? sender;

  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  ChatMessage withText(String text) => ChatMessage(
    id: id,
    classId: classId,
    clientMessageId: clientMessageId,
    text: text,
    createdOn: createdOn,
    mediaUrl: mediaUrl,
    sender: sender,
  );

  @override
  List<Object?> get props => [
    id,
    classId,
    clientMessageId,
    text,
    mediaUrl,
    createdOn,
    sender,
  ];
}

// Who "me" is when deciding which bubbles are the learner's own. The API
// echoes both the user id and email on every message; either matching
// counts, since sessions from before the id was stored may only have the
// email.
class ChatIdentity extends Equatable {
  const new({required this.userId, required this.email});

  final String userId;
  final String email;

  bool owns(ChatMessage message) {
    final sender = message.sender;
    if (sender == null) return false;
    if (userId.isNotEmpty &&
        sender.userId.toLowerCase() == userId.toLowerCase()) {
      return true;
    }
    return email.isNotEmpty &&
        sender.email.toLowerCase() == email.toLowerCase();
  }

  @override
  List<Object?> get props => [userId, email];
}
