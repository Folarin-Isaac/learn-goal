import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory({
    required String learnerId,
    bool forceRefresh = false,
  });

  // Synchronous peek at the last loaded history for this learner, so the
  // page can render it on the first frame instead of flashing a skeleton.
  List<PaymentRecord>? cachedPaymentHistory({required String learnerId});
}
