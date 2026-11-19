import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lengoal/core/utils/logger.dart';
import 'package:livekit_client/livekit_client.dart';

class LobbyDevices extends ChangeNotifier {
  LocalVideoTrack? _camera;
  LocalVideoTrack? get camera => _camera;

  LocalAudioTrack? _microphone;

  bool _busy = false;
  bool get busy => _busy;

  bool _disposed = false;

  // Returns whether the device ended up in the requested state.
  Future<bool> setCamera({required bool enabled}) {
    return _run(() async {
      if (enabled) {
        _camera ??= await LocalVideoTrack.createCameraTrack();
      } else {
        await _release(_camera);
        _camera = null;
      }
    });
  }

  Future<bool> setMicrophone({required bool enabled}) {
    return _run(() async {
      if (enabled) {
        _microphone ??= await LocalAudioTrack.create();
      } else {
        await _release(_microphone);
        _microphone = null;
      }
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    if (_busy) return false;
    _busy = true;
    _notify();
    try {
      await action();
      return true;
    } on Object catch (e) {
      AppLogger.e('[live] lobby device failed: $e');
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  static Future<void> _release(LocalTrack? track) async {
    if (track == null) return;
    await track.stop();
    await track.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    final camera = _camera;
    final microphone = _microphone;
    _camera = null;
    _microphone = null;
    unawaited(_release(camera));
    unawaited(_release(microphone));
    super.dispose();
  }
}
