import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/features/payments/data/models/payment_record_model.dart';
import 'package:lengoal/features/payments/data/payment_api_endpoints.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentRecordModel>> getPaymentHistory({
    required String learnerId,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  new(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PaymentRecordModel>> getPaymentHistory({
    required String learnerId,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        PaymentApiEndpoints.paymentHistory,
        queryParameters: {'learnerId': learnerId},
      );
      final body = response.data!;
      if (body['succeeded'] == false) {
        throw ServerException(
          body['message'] as String? ??
              'Something went wrong. Please try again.',
        );
      }
      final data = body['data'] as List<dynamic>? ?? const [];
      return data
          .cast<Map<String, dynamic>>()
          .map(PaymentRecordModel.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw NetworkException();
      }
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? data['message'] as String?
          : null;
      throw ServerException(
        message ?? 'Something went wrong. Please try again.',
        e.response?.statusCode,
      );
    }
  }
}
