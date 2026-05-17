abstract class Failure {
  final String message;
  final dynamic originalError;

  const Failure(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'A server error occurred', dynamic error]) 
      : super(message, error);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Please check your internet connection', dynamic error]) 
      : super(message, error);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, [dynamic error]) : super(message, error);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed', dynamic error]) 
      : super(message, error);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred', dynamic error]) 
      : super(message, error);
}
