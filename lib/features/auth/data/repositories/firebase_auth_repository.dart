import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

final class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Stream<UserProfile?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchProfile(user.uid);
    });
  }

  @override
  Future<UserProfile> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final profile = await _fetchProfile(user.uid);
      return profile ?? _minimalProfile(user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<UserProfile> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      final profile = _minimalProfile(user);
      await saveProfile(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw const UnauthorizedException('Đăng nhập Google bị hủy');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final existing = await _fetchProfile(user.uid);
      if (existing != null) return existing;

      final profile = _minimalProfile(user, displayName: googleUser.displayName);
      await saveProfile(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.uid);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toJson(), SetOptions(merge: true));
  }

  Future<UserProfile?> _fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromJson(doc.data()!);
  }

  UserProfile _minimalProfile(User user, {String? displayName}) => UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName ?? '',
        birthdate: DateTime(1990),
        gender: Gender.other,
        addressTitle: AddressTitle.anh,
        personalityTag: PersonalityTag.warm,
        onboardingComplete: false,
      );

  AppException _mapFirebaseError(FirebaseAuthException e) => switch (e.code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          const ValidationException('Email hoặc mật khẩu không đúng'),
        'email-already-in-use' =>
          const ValidationException('Email này đã được sử dụng'),
        'weak-password' =>
          const ValidationException('Mật khẩu quá yếu, cần ít nhất 6 ký tự'),
        'invalid-email' =>
          const ValidationException('Địa chỉ email không hợp lệ'),
        'network-request-failed' => const NetworkException(),
        'too-many-requests' =>
          const ValidationException('Quá nhiều lần thử. Vui lòng thử lại sau'),
        _ => ServerException(e.message ?? 'Lỗi xác thực'),
      };
}
