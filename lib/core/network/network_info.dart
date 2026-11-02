import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;

  // Emits whenever the device gains or loses a network interface
  // (mobile data, Wi-Fi, ...). Repeated values are filtered out.
  Stream<bool> get onConnectionChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  new(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  @override
  Stream<bool> get onConnectionChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection).distinct();

  static bool _hasConnection(List<ConnectivityResult> result) =>
      result.isNotEmpty && !result.contains(ConnectivityResult.none);
}
