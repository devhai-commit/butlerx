import 'dart:async';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Fake auth repository for local development/UI testing.
/// Replace with FirebaseAuthRepository for production.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  final _controller = StreamController<UserProfile?>.broadcast();
  UserProfile? _currentUser;

  static const _fakeDelay = Duration(milliseconds: 600);

  @override
  Stream<UserProfile?> get authStateChanges {
    // Emit current state immediately on subscribe
    return _controller.stream;
  }

  @override
  Future<UserProfile> signInWithEmail(String email, String password) async {
    await Future.delayed(_fakeDelay);
    if (password.length < 6) {
      throw const ValidationException('Mật khẩu phải có ít nhất 6 ký tự');
    }
    final profile = _makeProfile(email);
    _currentUser = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<UserProfile> registerWithEmail(String email, String password) async {
    await Future.delayed(_fakeDelay);
    final profile = _makeProfile(email, onboardingComplete: false);
    _currentUser = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    await Future.delayed(_fakeDelay);
    final profile = _makeProfile('google@example.com');
    _currentUser = profile;
    _controller.add(profile);
    return profile;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(_fakeDelay);
  }

  @override
  Future<UserProfile?> getCurrentProfile() async => _currentUser;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = profile;
    _controller.add(profile);
  }

  UserProfile _makeProfile(String email, {bool onboardingComplete = true}) =>
      UserProfile(
        uid: 'fake-uid-${email.hashCode}',
        email: email,
        displayName: 'Người dùng thử nghiệm',
        birthdate: DateTime(1990, 6, 15),
        gender: Gender.other,
        addressTitle: AddressTitle.anh,
        personalityTag: PersonalityTag.warm,
        onboardingComplete: onboardingComplete,
      );

  void dispose() => _controller.close();
}
