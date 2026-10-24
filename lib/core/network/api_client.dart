import 'package:dio/dio.dart';
import 'package:lengoal/core/constants/app_constants.dart';
import 'package:lengoal/core/env/env.dart';
import 'package:lengoal/core/network/interceptors/auth_interceptor.dart';
import 'package:lengoal/core/network/interceptors/logging_interceptor.dart';
import 'package:lengoal/core/storage/secure_storage_service.dart';

class ApiClient {
  new(SecureStorageService secureStorage, {bool enableLogging = false}) {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorage, dio));
    if (enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }
  }

  late final Dio dio;
}
