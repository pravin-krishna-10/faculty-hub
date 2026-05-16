import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps Firebase Auth calls for FacultyHub.
///
/// Uses email-link (passwordless) authentication:
/// 1. User enters their email → we save it locally and call sendSignInLink()
/// 2. Firebase sends a magic-link email
/// 3. User clicks the link in their email → returns to our app
/// 4. We retrieve the saved email and call signInWithEmailLink()
/// 5. User is now authenticated
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Key used to store the pending sign-in email in local storage.
  static const String _pendingEmailKey = 'pending_signin_email';

  /// Current signed-in user, or null if no one is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream that emits whenever the auth state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sends a magic sign-in link to the given email AND saves the email
  /// locally so we can retrieve it when the user returns after clicking
  /// the link.
  Future<void> sendSignInLink(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: _getEmailLinkRedirectUrl(),
      handleCodeInApp: true,
      iOSBundleId: 'com.facultyhub.facultyHub',
      androidPackageName: 'com.facultyhub.faculty_hub',
      androidInstallApp: true,
      androidMinimumVersion: '1',
    );

    await _firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, email);

    final saved = prefs.getString(_pendingEmailKey);
  }

  /// Retrieves the email saved before the user was sent the magic link.
  /// Returns null if no email is pending.
  Future<String?> getPendingSignInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_pendingEmailKey);

    return email;
  }

  /// Clears the pending sign-in email from local storage.
  /// Called after successful sign-in or to cancel a pending flow.
  Future<void> clearPendingSignInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingEmailKey);
  }

  /// Returns true if the given link is a valid Firebase sign-in link.
  bool isSignInLink(String link) {
    return _firebaseAuth.isSignInWithEmailLink(link);
  }

  /// Completes the sign-in process using the email and the link clicked
  /// from the email.
  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailLink(
      email: email,
      emailLink: emailLink,
    );
    // Clean up the pending email after successful sign-in.
    await clearPendingSignInEmail();
    return credential;
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _getEmailLinkRedirectUrl() {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    return 'http://localhost:5000';
  }
}
