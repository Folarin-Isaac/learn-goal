part of 'payment_history_cubit.dart';

enum PaymentHistoryStatus { initial, loading, loaded, failure }

class PaymentHistoryState extends Equatable {
  const new({
    this.status = PaymentHistoryStatus.initial,
    this.records = const [],
    this.errorMessage,
  });

  final PaymentHistoryStatus status;
  final List<PaymentRecord> records;
  final String? errorMessage;

  PaymentHistoryState copyWith({
    PaymentHistoryStatus? status,
    String? errorMessage,
  }) {
    return PaymentHistoryState(
      status: status ?? this.status,
      records: records,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, records, errorMessage];
}
