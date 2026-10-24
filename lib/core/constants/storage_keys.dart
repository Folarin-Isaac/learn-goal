class StorageKeys {
  const new();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String cachedUser = 'cached_user';
  static const String onboardingSeen = 'onboarding_seen';

  // Persisted so a first-time user mid goal-setup resumes there after
  // the app is killed, instead of landing on Home.
  static const String needsGoalSetup = 'needs_goal_setup';
}
