import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/payments/data/models/payment_record_model.dart';
import 'package:lengoal/features/payments/data/payment_api_endpoints.dart';
import 'package:lengoal/features/payments/domain/entities/payment_checkout.dart';
import 'package:lengoal/features/payments/domain/entities/payment_verification.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentRecordModel>> getPaymentHistory({
    required String learnerId,
  });

  Future<PaymentCheckout> initialisePayment({
    required String email,
    required String classId,
    required double amount,
    required String learnerId,
  });

  Future<PaymentVerification> verifyPayment(String reference);

  Future<void> abandonPayment(String reference);

  Future<void> enrollInFreeClass({
    required String learnerId,
    required String learnerEmail,
    required String classId,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  static const String _genericError = 'Something went wrong. Please try again.';

  @override
  Future<List<PaymentRecordModel>> getPaymentHistory({
    required String learnerId,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        PaymentApiEndpoints.paymentHistory,
        queryParameters: {'learnerId': learnerId},
      );
      final data = _checkSucceeded(response.data!)['data'] as List<dynamic>?;
      return (data ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PaymentRecordModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Body matches the web's request (InitialliseTransactionCommand in the
  // API spec); amount is in naira, as on the class.
  @override
  Future<PaymentCheckout> initialisePayment({
    required String email,
    required String classId,
    required double amount,
    required String learnerId,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        PaymentApiEndpoints.initialisePayment,
        data: {
          'email': email,
          'classId': classId,
          'amount': amount,
          'learnerId': learnerId,
        },
      );
      final data = _checkSucceeded(response.data!)['data'];
      if (data is! Map<String, dynamic>) throw ServerException();
      final url = _nonEmpty(data['authorizationUrl']);
      final reference = _nonEmpty(data['reference']);
      if (url == null || reference == null) {
        throw ServerException('Could not start the payment. Try again.');
      }
      return PaymentCheckout(
        authorizationUrl: url,
        accessCode: _nonEmpty(data['accessCode']) ?? '',
        reference: reference,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<PaymentVerification> verifyPayment(String reference) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        PaymentApiEndpoints.verifyPayment(reference),
      );
      final data = _checkSucceeded(response.data!)['data'];
      if (data is! Map<String, dynamic>) throw ServerException();
      return PaymentVerification(
        reference: _nonEmpty(data['transactionReference']) ?? reference,
        paymentStatus: int.tryParse('${data['paymentStatus']}') ?? 0,
        gatewayStatus: _nonEmpty(data['gatewayStatus']),
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> abandonPayment(String reference) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        PaymentApiEndpoints.abandonPayment(reference),
      );
      final body = response.data;
      if (body != null) _checkSucceeded(body);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Same body as the web's free "Join Class": no payment, so
  // transReference and amount are null. `data` comes back null.
  @override
  Future<void> enrollInFreeClass({
    required String learnerId,
    required String learnerEmail,
    required String classId,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        PaymentApiEndpoints.subscribeLearnerToClass,
        data: {
          'learnerId': learnerId,
          'learnerEmail': learnerEmail,
          'classId': classId,
          'transReference': null,
          'amount': null,
        },
      );
      final body = response.data;
      if (body != null) _checkSucceeded(body);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Map<String, dynamic> _checkSucceeded(Map<String, dynamic> body) {
    if (body['succeeded'] == false) {
      throw ServerException(_nonEmpty(body['message']) ?? _genericError);
    }
    return body;
  }

  String? _nonEmpty(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Exception _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) return UnauthorizedException();
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? data['message'] as String?
        : null;
    return ServerException(message ?? _genericError, e.response?.statusCode);
  }
}
