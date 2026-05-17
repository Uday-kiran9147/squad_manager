import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? get currentUser;
  String? get currentUserId;
  bool get isAuthenticated;

  Future<UserCredential?> signInWithGoogle();
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password);
  Future<UserCredential> signInAnonymously(String displayName);
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> sendPasswordResetEmail(String email);
}
