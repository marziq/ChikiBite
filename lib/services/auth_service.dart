import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Check if email is verified
    final user = credential.user;
    if (user != null && !user.emailVerified) {
      // Reload user to get the latest email verification status
      await user.reload();
      if (!user.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before signing in. Check your inbox for the verification link.',
        );
      }
    }
    
    // Reload user to get latest display name and other data
    if (user != null) {
      await user.reload();
    }
    
    return credential;
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
      case 'email-not-verified':
        return 'Please verify your email before signing in. Check your inbox for the verification link.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
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
