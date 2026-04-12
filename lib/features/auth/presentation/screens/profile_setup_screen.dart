import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/patient_dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  String _selectedRole = 'patient';
  String? _selectedSpecialty;

  final List<String> _specialties = [
    'Cardiology',
    'Pediatrics',
    'Neurology',
    'Dermatology',
    'General Practice',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _completeProfile() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const PatientDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.08,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.05,
            left: -MediaQuery.of(context).size.width * 0.05,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.locText(en: 'Libya Medical', ar: 'ليبيا الطبية'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.locText(
                            en: 'Step 2 of 2',
                            ar: 'الخطوة 2 من 2',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Title
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text: context.locText(
                            en: 'Complete your\n',
                            ar: 'أكمل\n',
                          ),
                        ),
                        TextSpan(
                          text: context.locText(
                            en: 'professional profile',
                            ar: 'ملفك الشخصي',
                          ),
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.locText(
                      en:
                          'Help us personalize your medical journey with accurate details.',
                      ar: 'ساعدنا في تخصيص تجربتك الصحية بإدخال بيانات دقيقة.',
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Profile card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar upload
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                      strokeAlign: BorderSide.strokeAlignInside,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 32,
                                    color: AppColors.outline,
                                  ),
                                ),
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.locText(
                                      en: 'Profile Picture',
                                      ar: 'الصورة الشخصية',
                                    ),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.locText(
                                      en:
                                          'Clear facial photos help build trust with colleagues and patients.',
                                      ar:
                                          'الصورة الواضحة تساعد على بناء الثقة مع الزملاء والمرضى.',
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.8,
                                      ),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Full name
                        Text(
                          context.locText(
                            en: 'Full Name',
                            ar: 'الاسم الكامل',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: context.locText(
                              en: 'Dr. Ahmed Mansour',
                              ar: 'د. أحمد منصور',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Role selection
                        Text(
                          context.locText(en: 'I am a...', ar: 'أنا...'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.person_outline,
                                title: context.locText(
                                  en: 'Patient',
                                  ar: 'مريض',
                                ),
                                subtitle: context.locText(
                                  en: 'Looking for care',
                                  ar: 'أبحث عن رعاية',
                                ),
                                isSelected: _selectedRole == 'patient',
                                onTap: () =>
                                    setState(() => _selectedRole = 'patient'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.medical_services_outlined,
                                title: context.locText(
                                  en: 'Healthcare Provider',
                                  ar: 'مقدم رعاية',
                                ),
                                subtitle: context.locText(
                                  en: 'Managing patients',
                                  ar: 'أدير المرضى',
                                ),
                                isSelected: _selectedRole == 'doctor',
                                onTap: () =>
                                    setState(() => _selectedRole = 'doctor'),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedRole == 'doctor') ...[
                          const SizedBox(height: 24),
                          Text(
                            context.locText(
                              en: 'Medical Specialty',
                              ar: 'التخصص الطبي',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedSpecialty,
                            hint: Text(
                              context.locText(
                                en: 'Select your field',
                                ar: 'اختر تخصصك',
                              ),
                            ),
                            decoration: const InputDecoration(),
                            items: _specialties.map((specialty) {
                              return DropdownMenuItem(
                                value: specialty,
                                child: Text(
                                  _localizedSpecialty(context, specialty),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedSpecialty = value),
                          ),
                        ],
                        const SizedBox(height: 32),
                        // Submit button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.locText(
                                  en:
                                      'You can update these details later in Settings.',
                                  ar:
                                      'يمكنك تعديل هذه البيانات لاحقًا من الإعدادات.',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _completeProfile,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.locText(
                                      en: 'Complete Profile',
                                      ar: 'إكمال الملف',
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.people_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.locText(
                                        en: 'Verified Network',
                                        ar: 'شبكة موثقة',
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.locText(
                                        en:
                                            'Join 500+ licensed Libyan medical professionals.',
                                        ar:
                                            'انضم إلى أكثر من 500 مختص طبي ليبي مرخّص.',
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.7),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                context.locText(
                                  en: 'Clinical Data Privacy Guaranteed',
                                  ar: 'خصوصية البيانات الطبية مضمونة',
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localizedSpecialty(BuildContext context, String specialty) {
  if (!context.l10n.isArabic) return specialty;

  switch (specialty) {
    case 'Cardiology':
      return 'طب القلب';
    case 'Pediatrics':
      return 'طب الأطفال';
    case 'Neurology':
      return 'طب الأعصاب';
    case 'Dermatology':
      return 'الأمراض الجلدية';
    case 'General Practice':
      return 'طب عام';
    default:
      return specialty;
  }
}
