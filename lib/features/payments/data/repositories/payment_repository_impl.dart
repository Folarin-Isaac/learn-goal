import 'package:fpdart/fpdart.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/error/failures.dart';
import 'package:lengoal/core/network/network_info.dart';
import 'package:lengoal/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:lengoal/features/payments/domain/entities/payment_record.dart';
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
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final records = await _remoteDataSource.getPaymentHistory(
        learnerId: learnerId,
      );
      _cache[learnerId] = (records: records, at: DateTime.now());
      return right(records);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
