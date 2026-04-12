import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'patient_tab_navigation.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late final SharedPreferences _prefs;
  late final String _name;
  late final String _phone;

  @override
  void initState() {
    super.initState();
    _prefs = sl<SharedPreferences>();
    _name = _prefs.getString('user_name') ?? 'User';
    _phone = _prefs.getString('user_phone') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        AppTopBar(title: context.l10n.tr('profile')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 52,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _ProfileTile(
                  icon: Icons.badge_outlined,
                  title: context.locText(en: 'Account Type', ar: 'نوع الحساب'),
                  subtitle: context.locText(en: 'Patient', ar: 'مريض'),
                ),
                _ProfileTile(
                  icon: Icons.language_outlined,
                  title: context.locText(en: 'Language', ar: 'اللغة'),
                  subtitle: context.locText(en: 'English', ar: 'العربية'),
                ),
                _ProfileTile(
                  icon: Icons.security_outlined,
                  title: context.locText(
                    en: 'Session Status',
                    ar: 'حالة الجلسة',
                  ),
                  subtitle: context.locText(
                    en: 'Signed in',
                    ar: 'مسجل الدخول',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showLogoutDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.logout),
                    label: Text(context.locText(en: 'Sign Out', ar: 'تسجيل الخروج')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: content,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          navigateToPatientRootTab(context, index);
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.locText(en: 'Sign Out', ar: 'تسجيل الخروج')),
        content: Text(
          context.locText(
            en: 'Do you want to end the current session?',
            ar: 'هل تريد إنهاء الجلسة الحالية؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _prefs.clear();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              context.locText(en: 'Sign Out', ar: 'تسجيل الخروج'),
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
