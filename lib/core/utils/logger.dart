import 'package:flutter/foundation.dart';

class AppLogger {
  const new _();

  static void d(String message) => _log('DEBUG', message);
  static void i(String message) => _log('INFO', message);
  static void w(String message) => _log('WARN', message);
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message);
    if (error != null) _log('ERROR', error.toString());
    if (stackTrace != null) _log('ERROR', stackTrace.toString());
  }

  static void _log(String level, String message) {
    if (kDebugMode) {
      debugPrint('[$level] $message');
    }
  }
}
