import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/core/network/api_endpoints.dart';
import 'package:lengoal/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lengoal/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  // userType is an int in the API; this app only ever uses "Learner" (4),
  // per the sample token's Role claim.
  static const int _learnerUserType = 4;

  @override
  Future<(UserModel, String, String, bool)> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
          'userType': _learnerUserType,
        },
      );
      final data = _unwrap(response.data!)['data'] as Map<String, dynamic>;
      final accessToken = data['userToken'] as String;
      final refreshToken = data['refreshToken'] as String;
      // isFirstLogin (not hasGoal) decides goal-setup routing — hasGoal
      // stays false after skipping, which would otherwise re-show it.
      final isFirstLogin = data['isFirstLogin'] as bool? ?? false;
      final user = UserModel.fromLoginToken(
        userId: data['userId'] as String,
        accessToken: accessToken,
        fallbackEmail: email,
      );
      return (user, accessToken, refreshToken, isFirstLogin);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.signUp,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'userType': _learnerUserType,
          'inviteeEmail': '',
        },
      );
      _unwrap(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.confirmEmail,
        data: {'email': email, 'otp': otp},
      );
      _unwrap(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.resendOtp,
        data: {'email': email},
      );
      _unwrap(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return _unwrap(response.data!)['data'] as String;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'email': email, 'newPassword': password},
      );
      _unwrap(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post<void>(ApiEndpoints.logout);
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
    final message = (e.response?.data is Map)
        ? (e.response?.data['message'] as String? ??
              'Something went wrong. Please try again.')
        : 'Something went wrong. Please try again.';
    return ServerException(message, e.response?.statusCode);
  }
}
