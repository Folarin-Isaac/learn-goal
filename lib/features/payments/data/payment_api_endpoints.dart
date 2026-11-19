class PaymentApiEndpoints {
  const new();

  static const String paymentHistory = '/api/v1/Payment/PaymentHistory';
  static const String initialisePayment = '/api/v1/Payment/InitialisePayment';
  static const String subscribeLearnerToClass =
      '/api/v1/Subscription/SubscribeLearnerToClass';

  static String verifyPayment(String reference) =>
      '/api/v1/Payment/VerifyPayment/${Uri.encodeComponent(reference)}';

  static String abandonPayment(String reference) =>
      '/api/v1/Payment/AbandonPayment/${Uri.encodeComponent(reference)}';
}
