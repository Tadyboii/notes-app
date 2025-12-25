class ServerException implements Exception {

  const ServerException(this.message, this.statusCode);
  final String? message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (Status code: $statusCode)';
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache Error']);
  final String? message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No Internet Connection']);
  final String? message;

  @override
  String toString() => 'NetworkException: $message';
}

