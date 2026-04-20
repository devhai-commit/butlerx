import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/fake_auth_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// Toggle to FirebaseAuthRepository once Firebase is configured.
@riverpod
AuthRepository authRepository(Ref ref) {
  final repo = FakeAuthRepository();
  ref.onDispose(repo.dispose);
  return repo;
}

sealed class AuthStatus {
  const AuthStatus();
}

final class AuthLoading extends AuthStatus {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthStatus {
  const AuthAuthenticated(this.profile);
  final UserProfile profile;
}

final class AuthUnauthenticated extends AuthStatus {
  const AuthUnauthenticated();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthStatus build() {
    final repo = ref.watch(authRepositoryProvider);

    // Listen to auth stream — emit unauthenticated immediately if stream
    // produces no value within the first frame (avoids infinite splash).
    final sub = repo.authStateChanges.listen(
      (profile) {
        state = profile != null
            ? AuthAuthenticated(profile)
            : const AuthUnauthenticated();
      },
      onError: (_) => state = const AuthUnauthenticated(),
    );

    ref.onDispose(sub.cancel);

    // Start unauthenticated so the app never hangs on the splash screen.
    return const AuthUnauthenticated();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthLoading();
    try {
      final profile =
          await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      state = AuthAuthenticated(profile);
    } catch (_) {
      state = const AuthUnauthenticated();
      rethrow;
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    state = const AuthLoading();
    try {
      final profile = await ref
          .read(authRepositoryProvider)
          .registerWithEmail(email, password);
      state = AuthAuthenticated(profile);
    } catch (_) {
      state = const AuthUnauthenticated();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final profile =
          await ref.read(authRepositoryProvider).signInWithGoogle();
      state = AuthAuthenticated(profile);
    } catch (_) {
      state = const AuthUnauthenticated();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthUnauthenticated();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await ref.read(authRepositoryProvider).saveProfile(profile);
    state = AuthAuthenticated(profile);
  }
}
