import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FacultyHubApp());
}

class FacultyHubApp extends StatelessWidget {
  const FacultyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FacultyHub',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

/// Decides which screen to show on startup.
///
/// Three cases:
/// 1. App was opened via a magic sign-in link → complete sign-in and route home
/// 2. User is already signed in (returning user) → route home
/// 3. Otherwise → show login screen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  bool _isProcessingLink = false;
  String? _linkError;
  String? _emailLinkUrl; // Saved if we need to ask user for their email

  @override
  void initState() {
    super.initState();
    _checkForSignInLink();
  }

  Future<void> _checkForSignInLink() async {
    if (!kIsWeb) return;

    final currentUrl = Uri.base.toString();

    if (!_authService.isSignInLink(currentUrl)) {
      return;
    }

    setState(() => _isProcessingLink = true);

    try {
      String? email = await _authService.getPendingSignInEmail();

      if (email == null) {
        // Ask the user to enter their email (e.g. they clicked the link
        // on a different device or browser session).
        setState(() {
          _isProcessingLink = false;
          _emailLinkUrl = currentUrl;
        });
        return;
      }

      await _completeSignIn(email, currentUrl);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _completeSignIn(String email, String emailLink) async {
    setState(() {
      _isProcessingLink = true;
      _linkError = null;
    });

    try {
      await _authService.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );
      // Auth state stream will fire and StreamBuilder will route to HomeScreen.
      if (mounted) {
        setState(() {
          _isProcessingLink = false;
          _emailLinkUrl = null;
        });
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    if (!mounted) return;
    String message;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-action-code':
          message =
              'This sign-in link is invalid or has already been used. Please request a new one.';
          break;
        case 'expired-action-code':
          message = 'This sign-in link has expired. Please request a new one.';
          break;
        default:
          message = e.message ?? 'Sign-in failed. Please try again.';
      }
    } else {
      message = 'Could not complete sign-in. Please try again.';
      print('Unexpected error completing sign-in: $e');
    }
    setState(() {
      _isProcessingLink = false;
      _linkError = message;
      _emailLinkUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessingLink) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Signing you in...'),
            ],
          ),
        ),
      );
    }

    // Need to ask user for their email to complete sign-in
    if (_emailLinkUrl != null) {
      return _EmailPromptScreen(
        onSubmit: (email) {
          _completeSignIn(email, _emailLinkUrl!);
        },
        onCancel: () {
          setState(() {
            _emailLinkUrl = null;
            _linkError = null;
          });
        },
      );
    }

    if (_linkError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _linkError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _linkError = null);
                  },
                  child: const Text('Back to login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class _EmailPromptScreen extends StatefulWidget {
  final void Function(String email) onSubmit;
  final VoidCallback onCancel;

  const _EmailPromptScreen({required this.onSubmit, required this.onCancel});

  @override
  State<_EmailPromptScreen> createState() => _EmailPromptScreenState();
}

class _EmailPromptScreenState extends State<_EmailPromptScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.mail_outline, size: 56, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Confirm your email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'For security, please enter the email address where you received the sign-in link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final email = _controller.text.trim();
                    if (email.isNotEmpty) {
                      widget.onSubmit(email);
                    }
                  },
                  child: const Text('Complete sign-in'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
