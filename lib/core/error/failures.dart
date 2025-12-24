abstract class Failure {
  String get message;
}

class NotConnectedToInternetError implements Failure {
  @override
  final String message;

  NotConnectedToInternetError({this.message = 'Not connected to the internet'});
}

class APITimeoutError implements Failure {
  @override
  final String message;

  APITimeoutError({this.message = 'API Timeout Error'});
}

class ServerFailure implements Failure {
  @override
  final String message;

  ServerFailure(this.message);
}

class UnexpectedFailure implements Failure {
  @override
  final String message;

  UnexpectedFailure(this.message);
}
