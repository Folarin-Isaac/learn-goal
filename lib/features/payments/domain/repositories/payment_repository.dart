import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory({
    required String learnerId,
  });
}
