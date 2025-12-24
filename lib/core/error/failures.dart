abstract class Failure {
  String get message;
}

class NotConnectedToInternetError implements Failure {

  NotConnectedToInternetError({this.message = 'Not connected to the internet'});
  @override
  final String message;
}

class APITimeoutError implements Failure {

  APITimeoutError({this.message = 'API Timeout Error'});
  @override
  final String message;
}

class ServerFailure implements Failure {

  ServerFailure(this.message);
  @override
  final String message;
}

class UnexpectedFailure implements Failure {

  UnexpectedFailure(this.message);
  @override
  final String message;
}
