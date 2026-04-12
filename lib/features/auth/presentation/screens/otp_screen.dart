import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import '../../data/auth_models.dart';
import '../../../home/presentation/screens/patient_dashboard_screen.dart';
import '../../../doctors/presentation/screens/doctor_dashboard_screen.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otpCode.length == 6;

  void _verifyOtp() {
    if (_isOtpComplete) {
      FocusScope.of(context).unfocus();
      context.read<AuthCubit>().verifyOtp(
        verificationId: widget.verificationId,
        smsCode: _otpCode,
        phoneNumber: widget.phoneNumber,
      );
    }
  }

  void _resendOtp() {
    if (_canResend) {
      _startResendTimer();
      _clearOtp();
      context.read<AuthCubit>().resendOtp(widget.phoneNumber);
    }
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on delete
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when complete
    if (_isOtpComplete) {
      _verifyOtp();
    }
  }

  void _navigateBasedOnRole(UserRole role, {bool isNewUser = false}) {
    if (isNewUser) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const ProfileSetupScreen()),
        (route) => false,
      );
    } else if (role == UserRole.doctor) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const DoctorDashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const PatientDashboardScreen()),
        (route) => false,
      );
    }
  }

  String _formatPhoneNumber(String phone) {
    // Simple formatting for display
    if (phone.startsWith('+218')) {
      return phone;
    }
    return '+218 $phone';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigateBasedOnRole(state.role, isNewUser: state.isNewUser);
        } else if (state is OtpSent) {
          // OTP resent - update verification ID if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.locText(
                  en: 'Verification code sent successfully',
                  ar: 'تم إرسال رمز التحقق بنجاح',
                ),
              ),
              backgroundColor: AppColors.tertiary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is AuthError) {
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
                      label: context.locText(en: 'Clear', ar: 'مسح'),
                      textColor: Colors.white,
                      onPressed: _clearOtp,
                    )
                  : null,
            ),
          );
          // Clear OTP on error for retry
          if (state.code == 'invalid-verification-code') {
            _clearOtp();
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading || state is OtpVerifying;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                context.read<AuthCubit>().reset();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Text(
                    context.locText(
                      en: 'Verify Phone',
                      ar: 'تأكيد الهاتف',
                    ),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: context.locText(
                            en: 'Enter the 6-digit code sent to ',
                            ar: 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى ',
                          ),
                        ),
                        TextSpan(
                          text: _formatPhoneNumber(widget.phoneNumber),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // OTP Input fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        height: 56,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: _controllers[index].text.isNotEmpty
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _controllers[index].text.isNotEmpty
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.surfaceContainerHigh,
                                width: 1,
                              ),
                            ),
                          ),
                          onChanged: (value) =>
                              _onOtpDigitChanged(index, value),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading || !_isOtpComplete
                          ? null
                          : _verifyOtp,
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
                                  state is OtpVerifying
                                      ? context.locText(
                                          en: 'Verifying...',
                                          ar: 'جارٍ التحقق...',
                                        )
                                      : (state as AuthLoading).message ??
                                            context.l10n.tr('pleaseWait'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.locText(
                                    en: 'Verify',
                                    ar: 'تحقق',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.check, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Resend timer
                  Center(
                    child: _canResend
                        ? TextButton(
                            onPressed: _resendOtp,
                            child: Text(
                              context.locText(
                                en: 'Resend Code',
                                ar: 'إعادة إرسال الرمز',
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.locText(
                                  en: "Didn't receive code? ",
                                  ar: 'لم يصلك الرمز؟ ',
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              Text(
                                context.locText(
                                  en: 'Resend in ${_resendSeconds}s',
                                  ar: 'إعادة الإرسال خلال ${_resendSeconds}ث',
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const Spacer(),
                  // Change number option
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AuthCubit>().reset();
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.locText(
                          en: 'Change Phone Number',
                          ar: 'تغيير رقم الهاتف',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
