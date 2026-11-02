import 'package:lengoal/features/payments/domain/entities/payment_record.dart';

class PaymentRecordModel extends PaymentRecord {
  const new({
    required super.id,
    required super.classId,
    required super.cohortName,
    required super.amount,
    required super.status,
    super.educatorName,
    super.educatorImageUrl,
    super.paymentDate,
    super.reference,
  });

  factory fromJson(Map<String, dynamic> json) {
    return PaymentRecordModel(
      id: json['id'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      cohortName: json['cohortName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['paymentStatus'] as int? ?? 0,
      educatorName: json['educatorName'] as String?,
      educatorImageUrl: json['educatorImageUrl'] as String?,
      paymentDate: DateTime.tryParse(json['paymentDate'] as String? ?? ''),
      reference: json['transactionReference'] as String?,
    );
  }
}
