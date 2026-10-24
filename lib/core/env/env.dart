import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { development, staging, production }

class Env {
  const new();

  static Future<void> load(Flavor flavor) {
    final fileName = switch (flavor) {
      Flavor.development => '.env.development',
      Flavor.staging => '.env.staging',
      Flavor.production => '.env.production',
    };
    return dotenv.load(fileName: fileName);
  }

  static String get baseUrl => _require('BASE_URL');
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  static String _require(String key) {
    final value = dotenv.env[key];
    assert(value != null && value.isNotEmpty, 'Missing env key: $key');
    return value ?? '';
  }
}
