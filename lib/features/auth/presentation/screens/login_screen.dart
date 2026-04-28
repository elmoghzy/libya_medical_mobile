import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/storage/shared_preferences_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_models.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import '../../../doctors/presentation/screens/doctor_dashboard_screen.dart';
import '../../../home/presentation/screens/patient_dashboard_screen.dart';
import 'otp_screen.dart';
import 'profile_setup_screen.dart';
import 'workspace_selection_screen.dart';

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
    final l10n = context.l10n;
    final input = value?.trim() ?? '';
    if (input.isEmpty) return l10n.tr('emptyPhone');

    // Accept 9 digits (without leading 0) or 10 digits (with leading 0)
    final cleaned = input.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^0?\d{9}$').hasMatch(cleaned)) {
      return l10n.tr('invalidPhone');
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

  void _handleAuthSuccess(AuthSuccess state) {
    if (state.requiresWorkspaceSelection) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              WorkspaceSelectionScreen(institutions: state.institutions),
        ),
        (route) => false,
      );
      return;
    }

    _navigateBasedOnRole(state.role, isNewUser: state.isNewUser);
  }

  Future<void> _skipAuthForDev(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsHelper = SharedPreferencesHelper(prefs);

    await prefs.setString(
      'access_token',
      'dev_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    await prefs.setString(
      'user_role',
      role == UserRole.patient ? 'patient' : 'doctor',
    );
    await prefs.setInt('user_id', 999);
    await prefs.setString(
      'user_name',
      role == UserRole.patient ? 'مريض تجريبي' : 'دكتور تجريبي',
    );
    await prefs.setString('user_phone', '+218910000000');

    if (role == UserRole.doctor) {
      const devInstitution = InstitutionModel(id: 1, name: 'عيادة تجريبية');
      await prefs.setString(
        AuthCubit.institutionsStorageKey,
        jsonEncode([devInstitution.toJson()]),
      );
      await prefs.setInt(AuthCubit.institutionIdStorageKey, devInstitution.id);
      await prefs.setString(
        AuthCubit.institutionNameStorageKey,
        devInstitution.name,
      );
      await prefsHelper.saveLastInstitutionId(devInstitution.id);
    } else {
      await prefs.remove(AuthCubit.institutionsStorageKey);
      await prefs.remove(AuthCubit.institutionIdStorageKey);
      await prefs.remove(AuthCubit.institutionNameStorageKey);
      await prefsHelper.clearLastInstitutionId();
    }

    if (!mounted) return;

    _navigateBasedOnRole(role);

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.trWithArgs('devModeLoggedInAs', {
            'role': role == UserRole.patient
                ? l10n.tr('patient')
                : l10n.tr('doctor'),
          }),
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
        final l10n = context.l10n;

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
        } else if (state is AuthSuccess) {
          _handleAuthSuccess(state);
        } else if (state is AuthAuthenticated) {
          _navigateBasedOnRole(state.role);
        } else if (state is AuthError) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: state.canRetry
                  ? SnackBarAction(
                      label: l10n.tr('retry'),
                      textColor: Colors.white,
                      onPressed: _sendOtp,
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final isLoading = state is AuthLoading;
        final loadingMessage = state is AuthLoading ? state.message : null;
        final screenSize = MediaQuery.sizeOf(context);
        final isCompactWidth = screenSize.width < 420;
        final isCompactHeight = screenSize.height < 760;
        final horizontalPadding = isCompactWidth ? 16.0 : 24.0;
        final verticalPadding = isCompactHeight ? 12.0 : 20.0;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.medical_services,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.tr('appName'),
                              style: TextStyle(
                                fontSize: isCompactWidth ? 20 : 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isCompactHeight ? 28 : 48),
                        Text(
                          l10n.tr('welcome'),
                          style: TextStyle(
                            fontSize: isCompactWidth ? 28 : 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tr('enterPhonePrompt'),
                          style: TextStyle(
                            fontSize: isCompactWidth ? 14 : 15,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: isCompactHeight ? 28 : 48),
                        Text(
                          l10n.tr('phoneNumber'),
                          style: const TextStyle(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                color: AppColors.tertiary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.tr('smsCodeInfo'),
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
                        SizedBox(height: isCompactHeight ? 24 : 32),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        loadingMessage ?? l10n.tr('pleaseWait'),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.tr('sendOtp')),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: isCompactHeight ? 28 : 48),
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
                                    Text(
                                      l10n.tr('devModeOnly'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (isCompactWidth) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: isLoading
                                          ? null
                                          : () => _skipAuthForDev(
                                              UserRole.patient,
                                            ),
                                      icon: const Icon(Icons.person, size: 18),
                                      label: Text(l10n.tr('loginAsPatient')),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: isLoading
                                          ? null
                                          : () => _skipAuthForDev(
                                              UserRole.doctor,
                                            ),
                                      icon: const Icon(
                                        Icons.medical_services,
                                        size: 18,
                                      ),
                                      label: Text(l10n.tr('loginAsDoctor')),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.secondary,
                                        side: const BorderSide(
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: isLoading
                                              ? null
                                              : () => _skipAuthForDev(
                                                  UserRole.patient,
                                                ),
                                          icon: const Icon(
                                            Icons.person,
                                            size: 18,
                                          ),
                                          label: Text(
                                            l10n.tr('loginAsPatient'),
                                          ),
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
                                              : () => _skipAuthForDev(
                                                  UserRole.doctor,
                                                ),
                                          icon: const Icon(
                                            Icons.medical_services,
                                            size: 18,
                                          ),
                                          label: Text(l10n.tr('loginAsDoctor')),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppColors.secondary,
                                            side: const BorderSide(
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 0,
                            runSpacing: 8,
                            children: [
                              _FooterLink(
                                text: l10n.tr('privacyPolicy'),
                                onTap: () {},
                              ),
                              const _FooterDot(),
                              _FooterLink(
                                text: l10n.tr('termsOfService'),
                                onTap: () {},
                              ),
                              const _FooterDot(),
                              _FooterLink(
                                text: l10n.tr('helpCenter'),
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
