class ChatApiEndpoints {
  const new();

  static String messages(String classId) =>
      '/api/v1/ClassChat/classes/$classId/chat/messages';

  static String message(String classId, String messageId) =>
      '${messages(classId)}/$messageId';
}
