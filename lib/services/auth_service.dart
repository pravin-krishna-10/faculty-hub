import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Auth calls for FacultyHub.
///
/// Uses email-link (passwordless) authentication:
/// 1. User enters their email
/// 2. We call sendSignInLink() — Firebase sends a magic-link email
/// 3. User clicks the link in their email
/// 4. The link opens our app and we call signInWithEmailLink()
/// 5. User is now authenticated
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Current signed-in user, or null if no one is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream that emits whenever the auth state changes
  /// (sign-in, sign-out, etc.). UI listens to this to rebuild.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sends a magic sign-in link to the given email.
  ///
  /// Throws [FirebaseAuthException] on failure (invalid email, network, etc.)
  Future<void> sendSignInLink(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      // The URL that the email link will redirect to.
      // For dev (Chrome on localhost), this is our local app.
      // For production, this would be our app's domain.
      url: _getEmailLinkRedirectUrl(),

      // Must be true for email-link auth.
      handleCodeInApp: true,

      // iOS-specific (we'll configure properly when we add iOS)
      iOSBundleId: 'com.facultyhub.facultyHub',

      // Android-specific (we'll configure properly when we add Android)
      androidPackageName: 'com.facultyhub.faculty_hub',
      androidInstallApp: true,
      androidMinimumVersion: '1',
    );

    await _firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  /// Returns true if the given link is a valid Firebase sign-in link.
  /// Used when the app receives a deep link to check if it's a sign-in link.
  bool isSignInLink(String link) {
    return _firebaseAuth.isSignInWithEmailLink(link);
  }

  /// Completes the sign-in process using the email and the link clicked
  /// from the email.
  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    return await _firebaseAuth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Determines the URL that Firebase should redirect to after the user
  /// clicks the magic link in their email.
  ///
  /// In dev mode (web on localhost), this is the current page URL.
  /// In production, this would be your app's deep link or production URL.
  String _getEmailLinkRedirectUrl() {
    if (kIsWeb) {
      // For web dev: use the current page's origin (e.g. http://localhost:5000)
      // We'll set this properly once we fix the port number.
      // For now, hardcoding the standard Flutter web dev port.
      return 'http://localhost:5000';
    }

    // For mobile (later), this would be a custom deep link scheme like:
    // return 'https://facultyhub.page.link/email-signin';
    return 'http://localhost:5000';
  }
}
