import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:lengoal/core/env/env.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;

  Stream<bool> get onConnectionChanged;

  void reportRequestOutcome({required bool reachedServer});
}

class NetworkInfoImpl implements NetworkInfo {
  new(this._connectivity, {Future<bool> Function()? probe})
    : _probe = probe ?? _defaultProbe {
    _interfaceSubscription = _connectivity.onConnectivityChanged.listen(
      (result) => _onInterfaceChanged(_hasInterface(result)),
    );
    unawaited(
      _connectivity.checkConnectivity().then(
        (result) => _onInterfaceChanged(_hasInterface(result)),
      ),
    );
  }

  static const Duration _firstRetry = Duration(seconds: 10);
  static const Duration _maxRetry = Duration(seconds: 60);
  static const Duration _probeTimeout = Duration(seconds: 5);
  static const String _publicProbeUrl =
      'https://clients3.google.com/generate_204';

  final Connectivity _connectivity;
  final Future<bool> Function() _probe;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _interfaceSubscription;
  Timer? _retryTimer;
  Duration _retryDelay = _firstRetry;
  Future<bool>? _probeInFlight;

  bool? _interfaceUp;
  bool _reachable = true;
  bool? _lastEmitted;

  bool get _connected => (_interfaceUp ?? true) && _reachable;

  @override
  Stream<bool> get onConnectionChanged => _changes.stream;

  @override
  Future<bool> get isConnected async {
    _interfaceUp ??= _hasInterface(await _connectivity.checkConnectivity());
    if (!_interfaceUp!) return false;
    if (_reachable) return true;
    // Marked unreachable earlier: re-check now rather than blocking the
    // request on a possibly stale verdict.
    return await _checkReachability();
  }

  @override
  void reportRequestOutcome({required bool reachedServer}) {
    if (reachedServer) {
      _setReachable(true);
    } else if (_interfaceUp ?? true) {
      unawaited(_checkReachability());
    }
  }

  void _onInterfaceChanged(bool up) {
    _interfaceUp = up;
    _retryTimer?.cancel();
    _retryDelay = _firstRetry;
    if (!up) {
      _emitIfChanged();
      return;
    }
    unawaited(_checkReachability());
  }

  Future<bool> _checkReachability() {
    return _probeInFlight ??= _probe().then((ok) {
      _probeInFlight = null;
      _setReachable(ok);
      return ok;
    });
  }

  void _setReachable(bool reachable) {
    _reachable = reachable;
    _retryTimer?.cancel();
    if (reachable) {
      _retryDelay = _firstRetry;
    } else if (_interfaceUp ?? true) {
      _retryTimer = Timer(_retryDelay, () => unawaited(_checkReachability()));
      final doubled = _retryDelay * 2;
      _retryDelay = doubled > _maxRetry ? _maxRetry : doubled;
    }
    _emitIfChanged();
  }

  void _emitIfChanged() {
    final connected = _connected;
    if (connected == _lastEmitted) return;
    _lastEmitted = connected;
    _changes.add(connected);
  }

  static bool _hasInterface(List<ConnectivityResult> result) =>
      result.isNotEmpty && !result.contains(ConnectivityResult.none);

  // Reachable if either our backend or a public 204 endpoint answers with
  // any HTTP response, so a backend outage alone never reads as "no
  // internet".
  static Future<bool> _defaultProbe() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: _probeTimeout,
        receiveTimeout: _probeTimeout,
        validateStatus: (_) => true,
      ),
    );
    Future<bool> hit(String url) async {
      try {
        await dio.head<void>(url);
        return true;
      } on DioException {
        return false;
      }
    }

    final completer = Completer<bool>();
    var pending = 2;
    for (final url in [Env.baseUrl, _publicProbeUrl]) {
      unawaited(
        hit(url).then((ok) {
          pending--;
          if (ok && !completer.isCompleted) completer.complete(true);
          if (pending == 0 && !completer.isCompleted) {
            completer.complete(false);
          }
        }),
      );
    }
    final result = await completer.future;
    dio.close(force: true);
    return result;
  }

  Future<void> dispose() async {
    _retryTimer?.cancel();
    await _interfaceSubscription?.cancel();
    await _changes.close();
  }
}
