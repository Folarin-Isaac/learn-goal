import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';
import 'package:lengoal/features/payments/domain/repositories/payment_repository.dart';

class GetPaymentHistoryUseCase {
  new(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, List<PaymentRecord>>> call({
    required String learnerId,
    bool forceRefresh = false,
  }) {
    return _repository.getPaymentHistory(
      learnerId: learnerId,
      forceRefresh: forceRefresh,
    );
  }

  List<PaymentRecord>? cached({required String learnerId}) =>
      _repository.cachedPaymentHistory(learnerId: learnerId);
}
