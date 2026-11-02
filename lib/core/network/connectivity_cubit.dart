import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/network/network_info.dart';

enum ConnectivityStatus { unknown, online, offline, restored }

// `restored` is a short-lived state after coming back online so the UI
// can confirm reconnection before settling back to plain `online`.
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  new(this._networkInfo) : super(ConnectivityStatus.unknown) {
    _subscription = _networkInfo.onConnectionChanged.listen(_onChanged);
    unawaited(_networkInfo.isConnected.then(_onInitial));
    // Background retries are wasted work nobody can see; pause them while
    // the app is off-screen and re-check the moment it is shown again.
    _lifecycle = AppLifecycleListener(
      onHide: () => _networkInfo.setForeground(foreground: false),
      onShow: () => _networkInfo.setForeground(foreground: true),
    );
  }

  static const Duration restoredFor = Duration(seconds: 2);

  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;
  Timer? _restoredTimer;
  late final AppLifecycleListener _lifecycle;

  void _onInitial(bool connected) {
    if (isClosed || state != ConnectivityStatus.unknown) return;
    emit(connected ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  void _onChanged(bool connected) {
    _restoredTimer?.cancel();
    if (!connected) {
      emit(ConnectivityStatus.offline);
      return;
    }
    if (state != ConnectivityStatus.offline) {
      emit(ConnectivityStatus.online);
      return;
    }
    emit(ConnectivityStatus.restored);
    _restoredTimer = Timer(restoredFor, () {
      if (!isClosed) emit(ConnectivityStatus.online);
    });
  }

  @override
  Future<void> close() async {
    _lifecycle.dispose();
    _restoredTimer?.cancel();
    await _subscription?.cancel();
    await super.close();
  }
}
