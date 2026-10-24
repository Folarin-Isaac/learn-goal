import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:lengoal/features/profile/data/models/learner_profile_model.dart';
import 'package:lengoal/features/profile/data/profile_api_endpoints.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<LearnerProfileModel> getLearnerProfile() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ProfileApiEndpoints.learnerProfile,
      );
      final body = _unwrap(response.data!);
      return LearnerProfileModel.fromJson(
        body['data']! as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> updateLearnerProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ProfileApiEndpoints.updateLearnerProfile,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'avatarUrl': ?avatarUrl,
        },
      );
      // Success returns data: null, so there is nothing to parse — the
      // unwrap is only here to surface a succeeded:false sent as HTTP 200.
      _unwrap(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<String> uploadFile({required String filePath}) async {
    try {
      final formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ProfileApiEndpoints.uploadFile,
        data: formData,
      );
      final body = _unwrap(response.data!);
      // UploadFile is the odd one out: it leaves data null and returns
      // the hosted file URL in `message` instead.
      final url = body['message'] as String?;
      if (url == null || url.isEmpty) {
        throw ServerException('Upload did not return a file URL.');
      }
      return url;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Every response wraps { data, failed, message, succeeded } — a
  // failure can still be HTTP 200, so succeeded must be checked.
  Map<String, dynamic> _unwrap(Map<String, dynamic> body) {
    if (body['succeeded'] != true) {
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
    const fallback = 'Something went wrong. Please try again.';
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? data['message'] as String? ?? fallback
        : fallback;
    return ServerException(message, e.response?.statusCode);
  }
}
