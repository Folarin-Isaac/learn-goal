import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:lengoal/features/payments/domain/entities/payment_checkout.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';
import 'package:lengoal/features/payments/domain/entities/payment_verification.dart';
import 'package:lengoal/features/payments/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  new({required this._remoteDataSource, required this._networkInfo});

  final PaymentRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  // History only changes when the learner pays, so a short-lived memory
  // cache avoids refetching on every visit. Keyed by learner, so another
  // account on the same device never sees these records.
  static const Duration _freshFor = Duration(minutes: 3);
  final Map<String, ({List<PaymentRecord> records, DateTime at})> _cache = {};

  // classId → reference of a checkout not yet verified or abandoned.
  // Memory only: it covers the risky window (checkout closed, verify lost
  // to a bad network) for the life of the app session.
  final Map<String, String> _pending = {};
  final Map<String, String> _pendingClassByReference = {};

  @override
  List<PaymentRecord>? cachedPaymentHistory({required String learnerId}) =>
      _cache[learnerId]?.records;

  @override
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory({
    required String learnerId,
    bool forceRefresh = false,
  }) async {
    final cached = _cache[learnerId];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.at) < _freshFor) {
      return right(cached.records);
    }
    return await _guard(() async {
      final records = await _remoteDataSource.getPaymentHistory(
        learnerId: learnerId,
      );
      _cache[learnerId] = (records: records, at: DateTime.now());
      return records;
    });
  }

  @override
  Future<Either<Failure, PaymentCheckout>> initialisePayment({
    required String email,
    required String classId,
    required double amount,
    required String learnerId,
  }) {
    return _guard(() async {
      final checkout = await _remoteDataSource.initialisePayment(
        email: email,
        classId: classId,
        amount: amount,
        learnerId: learnerId,
      );
      _pending[classId] = checkout.reference;
      _pendingClassByReference[checkout.reference] = classId;
      return checkout;
    });
  }

  @override
  Future<Either<Failure, PaymentVerification>> verifyPayment(String reference) {
    return _guard(() async {
      final verification = await _remoteDataSource.verifyPayment(reference);
      if (verification.isSuccessful) {
        _settle(reference);
        _cache.clear();
      }
      return verification;
    });
  }

  @override
  Future<Either<Failure, Unit>> abandonPayment(String reference) {
    return _guard(() async {
      await _remoteDataSource.abandonPayment(reference);
      _settle(reference);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> enrollInFreeClass({
    required String learnerId,
    required String learnerEmail,
    required String classId,
  }) {
    return _guard(() async {
      await _remoteDataSource.enrollInFreeClass(
        learnerId: learnerId,
        learnerEmail: learnerEmail,
        classId: classId,
      );
      return unit;
    });
  }

  @override
  String? pendingReference(String classId) => _pending[classId];

  void _settle(String reference) {
    final classId = _pendingClassByReference.remove(reference);
    if (classId != null) _pending.remove(classId);
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      return right(await action());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
