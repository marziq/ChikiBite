import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email is already registered. Please try signing in or use a different email.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Registration is currently unavailable. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Registration failed: ${e.message ?? e.toString()}';
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
    }
  }
}
