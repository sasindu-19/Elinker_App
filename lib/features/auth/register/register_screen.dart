// lib/features/auth/register/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/config/router_config.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepo = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String _userType = 'both'; // 'worker' | 'client' | 'both'

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Registration failed. Please try again.');
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

                const Text(
                  'Create\nAccount 🚀',
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
                  'Join Sri Lanka\'s verified gig network',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 28),

                // User type selector
                _buildUserTypeSelector(),

                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.error.withOpacity(0.3)),
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

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name
                      _buildLabel(AppStrings.fullName),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Kasun Perera',
                        icon: Icons.person_outline,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter your full name'
                            : null,
                      ),

                      const SizedBox(height: 18),

                      // Email
                      _buildLabel(AppStrings.email),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'your@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Phone (optional)
                      _buildLabel('${AppStrings.phone} (Optional)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _phoneController,
                        hint: '+94 7X XXX XXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 18),

                      // Password
                      _buildLabel(AppStrings.password),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        onToggleObscure: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please enter a password';
                          if (v.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Confirm Password
                      _buildLabel('Confirm Password'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: _obscureConfirm,
                        onToggleObscure: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) {
                          if (v != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Register button
                      GestureDetector(
                        onTap: _isLoading ? null : _register,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: _isLoading
                                ? null
                                : AppColors.primaryGradient,
                            color:
                                _isLoading ? AppColors.bgElevated : null,
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
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.hasAccount,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(AppRoutes.login),
                            child: const Text(
                              AppStrings.signIn,
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

                      const SizedBox(height: 28),

                      const Text(
                        'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          height: 1.5,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 24),
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

  Widget _buildUserTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I want to...',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildTypeChip('Find Work', 'worker', Icons.work_outline),
            const SizedBox(width: 10),
            _buildTypeChip('Hire People', 'client', Icons.people_outline),
            const SizedBox(width: 10),
            _buildTypeChip('Both', 'both', Icons.swap_horiz_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, String type, IconData icon) {
    final isSelected = _userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _userType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderDefault,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: onToggleObscure != null
            ? GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
            color: AppColors.textMuted, fontFamily: 'Poppins'),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}
