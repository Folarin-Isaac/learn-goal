import 'package:equatable/equatable.dart';

class PaymentCheckout extends Equatable {
  const new({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  final String authorizationUrl;
  final String accessCode;
  final String reference;

  @override
  List<Object?> get props => [authorizationUrl, accessCode, reference];
}
