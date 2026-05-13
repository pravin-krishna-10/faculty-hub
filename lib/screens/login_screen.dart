import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();

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
    // Clear error message when user types again.
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    } else {
      // Trigger rebuild so button enabled state updates.
      setState(() {});
    }
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    if (email.isEmpty) return false;
    // Basic email shape: something@something.something
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

    // In production mode, enforce institute email.
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

    // Simulate sending OTP (tomorrow we wire this to Firebase).
    await Future.delayed(const Duration(seconds: 1));

    print('OTP would be sent to: $email');

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $email (simulated)'),
          duration: const Duration(seconds: 2),
        ),
      );
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

              // App name
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

              // Tagline
              const Text(
                'Academic openings, shared by the community',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 48),

              // Email label
              const Text(
                'Institute email',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 6),

              // Email input field
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

              // Error message (only shown when there's an error)
              if (_errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                ),
              ],

              const SizedBox(height: 16),

              // Send OTP button
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
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Footer text
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
