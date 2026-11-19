import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/payments/domain/entities/payment_checkout.dart';
import 'package:lengoal/features/payments/domain/entities/payment_verification.dart';
import 'package:lengoal/features/payments/domain/repositories/payment_repository.dart';
import 'package:lengoal/features/profile/domain/usecases/get_learner_profile_usecase.dart';

class InitialisePaymentUseCase {
  new(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, PaymentCheckout>> call({
    required String email,
    required String classId,
    required double amount,
    required String learnerId,
  }) {
    return _repository.initialisePayment(
      email: email,
      classId: classId,
      amount: amount,
      learnerId: learnerId,
    );
  }

  String? pendingReference(String classId) =>
      _repository.pendingReference(classId);
}

class VerifyPaymentUseCase {
  new(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, PaymentVerification>> call(String reference) {
    return _repository.verifyPayment(reference);
  }
}

class EnrollInFreeClassUseCase {
  new(this._repository, this._getLearnerProfile);

  final PaymentRepository _repository;
  final GetLearnerProfileUseCase _getLearnerProfile;

  Future<Either<Failure, Unit>> call(String classId) async {
    final profileResult = await _getLearnerProfile();
    final profile = profileResult.getRight().toNullable();
    if (profile == null) {
      return Left(
        profileResult.getLeft().toNullable() ?? const ServerFailure(),
      );
    }
    if (profile.learnerId.isEmpty || profile.email.isEmpty) {
      return const Left(ServerFailure());
    }
    return await _repository.enrollInFreeClass(
      learnerId: profile.learnerId,
      learnerEmail: profile.email,
      classId: classId,
    );
  }
}

class AbandonPaymentUseCase {
  new(this._repository);

  final PaymentRepository _repository;

  Future<Either<Failure, Unit>> call(String reference) {
    return _repository.abandonPayment(reference);
  }
}
