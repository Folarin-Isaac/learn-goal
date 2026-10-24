import 'dart:convert';

class JwtDecoder {
  const new();

  static Map<String, dynamic> decodePayload(String token) {
    final segments = token.split('.');
    if (segments.length != 3) return const {};
    final normalized = base64Url.normalize(segments[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(payload) as Map<String, dynamic>;
  }
}
