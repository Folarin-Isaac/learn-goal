import 'package:lengoal/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<
    (UserModel user, String accessToken, String refreshToken, bool isFirstLogin)
  >
  login({required String email, required String password});

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<void> verifyOtp({required String email, required String otp});

  Future<void> resendOtp({required String email});

  Future<String> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  });

  Future<void> logout();
}
