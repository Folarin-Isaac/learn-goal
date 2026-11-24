import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/goal_setup/data/datasources/goal_remote_data_source.dart';
import 'package:lengoal/features/goal_setup/data/goal_api_endpoints.dart';
import 'package:lengoal/features/goal_setup/data/models/exam_goal_model.dart';
import 'package:lengoal/features/goal_setup/data/models/goal_category_model.dart';
import 'package:lengoal/features/goal_setup/domain/entities/exam_goal.dart';

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

  // Same endpoint as the catalogue, but filtered to one learner it returns
  // their own goals, each carrying that learner's examTargetDate.
  @override
  Future<List<ExamGoalModel>> getLearnerGoals({
    required String learnerId,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        GoalApiEndpoints.goals,
        queryParameters: {
          'PageSize': _pageSize,
          'PageNumber': 1,
          'LearnerId': learnerId,
        },
      );
      return _unwrapList(response.data!).map(ExamGoalModel.fromJson).toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Same body the web sends (names included). The date is the start of the
  // chosen day on the phone, sent in UTC — e.g. 29 Nov in Lagos goes as
  // "2026-11-28T23:00:00.000Z", exactly like the web's toISOString().
  @override
  Future<void> addLearnerGoal({
    required String goalId,
    required DateTime targetDate,
    List<GoalLevel> levels = const [],
    List<GoalSubject> subjects = const [],
  }) async {
    Map<String, String> subject(GoalSubject s) => {
      'subjectId': s.id,
      'name': s.name,
    };
    final day = DateTime(targetDate.year, targetDate.month, targetDate.day);
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        GoalApiEndpoints.addLearnerGoal,
        data: {
          'goals': [
            {
              'goalId': goalId,
              'examTargetDate': day.toUtc().toIso8601String(),
              'levels': [
                for (final level in levels)
                  {
                    'levelId': level.id,
                    'name': level.name,
                    'subjects': level.subjects.map(subject).toList(),
                  },
              ],
              'subjects': subjects.map(subject).toList(),
            },
          ],
        },
      );
      final body = response.data;
      if (body != null && body['succeeded'] == false) {
        throw ServerException(
          body['message'] as String? ??
              'Something went wrong. Please try again.',
        );
      }
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
