import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/goal_setup/data/datasources/goal_remote_data_source.dart';
import 'package:lengoal/features/goal_setup/data/goal_api_endpoints.dart';
import 'package:lengoal/features/goal_setup/data/models/exam_goal_model.dart';
import 'package:lengoal/features/goal_setup/data/models/exam_stage_model.dart';
import 'package:lengoal/features/goal_setup/data/models/goal_category_model.dart';
import 'package:lengoal/features/goal_setup/data/models/learning_goal_model.dart';

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  // The list endpoints are paged. The setup steps show every option in
  // one scrollable card rather than paginating, so ask for a page large
  // enough to cover the whole catalogue in a single call.
  static const int _pageSize = 100;

  @override
  Future<List<GoalCategoryModel>> getCategories({String? searchTerm}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        GoalApiEndpoints.categories,
        queryParameters: {
          'PageSize': _pageSize,
          'PageNumber': 1,
          if (searchTerm != null && searchTerm.isNotEmpty)
            'SearchTerm': searchTerm,
        },
      );
      return _unwrapList(response.data!)
          .map(GoalCategoryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<List<ExamGoalModel>> getGoals({
    required String categoryId,
    String? searchTerm,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        GoalApiEndpoints.goals,
        queryParameters: {
          'PageSize': _pageSize,
          'PageNumber': 1,
          'CategoryId': categoryId,
          if (searchTerm != null && searchTerm.isNotEmpty)
            'SearchTerm': searchTerm,
        },
      );
      return _unwrapList(response.data!).map(ExamGoalModel.fromJson).toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<List<ExamStageModel>> getExamStages({required String examId}) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        GoalApiEndpoints.examStages,
        queryParameters: {'examId': examId},
      );
      return response.data!
          .map((json) => ExamStageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<LearningGoalModel> saveGoal({
    required String fieldId,
    required String examId,
    required String stageId,
    required List<String> topicIds,
    required DateTime targetDate,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        GoalApiEndpoints.saveGoal,
        data: {
          'fieldId': fieldId,
          'examId': examId,
          'stageId': stageId,
          'topicIds': topicIds,
          'targetDate': targetDate.toIso8601String(),
        },
      );
      return LearningGoalModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Paged responses wrap { data: [...], page, totalPages, failed, message,
  // succeeded }. A failure can still come back as HTTP 200, so succeeded
  // must be checked — same contract as auth's _unwrap.
  List<Map<String, dynamic>> _unwrapList(Map<String, dynamic> body) {
    if (body['succeeded'] != true) {
      throw ServerException(
        body['message'] as String? ?? 'Something went wrong. Please try again.',
      );
    }
    final data = body['data'] as List<dynamic>? ?? const [];
    return data.cast<Map<String, dynamic>>();
  }

  Exception _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) {
      return UnauthorizedException();
    }
    final String message;
    if (e.response?.data is Map) {
      message =
          e.response?.data['message'] as String? ??
          'Something went wrong. Please try again.';
    } else {
      message = 'Something went wrong. Please try again.';
    }
    return ServerException(message, e.response?.statusCode);
  }
}
