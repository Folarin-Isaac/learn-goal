class ApiEndpoints {
  const new();

  static const String signUp = '/api/v1/Authentication/sign-up';
  static const String confirmEmail = '/api/v1/Authentication/confirm-email';
  static const String login = '/api/v1/Authentication/login';
  static const String logout = '/api/v1/Authentication/logout';
  static const String forgotPassword = '/api/v1/Authentication/forgot-password';
  static const String resetPassword = '/api/v1/Authentication/reset-password';
  static const String resendOtp = '/api/v1/Authentication/Resend-Otp';
  static const String refreshToken = '/api/v1/Authentication/refresh-token';
}
