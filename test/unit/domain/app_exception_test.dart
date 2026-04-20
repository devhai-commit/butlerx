import 'package:butlerx/core/errors/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    test('NetworkException has correct default message', () {
      const e = NetworkException();
      expect(e.message, 'Không có kết nối mạng');
    });

    test('UnauthorizedException has correct default message', () {
      const e = UnauthorizedException();
      expect(e.message, 'Phiên đăng nhập đã hết hạn');
    });

    test('ValidationException carries custom message', () {
      const e = ValidationException('Email không hợp lệ');
      expect(e.message, 'Email không hợp lệ');
    });

    test('toString includes type and message', () {
      const e = NetworkException();
      expect(e.toString(), contains('NetworkException'));
      expect(e.toString(), contains('Không có kết nối mạng'));
    });

    test('exceptions are sealed — exhaustive switch compiles', () {
      AppException exception = const NetworkException();
      final result = switch (exception) {
        NetworkException() => 'network',
        UnauthorizedException() => 'auth',
        NotFoundException() => 'notfound',
        ServerException() => 'server',
        ValidationException() => 'validation',
        PermissionException() => 'permission',
      };
      expect(result, 'network');
    });
  });
}
