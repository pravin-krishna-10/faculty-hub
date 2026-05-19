import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Auth calls for FacultyHub.
///
/// Uses email + password authentication:
/// - New users: createAccount(email, password) → account created and signed in
/// - Returning users: signIn(email, password) → signed in
/// - Anyone: signOut() → signed out
/// - Anyone: sendPasswordResetEmail(email) → Firebase emails a reset link
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Current signed-in user, or null if no one is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream that emits whenever the auth state changes.
  /// UI listens to this to rebuild between LoginScreen and HomeScreen.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Create a new account with email + password.
  /// Throws FirebaseAuthException on failure.
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in an existing user with email + password.
  /// Throws FirebaseAuthException on failure.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Send a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Sign the current user out.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
