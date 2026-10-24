import 'dart:async';

import 'package:lengoal/features/auth/domain/repositories/auth_repository.dart';
import 'package:lengoal/features/profile/domain/repositories/profile_repository.dart';

// Keeps the profile cache tied to the session: warms it as soon as the
// learner is authenticated so the profile page has data before it is
// opened, and drops it on sign-out so the next account never sees the
// previous one's name or avatar.
class ProfileSessionSync {
  new({required this._authRepository, required this._profileRepository});

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  StreamSubscription<AuthStatus>? _subscription;

  void start() {
    _subscription ??= _authRepository.authStatusStream.listen(_onStatus);
    _onStatus(_authRepository.currentAuthStatus);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onStatus(AuthStatus status) {
    switch (status) {
      case AuthStatus.authenticated:
        unawaited(_profileRepository.prefetchProfile());
      case AuthStatus.unauthenticated:
        _profileRepository.clearCache();
      case AuthStatus.unknown:
        break;
    }
  }
}
