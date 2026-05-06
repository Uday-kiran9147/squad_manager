import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await _googleSignIn.initialize(
        clientId:
            "259598366990-a2cbfdmsrb4imum25pjugcfkbn64edfv.apps.googleusercontent.com",
      );
      _googleSignInInitialized = true;
    }
  }

  /// Listen to authentication state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Get currently logged-in user
  User? get currentUser => _auth.currentUser;

  /// Get current user UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Private helper to convert any exception to [FirebaseAuthException]
  FirebaseAuthException _toAuthException(Object e) {
    if (e is FirebaseAuthException) return e;
    return FirebaseAuthException(code: 'unknown', message: e.toString());
  }

  /// Update user data in Firestore
  Future<void> _updateUserData(User user) async {
    final userRef = _firestore.collection('squadusers').doc(user.uid);

    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastSignIn': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Sign in with Google (OAuth)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final authz = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      final credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _updateUserData(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      throw _toAuthException(e);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _updateUserData(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      throw _toAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _updateUserData(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      throw _toAuthException(e);
    }
  }

  /// Sign in anonymously (for guest users)
  Future<UserCredential> signInAnonymously(String displayName) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        // Refresh the user object after updating display name
        await userCredential.user!.reload();
        final updatedUser = _auth.currentUser;
        if (updatedUser != null) {
          // Explicitly pass displayName in case user.displayName hasn't
          // propagated yet after reload — avoids null being written to Firestore.
          await _updateUserDataWithName(updatedUser, displayName);
        }
      }
      return userCredential;
    } catch (e) {
      throw _toAuthException(e);
    }
  }

  /// Internal helper that writes user data with an explicit override for displayName.
  Future<void> _updateUserDataWithName(User user, String displayName) async {
    final userRef = _firestore.collection('squadusers').doc(user.uid);
    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? displayName,
      'photoURL': user.photoURL,
      'lastSignIn': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw _toAuthException(e);
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final uid = currentUser?.uid;
      await currentUser?.delete();
      if (uid != null) {
        await _firestore.collection('squadusers').doc(uid).delete();
      }
    } catch (e) {
      throw _toAuthException(e);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _toAuthException(e);
    }
  }
}
