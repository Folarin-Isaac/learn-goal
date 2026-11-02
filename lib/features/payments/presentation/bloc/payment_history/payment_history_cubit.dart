import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';
import 'package:lengoal/features/payments/domain/usecases/get_payment_history_usecase.dart';
import 'package:lengoal/features/profile/domain/usecases/get_learner_profile_usecase.dart';

part 'payment_history_state.dart';

// Lists only successful payments: the history also records failed and
// abandoned attempts, which aren't subscriptions and would read as money
// the learner spent. Starts from the repository's cached history when
// there is one, so reopening the page renders immediately.
class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  new({
    required GetLearnerProfileUseCase getLearnerProfileUseCase,
    required GetPaymentHistoryUseCase getPaymentHistoryUseCase,
  }) : _getLearnerProfileUseCase = getLearnerProfileUseCase,
       _getPaymentHistoryUseCase = getPaymentHistoryUseCase,
       super(_initialState(getLearnerProfileUseCase, getPaymentHistoryUseCase));

  final GetLearnerProfileUseCase _getLearnerProfileUseCase;
  final GetPaymentHistoryUseCase _getPaymentHistoryUseCase;

  static PaymentHistoryState _initialState(
    GetLearnerProfileUseCase profiles,
    GetPaymentHistoryUseCase payments,
  ) {
    final learnerId = profiles.cached?.learnerId;
    if (learnerId == null || learnerId.isEmpty) {
      return const PaymentHistoryState();
    }
    final cached = payments.cached(learnerId: learnerId);
    if (cached == null) return const PaymentHistoryState();
    return PaymentHistoryState(
      status: PaymentHistoryStatus.loaded,
      records: _paidNewestFirst(cached),
    );
  }

  static List<PaymentRecord> _paidNewestFirst(List<PaymentRecord> records) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    return records.where((r) => r.isSuccessful).toList()..sort(
      (a, b) => (b.paymentDate ?? epoch).compareTo(a.paymentDate ?? epoch),
    );
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (state.status != PaymentHistoryStatus.loaded) {
      emit(state.copyWith(status: PaymentHistoryStatus.loading));
    }
    final profileResult = await _getLearnerProfileUseCase();
    final profile = profileResult.getRight().toNullable();
    if (profile == null) {
      emit(
        state.copyWith(
          status: state.status == PaymentHistoryStatus.loaded
              ? PaymentHistoryStatus.loaded
              : PaymentHistoryStatus.failure,
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
      forceRefresh: forceRefresh,
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
      (records) => emit(
        PaymentHistoryState(
          status: PaymentHistoryStatus.loaded,
          records: _paidNewestFirst(records),
        ),
      ),
    );
  }
}
