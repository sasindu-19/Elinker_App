// lib/features/auth/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/config/router_config.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button
                GestureDetector(
                  onTap: () => context.go(AppRoutes.onboarding),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textPrimary, size: 20),
                  ),
                ),

                const SizedBox(height: 32),

                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.4)),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/elinker_logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.link,
                              color: AppColors.primary, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'E',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextSpan(
                                text: 'linker',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          AppStrings.appTagline,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                const Text(
                  'Welcome\nBack! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to find local micro-jobs near you',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 36),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      _buildLabel(AppStrings.email),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          hintText: 'your@email.com',
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AppColors.textMuted, size: 20),
                          filled: true,
                          fillColor: AppColors.bgElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.borderDefault),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.borderDefault),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          hintStyle: const TextStyle(
                              color: AppColors.textMuted, fontFamily: 'Poppins'),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password field
                      _buildLabel(AppStrings.password),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'Poppins'),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppColors.textMuted, size: 20),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.bgElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.borderDefault),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.borderDefault),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          hintStyle: const TextStyle(
                              color: AppColors.textMuted, fontFamily: 'Poppins'),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please enter your password';
                          if (v.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: const Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Login button
                      GestureDetector(
                        onTap: _isLoading ? null : _login,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: _isLoading
                                ? null
                                : AppColors.primaryGradient,
                            color: _isLoading ? AppColors.bgElevated : null,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: _isLoading
                                ? null
                                : [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login_rounded,
                                          color: Colors.black, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        AppStrings.login,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.borderDefault)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppStrings.orContinueWith,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.borderDefault)),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Google Sign-in button
                      GestureDetector(
                        onTap: () async {
                          setState(() => _isLoading = true);
                          try {
                            await _authRepo.signInWithGoogle();
                          } catch (e) {
                            setState(() {
                              _errorMessage = 'Google sign in failed';
                              _isLoading = false;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Fallback for google logo
                              const Icon(Icons.g_mobiledata, color: Colors.black, size: 36),
                              const SizedBox(width: 8),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign up prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.noAccount,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.register),
                            child: const Text(
                              AppStrings.signUp,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 28,
          right: 28,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email to receive a reset link',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'your@email.com',
                prefixIcon: const Icon(Icons.email_outlined,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontFamily: 'Poppins'),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                if (emailCtrl.text.isNotEmpty) {
                  await _authRepo.resetPassword(emailCtrl.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reset link sent! Check your email.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Center(
                  child: Text(
                    'Send Reset Link',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
