class ServerException implements Exception {
  new([
    this.message = '''
Something went wrong. Please try again.''',
    this.statusCode,
  ]);

  final String message;
  final int? statusCode;
}

class NetworkException implements Exception {
  new([this.message = 'No internet connection.']);

  final String message;
}

class CacheException implements Exception {
  new([this.message = 'Could not read local data.']);

  final String message;
}

class UnauthorizedException implements Exception {
  new([this.message = 'Session expired. Please log in again.']);

  final String message;
}
