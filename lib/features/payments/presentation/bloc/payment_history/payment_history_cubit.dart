import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';
import 'package:lengoal/features/payments/domain/usecases/get_payment_history_usecase.dart';
import 'package:lengoal/features/profile/domain/usecases/get_learner_profile_usecase.dart';

part 'payment_history_state.dart';

// Lists only successful payments: the history also records failed and
// abandoned attempts, which aren't subscriptions and would read as money
// the learner spent.
class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  new({
    required this._getLearnerProfileUseCase,
    required this._getPaymentHistoryUseCase,
  }) : super(const PaymentHistoryState());

  final GetLearnerProfileUseCase _getLearnerProfileUseCase;
  final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: state.status == PaymentHistoryStatus.loaded
            ? PaymentHistoryStatus.loaded
            : PaymentHistoryStatus.loading,
      ),
    );
    final profileResult = await _getLearnerProfileUseCase();
    final profile = profileResult.getRight().toNullable();
    if (profile == null) {
      emit(
        state.copyWith(
          status: PaymentHistoryStatus.failure,
          errorMessage: profileResult.getLeft().toNullable()?.message,
        ),
      );
      return;
    }
    if (profile.learnerId.isEmpty) {
      emit(const PaymentHistoryState(status: PaymentHistoryStatus.loaded));
      return;
    }
    final result = await _getPaymentHistoryUseCase(
      learnerId: profile.learnerId,
    );
    result.match(
      (failure) => emit(
        state.copyWith(
          status: state.status == PaymentHistoryStatus.loaded
              ? PaymentHistoryStatus.loaded
              : PaymentHistoryStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (records) {
        final epoch = DateTime.fromMillisecondsSinceEpoch(0);
        final paid = records.where((r) => r.isSuccessful).toList()
          ..sort(
            (a, b) =>
                (b.paymentDate ?? epoch).compareTo(a.paymentDate ?? epoch),
          );
        emit(
          PaymentHistoryState(
            status: PaymentHistoryStatus.loaded,
            records: paid,
          ),
        );
      },
    );
  }
}
