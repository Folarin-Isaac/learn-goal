import 'package:equatable/equatable.dart';

class ClassReferral extends Equatable {
  const new({required this.referralCode, required this.referralLink});

  final String referralCode;
  final String referralLink;

  @override
  List<Object?> get props => [referralCode, referralLink];
}
