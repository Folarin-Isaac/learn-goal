import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/chats/data/datasources/chat_remote_data_source.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';
import 'package:lengoal/features/chats/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  new({required this._remoteDataSource, required this._networkInfo});

  final ChatRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String classId, {
    DateTime? before,
    int take = 30,
  }) => _guard(
    () => _remoteDataSource.getMessages(classId, before: before, take: take),
  );

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String classId,
    required String clientMessageId,
    required String senderAppUserId,
    required String text,
    String? mediaUrl,
  }) => _guard(
    () => _remoteDataSource.sendMessage(
      classId: classId,
      clientMessageId: clientMessageId,
      senderAppUserId: senderAppUserId,
      text: text,
      mediaUrl: mediaUrl,
    ),
  );

  @override
  Future<Either<Failure, String>> editMessage({
    required String classId,
    required String messageId,
    required String newText,
  }) => _guard(
    () => _remoteDataSource.editMessage(
      classId: classId,
      messageId: messageId,
      newText: newText,
    ),
  );

  @override
  Future<Either<Failure, Unit>> deleteMessage({
    required String classId,
    required String messageId,
  }) => _guard(() async {
    await _remoteDataSource.deleteMessage(
      classId: classId,
      messageId: messageId,
    );
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      return right(await action());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
