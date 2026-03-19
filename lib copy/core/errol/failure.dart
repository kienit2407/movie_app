abstract class Failure {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  static String mapError(String message) {
    if (message.contains('already registered')) {
      return 'This account already created. Please choose another email';
    } else if (message.contains('Password should')) {
      return 'Password is quite weak. Please enter a stronger password';
    } else if (message.contains('Invalid login')) {
      return 'Password or email is incorrect. Please try again';
    }
    return 'An error occurred. Please try again or contact support';
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
