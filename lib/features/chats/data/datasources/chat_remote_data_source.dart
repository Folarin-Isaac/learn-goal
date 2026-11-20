import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/chats/data/chat_api_endpoints.dart';
import 'package:lengoal/features/chats/data/models/chat_message_model.dart';
import 'package:lengoal/features/chats/domain/entities/chat_message.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessage>> getMessages(
    String classId, {
    DateTime? before,
    int take,
  });

  Future<ChatMessage> sendMessage({
    required String classId,
    required String clientMessageId,
    required String senderAppUserId,
    required String text,
    String? mediaUrl,
  });

  Future<String> editMessage({
    required String classId,
    required String messageId,
    required String newText,
  });

  Future<void> deleteMessage({
    required String classId,
    required String messageId,
  });
}

// Bodies match the web's requests (SendClassChatMessageCommand and
// EditClassChatMessageCommand in the API spec).
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  static const String _genericError = 'Something went wrong. Please try again.';

  @override
  Future<List<ChatMessage>> getMessages(
    String classId, {
    DateTime? before,
    int take = 30,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ChatApiEndpoints.messages(classId),
        queryParameters: {
          'take': take,
          if (before != null) 'before': before.toUtc().toIso8601String(),
        },
      );
      final data = _checkSucceeded(response.data!)['data'] as List<dynamic>?;
      final messages =
          (data ?? const [])
              .cast<Map<String, dynamic>>()
              .where((json) => !ChatMessageModel.isDeleted(json))
              .map((json) => ChatMessageModel.fromJson(json, classId: classId))
              .toList()
            ..sort((a, b) => a.createdOn.compareTo(b.createdOn));
      return messages;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String classId,
    required String clientMessageId,
    required String senderAppUserId,
    required String text,
    String? mediaUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ChatApiEndpoints.messages(classId),
        data: {
          'classId': classId,
          'clientMessageId': clientMessageId,
          'senderAppUserId': senderAppUserId,
          'text': text,
          'mediaUrl': ?mediaUrl,
        },
      );
      final data = _checkSucceeded(response.data!)['data'];
      if (data is! Map<String, dynamic>) throw ServerException();
      return ChatMessageModel.fromJson(data, classId: classId);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // The response carries the new text but nulls chatId and user, so only
  // the text is taken from it.
  @override
  Future<String> editMessage({
    required String classId,
    required String messageId,
    required String newText,
  }) async {
    try {
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        ChatApiEndpoints.message(classId, messageId),
        data: {'classId': classId, 'messageId': messageId, 'newText': newText},
      );
      final data = _checkSucceeded(response.data!)['data'];
      final text = data is Map<String, dynamic> ? data['text'] : null;
      return text is String ? text : newText;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> deleteMessage({
    required String classId,
    required String messageId,
  }) async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        ChatApiEndpoints.message(classId, messageId),
      );
      final body = response.data;
      if (body != null) _checkSucceeded(body);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Map<String, dynamic> _checkSucceeded(Map<String, dynamic> body) {
    if (body['succeeded'] == false) {
      final message = body['message'];
      throw ServerException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : _genericError,
      );
    }
    return body;
  }

  Exception _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) return UnauthorizedException();
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? data['message'] as String?
        : null;
    return ServerException(message ?? _genericError, e.response?.statusCode);
  }
}
