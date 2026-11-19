import 'package:equatable/equatable.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';

class PaymentVerification extends Equatable {
  const new({
    required this.reference,
    required this.paymentStatus,
    this.gatewayStatus,
  });

  final String reference;
  final int paymentStatus;

  // Paystack's own word for it, e.g. "success", "abandoned", "failed".
  final String? gatewayStatus;

  bool get isSuccessful =>
      paymentStatus == PaymentRecord.successfulStatus ||
      gatewayStatus?.toLowerCase() == 'success';

  @override
  List<Object?> get props => [reference, paymentStatus, gatewayStatus];
}
