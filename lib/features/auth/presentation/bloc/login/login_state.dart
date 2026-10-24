part of 'login_bloc.dart';

enum LoginStatus { initial, submitting, success, failure, emailNotConfirmed }

class LoginState extends Equatable {
  const new({
    this.email = '',
    this.password = '',
    this.keepSignedIn = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool keepSignedIn;
  final LoginStatus status;
  final String? errorMessage;

  bool get isValid => email.isValidEmail && password.length >= 8;

  LoginState copyWith({
    String? email,
    String? password,
    bool? keepSignedIn,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      keepSignedIn: keepSignedIn ?? this.keepSignedIn,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    keepSignedIn,
    status,
    errorMessage,
  ];
}
