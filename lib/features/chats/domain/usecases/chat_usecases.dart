import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/domain/repositories/chat_repository.dart';

class GetChatMessagesUseCase {
  new(this._repository);

  final ChatRepository _repository;

  static const int pageSize = 30;

  Future<Either<Failure, List<ChatMessage>>> call(
    String classId, {
    DateTime? before,
    int take = pageSize,
  }) => _repository.getMessages(classId, before: before, take: take);
}

// The newest message of a class, for the chat list preview. null when the
// chat is empty.
class GetLatestChatMessageUseCase {
  new(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatMessage?>> call(String classId) async {
    final result = await _repository.getMessages(classId, take: 1);
    return result.map((messages) => messages.isEmpty ? null : messages.last);
  }
}

class GetChatIdentityUseCase {
  new(this._authRepository);

  final AuthRepository _authRepository;

  Future<ChatIdentity> call() async {
    final user = await _authRepository.getCurrentUser();
    return ChatIdentity(userId: user?.id ?? '', email: user?.email ?? '');
  }
}

class SendChatMessageUseCase {
  new(this._repository, this._getIdentity);

  final ChatRepository _repository;
  final GetChatIdentityUseCase _getIdentity;

  Future<Either<Failure, ChatMessage>> call({
    required String classId,
    required String clientMessageId,
    required String text,
    String? mediaUrl,
  }) async {
    final identity = await _getIdentity();
    return await _repository.sendMessage(
      classId: classId,
      clientMessageId: clientMessageId,
      senderAppUserId: identity.userId,
      text: text,
      mediaUrl: mediaUrl,
    );
  }
}

class EditChatMessageUseCase {
  new(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, String>> call({
    required String classId,
    required String messageId,
    required String newText,
  }) => _repository.editMessage(
    classId: classId,
    messageId: messageId,
    newText: newText,
  );
}

class DeleteChatMessageUseCase {
  new(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String classId,
    required String messageId,
  }) => _repository.deleteMessage(classId: classId, messageId: messageId);
}
