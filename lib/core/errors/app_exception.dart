sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Không có kết nối mạng']);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Phiên đăng nhập đã hết hạn']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Không tìm thấy dữ liệu']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Lỗi máy chủ']);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class PermissionException extends AppException {
  const PermissionException(super.message);
}
