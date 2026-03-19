abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}
class BadRequestException extends AppException {
  const  BadRequestException(super.message);
}
class ServerException extends AppException {
  const ServerException(super.message);
}
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}