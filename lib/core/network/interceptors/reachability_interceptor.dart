import 'package:dio/dio.dart';
import 'package:lengoal/core/network/network_info.dart';

// Every request doubles as a free reachability check: any HTTP response
// (even an error status) proves the internet works, while a failed
// connection hints it doesn't. Slow-network timeouts are deliberately
// ignored so a sluggish connection isn't reported as offline.
class ReachabilityInterceptor extends Interceptor {
  new(this._networkInfo);

  final NetworkInfo _networkInfo;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _networkInfo.reportRequestOutcome(reachedServer: true);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _networkInfo.reportRequestOutcome(reachedServer: true);
    } else if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      _networkInfo.reportRequestOutcome(reachedServer: false);
    }
    handler.next(err);
  }
}
