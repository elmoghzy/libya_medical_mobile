import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import '../../data/auth_models.dart';
import '../../../home/presentation/screens/patient_dashboard_screen.dart';
import '../../../doctors/presentation/screens/doctor_dashboard_screen.dart';
import 'profile_setup_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().sendOtp(_phoneController.text.trim());
    }
  }

  String? _validatePhoneNumber(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Please enter your phone number';
    // Accept 9 digits (without leading 0) or 10 digits (with leading 0)
    final cleaned = input.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^0?\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid Libyan phone number';
    }
    return null;
  }

  void _navigateBasedOnRole(UserRole role, {bool isNewUser = false}) {
    if (isNewUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const ProfileSetupScreen()),
      );
    } else if (role == UserRole.doctor) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const DoctorDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const PatientDashboardScreen()),
      );
    }
  }

  /// DEV MODE: Skip auth and go directly to dashboard
  Future<void> _skipAuthForDev(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save fake token and role
    await prefs.setString('access_token', 'dev_token_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString('user_role', role == UserRole.patient ? 'patient' : 'doctor');
    await prefs.setInt('user_id', 999);
    await prefs.setString('user_name', role == UserRole.patient ? 'مريض تجريبي' : 'دكتور تجريبي');
    await prefs.setString('user_phone', '+218910000000');
    
    if (!mounted) return;
    
    // Navigate to dashboard
    _navigateBasedOnRole(role);
    
    // Show debug message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔧 DEV MODE: Logged in as ${role == UserRole.patient ? "Patient" : "Doctor"}',
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Navigate to OTP screen when code is sent
        if (state is OtpSent) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => OtpScreen(
                verificationId: state.verificationId,
                phoneNumber: state.phoneNumber,
              ),
            ),
          );
        }
        // Navigate based on role when authenticated
        else if (state is AuthSuccess) {
          _navigateBasedOnRole(state.role, isNewUser: state.isNewUser);
        } else if (state is AuthAuthenticated) {
          _navigateBasedOnRole(state.role);
        }
        // Show error snackbar
        else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: state.canRetry
                  ? SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: _sendOtp,
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final loadingMessage = state is AuthLoading ? state.message : null;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mobile header
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Libya Medical',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Welcome text
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your phone number to receive a verification code.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Phone field
                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      validator: _validatePhoneNumber,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _sendOtp(),
                      decoration: InputDecoration(
                        hintText: '91 000 0000',
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppColors.outlineVariant,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: const Center(
                            widthFactor: 1,
                            child: Text(
                              '+218',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Info text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.tertiary.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'We will send you a 6-digit verification code via SMS.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.tertiary.withValues(
                                  alpha: 0.9,
                                ),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendOtp,
                        child: isLoading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    loadingMessage ?? 'Please wait...',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Send OTP'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // DEV MODE: Skip Auth Buttons (Debug only)
                    if (kDebugMode) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.bug_report,
                                  color: AppColors.warning,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'وضع التطوير فقط',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () => _skipAuthForDev(UserRole.patient),
                                    icon: const Icon(Icons.person, size: 18),
                                    label: const Text('دخول كمريض'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () => _skipAuthForDev(UserRole.doctor),
                                    icon: const Icon(Icons.medical_services, size: 18),
                                    label: const Text('دخول كطبيب'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.secondary,
                                      side: const BorderSide(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Footer links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterLink(text: 'Privacy Policy', onTap: () {}),
                        const _FooterDot(),
                        _FooterLink(text: 'Terms of Service', onTap: () {}),
                        const _FooterDot(),
                        _FooterLink(text: 'Help Center', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  const _FooterDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '•',
        style: TextStyle(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
