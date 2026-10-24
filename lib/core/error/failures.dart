import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const new(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const new([super.message = 'Something went wrong. Please try again.']);
}

class NetworkFailure extends Failure {
  const new([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const new([super.message = 'Could not read local data.']);
}

class ValidationFailure extends Failure {
  const new(super.message);
}

class UnauthorizedFailure extends Failure {
  const new([super.message = 'Session expired. Please log in again.']);
}

// Login on an unconfirmed account — API returns a specific 400 message
// so the repository can route back into the OTP flow, not a dead end.
class UnconfirmedEmailFailure extends Failure {
  const new({required this.email, String message = 'Please confirm your email'})
    : super(message);

  final String email;

  @override
  List<Object?> get props => [message, email];
}
