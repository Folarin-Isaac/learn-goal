import 'package:equatable/equatable.dart';

class PaymentRecord extends Equatable {
  const new({
    required this.id,
    required this.classId,
    required this.cohortName,
    required this.amount,
    required this.status,
    this.educatorName,
    this.educatorImageUrl,
    this.paymentDate,
    this.reference,
  });

  // Provisional: 3 matches every payment that produced a subscription in
  // the test data. The backend hasn't documented the other codes (2 and 6
  // seen) yet — update here once they confirm.
  static const int successfulStatus = 3;

  final String id;
  final String classId;
  final String cohortName;
  final double amount;
  final int status;
  final String? educatorName;
  final String? educatorImageUrl;
  final DateTime? paymentDate;
  final String? reference;

  bool get isSuccessful => status == successfulStatus;

  @override
  List<Object?> get props => [
    id,
    classId,
    cohortName,
    amount,
    status,
    educatorName,
    educatorImageUrl,
    paymentDate,
    reference,
  ];
}
