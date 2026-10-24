import 'package:dio/dio.dart';
import 'package:lengoal/core/constants/storage_keys.dart';
import 'package:lengoal/core/network/api_endpoints.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';

// Attaches the bearer token to requests, and on a 401 tries one silent
// refresh before giving up. Refresh uses a bare Dio so it can't recurse.
class AuthInterceptor extends Interceptor {
  new(this._secureStorage, this._dio);

  final SecureStorageService _secureStorage;
  final Dio _dio;

  // Tracks an in-flight refresh so concurrent 401s share one call.
  Future<String?>? _refreshInFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // Endpoints with no existing session — a 401 here means bad
  // credentials, not an expired token, so never trigger a refresh.
  static const Set<String> _publicAuthEndpoints = {
    ApiEndpoints.signUp,
    ApiEndpoints.confirmEmail,
    ApiEndpoints.login,
    ApiEndpoints.resendOtp,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resetPassword,
    ApiEndpoints.refreshToken,
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isPublicAuthEndpoint = _publicAuthEndpoints.contains(
      err.requestOptions.path,
    );
    if (!isUnauthorized || isPublicAuthEndpoint) {
      handler.next(err);
      return;
    }

    // Concurrent 401s share one refresh call, not one each.
    final newAccessToken = await (_refreshInFlight ??= _refresh());
    _refreshInFlight = null;

    if (newAccessToken == null) {
      await _secureStorage.delete(StorageKeys.accessToken);
      await _secureStorage.delete(StorageKeys.refreshToken);
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  // Swagger's refresh-token has no body/query params, so the refresh
  // token itself travels in the Authorization header.
  Future<String?> _refresh() async {
    final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await Dio(BaseOptions(baseUrl: _dio.options.baseUrl))
          .post<Map<String, dynamic>>(
            ApiEndpoints.refreshToken,
            options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'},
            ),
          );
      final data = response.data?['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['userToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;
      if (newAccessToken == null || newRefreshToken == null) return null;

      await _secureStorage.write(StorageKeys.accessToken, newAccessToken);
      await _secureStorage.write(StorageKeys.refreshToken, newRefreshToken);
      return newAccessToken;
    } on DioException {
      return null;
    }
  }
}
