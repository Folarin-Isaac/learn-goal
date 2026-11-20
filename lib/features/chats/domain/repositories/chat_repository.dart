import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';

abstract class ChatRepository {
  // Newest [take] messages sent before [before] (or the newest overall),
  // oldest first, deleted ones left out.
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String classId, {
    DateTime? before,
    int take = 30,
  });

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String classId,
    required String clientMessageId,
    required String senderAppUserId,
    required String text,
    String? mediaUrl,
  });

  // Returns the saved text.
  Future<Either<Failure, String>> editMessage({
    required String classId,
    required String messageId,
    required String newText,
  });

  Future<Either<Failure, Unit>> deleteMessage({
    required String classId,
    required String messageId,
  });
}
