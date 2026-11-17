import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/classes/data/class_api_endpoints.dart';
import 'package:lengoal/features/classes/data/models/discussion_post_model.dart';
import 'package:lengoal/features/classes/domain/entities/discussion_post.dart';

abstract class ClassDiscussionRemoteDataSource {
  Future<List<DiscussionPost>> getPosts(String classId);

  Future<List<DiscussionPost>> getReplies({
    required String classId,
    required String postId,
  });

  Future<void> postMessage({
    required String classId,
    required String message,
    String? parentPostId,
  });
}

class ClassDiscussionRemoteDataSourceImpl
    implements ClassDiscussionRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  // Page and Length are sent, but the backend hasn't been confirmed to
  // honour them yet, so one large page stands in for infinite scroll.
  static const int _pageLength = 50;

  @override
  Future<List<DiscussionPost>> getPosts(String classId) {
    return _getList(
      ClassApiEndpoints.classDiscussion,
      queryParameters: {'ClassId': classId, 'Page': 1, 'Length': _pageLength},
    );
  }

  @override
  Future<List<DiscussionPost>> getReplies({
    required String classId,
    required String postId,
  }) {
    return _getList(
      ClassApiEndpoints.classDiscussionReplies,
      queryParameters: {'ClassId': classId, 'PostId': postId},
    );
  }

  // Learners always post as UserType 4. The response body isn't documented
  // yet, so callers refetch rather than rely on it.
  @override
  Future<void> postMessage({
    required String classId,
    required String message,
    String? parentPostId,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ClassApiEndpoints.classDiscussion,
        data: {
          'classId': classId,
          'parentPostId': parentPostId,
          'message': message,
          'userType': DiscussionUserRole.learner.code,
        },
      );
      _checkSucceeded(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<List<DiscussionPost>> _getList(
    String path, {
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = _checkSucceeded(response.data)['data'];
      final items = data is List<dynamic> ? data : const <dynamic>[];
      return items
          .whereType<Map<String, dynamic>>()
          .map(discussionPostFromJson)
          .where((post) => post.id.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Map<String, dynamic> _checkSucceeded(Map<String, dynamic>? body) {
    if (body == null) return const {};
    if (body['succeeded'] == false) {
      throw ServerException(
        body['message'] as String? ?? 'Something went wrong. Please try again.',
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
    return ServerException(
      message ?? 'Something went wrong. Please try again.',
      e.response?.statusCode,
    );
  }
}
