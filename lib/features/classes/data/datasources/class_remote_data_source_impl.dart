import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/classes/data/class_api_endpoints.dart';
import 'package:lengoal/features/classes/data/datasources/class_remote_data_source.dart';
import 'package:lengoal/features/classes/data/models/lengoal_class_model.dart';

class ClassRemoteDataSourceImpl implements ClassRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  // Lists are rendered in full rather than paginated, so one large page
  // covers them. Each class payload is heavy, hence smaller than the
  // goal-setup catalogue page.
  static const int _pageSize = 50;

  @override
  Future<List<LengoalClassModel>> getSubscribedClasses({String? searchTerm}) {
    return _getList(ClassApiEndpoints.subscribedClasses, searchTerm);
  }

  @override
  Future<List<LengoalClassModel>> getAllClasses({String? searchTerm}) {
    return _getList(ClassApiEndpoints.allClasses, searchTerm);
  }

  @override
  Future<List<LengoalClassModel>> getSavedClasses({String? searchTerm}) {
    return _getList(ClassApiEndpoints.savedClasses, searchTerm);
  }

  @override
  Future<LengoalClassModel> getClass(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ClassApiEndpoints.classById(id),
      );
      final body = _checkSucceeded(response.data!);
      return LengoalClassModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<List<LengoalClassModel>> _getList(
    String path,
    String? searchTerm,
  ) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'PageSize': _pageSize,
          'PageNumber': 1,
          if (searchTerm != null && searchTerm.isNotEmpty)
            'SearchTerm': searchTerm,
        },
      );
      return _unwrapList(response.data!)
          .map(LengoalClassModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Envelopes differ per endpoint: subscribed-classes returns
  // { data: [...] }, saved classes adds paging fields alongside, and
  // GetAllClasses nests a second envelope at data.data. Unwrap until a
  // list turns up, checking `succeeded` at each level since failures can
  // arrive as HTTP 200.
  List<Map<String, dynamic>> _unwrapList(Map<String, dynamic> body) {
    final data = _checkSucceeded(body)['data'];
    if (data is Map<String, dynamic>) return _unwrapList(data);
    return (data as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _checkSucceeded(Map<String, dynamic> body) {
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
    if (e.response?.statusCode == 401) {
      return UnauthorizedException();
    }
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
