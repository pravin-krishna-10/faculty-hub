import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  // Dev mode: accepts any valid email (gmail, etc.)
  // Set to false before pilot launch to enforce .ac.in / .edu.in only.
  static const bool _devMode = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    } else {
      setState(() {});
    }
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');
    return emailRegex.hasMatch(email);
  }

  bool get _isInstituteEmail {
    final email = _emailController.text.trim().toLowerCase();
    return email.endsWith('.ac.in') || email.endsWith('.edu.in');
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();

    if (!_isEmailValid) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    if (!_devMode && !_isInstituteEmail) {
      setState(
        () => _errorMessage = 'Only .ac.in or .edu.in emails are allowed',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Real Firebase call — sends a magic sign-in link to the user's email.
      await _authService.sendSignInLink(email);

      // Save email locally so we can retrieve it when the user clicks the link
      // and returns to our app. (The link itself does not contain the email
      // for security reasons.)
      // We'll set up proper storage tomorrow. For now, just log.
      print('Magic link sent to: $email');

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Check your email at $email for the sign-in link'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase-specific errors (network, invalid email format, etc.)
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _humanizeFirebaseError(e);
        });
      }
    } catch (e) {
      // Any other error
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
        print('Unexpected error sending sign-in link: $e');
      }
    }
  }

  String _humanizeFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid';
      case 'network-request-failed':
        return 'Network error. Check your internet connection';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'FH',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'FacultyHub',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Academic openings, shared by the community',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              const Text(
                'Institute email',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'name@institute.ac.in',
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _errorMessage != null
                          ? Colors.red.shade400
                          : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _errorMessage != null
                          ? Colors.red.shade400
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (_isEmailValid && !_isLoading)
                      ? _handleSendOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.textTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send sign-in link',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _devMode
                    ? 'Dev mode: any valid email accepted'
                    : 'Only verified institute emails (.ac.in, .edu.in) can join',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: _devMode
                      ? Colors.orange.shade700
                      : AppColors.textTertiary,
                  fontWeight: _devMode ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
