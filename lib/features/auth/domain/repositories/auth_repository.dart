import '../entities/user_profile.dart';

abstract interface class AuthRepository {
  Stream<UserProfile?> get authStateChanges;

  Future<UserProfile> signInWithEmail(String email, String password);
  Future<UserProfile> registerWithEmail(String email, String password);
  Future<UserProfile> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);

  Future<UserProfile?> getCurrentProfile();
  Future<void> saveProfile(UserProfile profile);
}
