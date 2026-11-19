import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/payments/domain/entities/payment_checkout.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';
import 'package:lengoal/features/payments/domain/entities/payment_verification.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory({
    required String learnerId,
    bool forceRefresh = false,
  });

  List<PaymentRecord>? cachedPaymentHistory({required String learnerId});

  Future<Either<Failure, PaymentCheckout>> initialisePayment({
    required String email,
    required String classId,
    required double amount,
    required String learnerId,
  });

  Future<Either<Failure, PaymentVerification>> verifyPayment(String reference);

  Future<Either<Failure, Unit>> abandonPayment(String reference);

  Future<Either<Failure, Unit>> enrollInFreeClass({
    required String learnerId,
    required String learnerEmail,
    required String classId,
  });

  String? pendingReference(String classId);
}
