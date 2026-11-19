import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/features/payments/domain/entities/payment_checkout.dart';
import 'package:lengoal/features/payments/domain/entities/payment_verification.dart';
import 'package:lengoal/features/payments/domain/usecases/class_payment_usecases.dart';
import 'package:lengoal/features/profile/domain/usecases/get_learner_profile_usecase.dart';

// ready → starting (InitialisePayment) → checkout (Paystack page open)
// → verifying (VerifyPayment) → paid. Anything short of a verified
// payment returns to ready with an issue for the page to explain.
enum ClassPaymentPhase { ready, starting, checkout, verifying, paid }

enum ClassPaymentIssue {
  // Learner closed or cancelled checkout without paying.
  notCompleted,
  // Paystack reported the payment as failed.
  declined,
  // Couldn't reach a verdict (network, or Paystack still processing). The
  // reference is kept, so the next Pay checks it before charging again.
  unconfirmed,
  // The server refused to start the payment; message holds its reason.
  failed,
}

class ClassPaymentState extends Equatable {
  const new({
    this.phase = ClassPaymentPhase.ready,
    this.checkout,
    this.issue,
    this.message,
    this.issueCount = 0,
  });

  final ClassPaymentPhase phase;
  final PaymentCheckout? checkout;
  final ClassPaymentIssue? issue;
  final String? message;

  // Bumps on every issue so the same one twice still shows a message.
  final int issueCount;

  bool get isBusy =>
      phase == ClassPaymentPhase.starting ||
      phase == ClassPaymentPhase.verifying;

  ClassPaymentState to(ClassPaymentPhase phase, {PaymentCheckout? checkout}) {
    return ClassPaymentState(
      phase: phase,
      checkout: checkout ?? this.checkout,
      issue: issue,
      message: message,
      issueCount: issueCount,
    );
  }

  ClassPaymentState withIssue(ClassPaymentIssue issue, {String? message}) {
    return ClassPaymentState(
      issue: issue,
      message: message,
      issueCount: issueCount + 1,
    );
  }

  @override
  List<Object?> get props => [phase, checkout, issue, message, issueCount];
}

class ClassPaymentCubit extends Cubit<ClassPaymentState> {
  new({
    required this.classId,
    required this.amount,
    required this._getLearnerProfile,
    required this._initialisePayment,
    required this._verifyPayment,
    required this._abandonPayment,
  }) : super(const ClassPaymentState());

  final String classId;
  final double amount;
  final GetLearnerProfileUseCase _getLearnerProfile;
  final InitialisePaymentUseCase _initialisePayment;
  final VerifyPaymentUseCase _verifyPayment;
  final AbandonPaymentUseCase _abandonPayment;

  static const Set<String> _stillProcessing = {
    'ongoing',
    'pending',
    'processing',
    'queued',
  };

  Future<void> pay() async {
    if (state.phase != ClassPaymentPhase.ready) return;
    emit(state.to(ClassPaymentPhase.starting));

    final pending = _initialisePayment.pendingReference(classId);
    if (pending != null) {
      final result = await _verifyPayment(pending);
      if (isClosed) return;
      final verification = result.getRight().toNullable();
      if (verification != null && verification.isSuccessful) {
        emit(state.to(ClassPaymentPhase.paid));
        return;
      }
      if (result.getLeft().toNullable() is NetworkFailure ||
          _isProcessing(verification)) {
        emit(state.withIssue(ClassPaymentIssue.unconfirmed));
        return;
      }
      unawaited(_abandonPayment(pending));
    }

    final profileResult = await _getLearnerProfile();
    if (isClosed) return;
    final profile = profileResult.getRight().toNullable();
    if (profile == null || profile.learnerId.isEmpty || profile.email.isEmpty) {
      emit(
        state.withIssue(
          ClassPaymentIssue.failed,
          message: profileResult.getLeft().toNullable()?.message,
        ),
      );
      return;
    }

    final result = await _initialisePayment(
      email: profile.email,
      classId: classId,
      amount: amount,
      learnerId: profile.learnerId,
    );
    if (isClosed) return;
    result.match(
      (failure) => emit(
        state.withIssue(ClassPaymentIssue.failed, message: failure.message),
      ),
      (checkout) =>
          emit(state.to(ClassPaymentPhase.checkout, checkout: checkout)),
    );
  }

  // Called when the checkout page is done, whether Paystack sent the
  // learner back (completed) or they closed it. Always verifies: a learner
  // can pay and then tap close before the redirect.
  Future<void> checkoutClosed({required bool cancelled}) async {
    final reference = state.checkout?.reference;
    if (state.phase != ClassPaymentPhase.checkout || reference == null) {
      return;
    }
    emit(state.to(ClassPaymentPhase.verifying));
    final result = await _verifyPayment(reference);
    if (isClosed) return;
    final verification = result.getRight().toNullable();
    if (verification == null || _isProcessing(verification)) {
      emit(state.withIssue(ClassPaymentIssue.unconfirmed));
      return;
    }
    if (verification.isSuccessful) {
      emit(state.to(ClassPaymentPhase.paid));
      return;
    }
    unawaited(_abandonPayment(reference));
    emit(
      state.withIssue(
        cancelled ? ClassPaymentIssue.notCompleted : ClassPaymentIssue.declined,
      ),
    );
  }

  bool _isProcessing(PaymentVerification? verification) {
    final gateway = verification?.gatewayStatus?.toLowerCase();
    return gateway != null && _stillProcessing.contains(gateway);
  }
}
