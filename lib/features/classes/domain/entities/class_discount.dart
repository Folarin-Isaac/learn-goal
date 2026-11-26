import 'package:equatable/equatable.dart';

class ClassDiscount extends Equatable {
  const new({required this.percentage, this.forFirstPeople, this.validUntil});

  final double percentage;

  // Set when the discount is limited to the first N subscribers.
  final int? forFirstPeople;

  // Set when the discount is limited by a deadline.
  final DateTime? validUntil;

  @override
  List<Object?> get props => [percentage, forFirstPeople, validUntil];
}
