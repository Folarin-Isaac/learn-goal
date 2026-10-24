import 'package:dio/dio.dart';
import 'package:lengoal/core/utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d(
      '--> ${options.method} ${options.uri}'
      '\nheaders: ${options.headers}\nbody: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d(
      '<-- ${response.statusCode} '
      '${response.requestOptions.uri}\nbody: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // `err` alone just stringifies to a generic Dio message — the real
    // error is in the response body, so log that explicitly.
    AppLogger.e(
      '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}'
      '\nbody: ${err.response?.data}',
      err,
      err.stackTrace,
    );
    handler.next(err);
  }
}
