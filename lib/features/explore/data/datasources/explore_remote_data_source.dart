import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/explore/data/explore_api_endpoints.dart';
import 'package:lengoal/features/explore/data/models/explore_models.dart';
import 'package:lengoal/features/explore/domain/entities/explore_category.dart';
import 'package:lengoal/features/explore/domain/entities/explore_class.dart';
import 'package:lengoal/features/explore/domain/entities/top_educator.dart';

abstract class ExploreRemoteDataSource {
  Future<List<ExploreCategory>> getCategories();

  Future<List<ExploreClass>> getCategoryClasses({String? categoryId});

  Future<List<ExploreClass>> getOngoingClasses();

  Future<List<ExploreClass>> getUpcomingClasses();

  Future<List<TopEducator>> getTopEducators();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  // Each Explore row scrolls sideways through a short preview, so one
  // page per row is enough. Categories are few and all shown as chips.
  static const int _rowPageSize = 10;
  static const int _categoryPageSize = 50;

  @override
  Future<List<ExploreCategory>> getCategories() async {
    final items = await _getPage(
      ExploreApiEndpoints.categories,
      pageSize: _categoryPageSize,
    );
    return items.map(exploreCategoryFromJson).toList();
  }

  @override
  Future<List<ExploreClass>> getCategoryClasses({String? categoryId}) async {
    final items = await _getPage(
      ExploreApiEndpoints.categoryClasses,
      extraParameters: {
        if (categoryId != null && categoryId.isNotEmpty)
          'CategoryId': categoryId,
      },
    );
    return items.map(exploreClassFromJson).toList();
  }

  @override
  Future<List<ExploreClass>> getOngoingClasses() async {
    final items = await _getPage(ExploreApiEndpoints.ongoingClasses);
    return items.map(exploreClassFromJson).toList();
  }

  @override
  Future<List<ExploreClass>> getUpcomingClasses() async {
    final items = await _getPage(ExploreApiEndpoints.upcomingClasses);
    return items.map(exploreClassFromJson).toList();
  }

  @override
  Future<List<TopEducator>> getTopEducators() async {
    final items = await _getPage(ExploreApiEndpoints.topEducators);
    return items.map(topEducatorFromJson).toList();
  }

  Future<List<Map<String, dynamic>>> _getPage(
    String path, {
    int pageSize = _rowPageSize,
    Map<String, dynamic> extraParameters = const {},
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'PageSize': pageSize,
          'PageNumber': 1,
          ...extraParameters,
        },
      );
      final body = response.data!;
      if (body['succeeded'] == false) {
        throw ServerException(
          body['message'] as String? ??
              'Something went wrong. Please try again.',
        );
      }
      final data = body['data'] as List<dynamic>? ?? const [];
      return data.whereType<Map<String, dynamic>>().toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException();
      }
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message'] as String?
          : null;
      throw ServerException(
        message ?? 'Something went wrong. Please try again.',
        e.response?.statusCode,
      );
    }
  }
}
