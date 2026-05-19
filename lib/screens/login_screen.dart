import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

enum AuthMode { signIn, signUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Dev mode: accepts any valid email (gmail, etc.)
  // Set to false before pilot launch to enforce .ac.in / .edu.in only.
  static const bool _devMode = true;

  AuthMode _mode = AuthMode.signIn;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
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

  bool get _isPasswordValid {
    return _passwordController.text.length >= 6;
  }

  bool get _canSubmit => _isEmailValid && _isPasswordValid && !_isLoading;

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
      _errorMessage = null;
    });
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

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

    if (!_isPasswordValid) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_mode == AuthMode.signUp) {
        await _authService.createAccount(email: email, password: password);
      } else {
        await _authService.signIn(email: email, password: password);
      }
      // Auth state stream will fire and AuthGate will route to HomeScreen.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _humanizeFirebaseError(e);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (!_isEmailValid) {
      setState(
        () => _errorMessage =
            'Enter your email above first, then tap Forgot password',
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _humanizeFirebaseError(e));
      }
    }
  }

  String _humanizeFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid';
      case 'user-not-found':
        return 'No account found with this email. Try signing up.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'An account already exists for this email. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == AuthMode.signUp;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),

                  // Logo
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
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email field
                  const Text(
                    'Institute email',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    decoration: _inputDecoration('name@institute.ac.in'),
                  ),

                  const SizedBox(height: 14),

                  // Password field
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    enabled: !_isLoading,
                    decoration:
                        _inputDecoration(
                          isSignUp ? 'At least 6 characters' : 'Your password',
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                            onPressed: () {
                              setState(() => _showPassword = !_showPassword);
                            },
                          ),
                        ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Submit button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _handleSubmit : null,
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
                          : Text(
                              isSignUp ? 'Create account' : 'Sign in',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Forgot password (only in sign in mode)
                  if (!isSignUp)
                    TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                  const Spacer(flex: 1),

                  // Mode toggle
                  TextButton(
                    onPressed: _isLoading ? null : _toggleMode,
                    child: Text(
                      isSignUp
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
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
                      fontWeight: _devMode
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: _errorMessage != null ? Colors.red.shade400 : AppColors.border,
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
    );
  }
}
