import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'clinic_queue_manager_screen.dart';
import 'consultation_view_screen.dart';
import 'schedule_manager_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home Tab
          _buildHomeTab(context),
          // Queue Tab
          const ClinicQueueManagerScreen(embedded: true),
          // Schedule Tab
          const ScheduleManagerScreen(embedded: true),
          // Profile Tab
          _buildProfileTab(context),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        isDoctor: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Column(
      children: [
        AppTopBar(
          title: context.locText(en: 'Dashboard', ar: 'لوحة التحكم'),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Welcome hero
                _buildWelcomeHero(context),
                const SizedBox(height: 24),
                // Stats cards
                _buildStatsRow(),
                const SizedBox(height: 24),
                // Quick actions
                _buildQuickActions(context),
                const SizedBox(height: 24),
                // Next patient
                _buildNextPatient(context),
                const SizedBox(height: 24),
                // Today's schedule
                _buildTodaySchedule(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return Column(
      children: [
        AppTopBar(title: context.l10n.tr('profile')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Profile Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 50, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'د. أحمد محمد',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'طب القلب',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Profile Options
                _buildProfileOption(
                  icon: Icons.edit,
                  title: context.locText(
                    en: 'Edit Profile',
                    ar: 'تعديل الملف الشخصي',
                  ),
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.settings,
                  title: context.locText(en: 'Settings', ar: 'الإعدادات'),
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.help_outline,
                  title: context.locText(
                    en: 'Help & Support',
                    ar: 'المساعدة والدعم',
                  ),
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: context.locText(en: 'Sign Out', ar: 'تسجيل الخروج'),
                  onTap: () => _showLogoutDialog(context),
                  isDestructive: true,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.locText(en: 'Sign Out', ar: 'تسجيل الخروج')),
        content: Text(
          context.locText(
            en: 'Are you sure you want to sign out?',
            ar: 'هل أنت متأكد من تسجيل الخروج؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear stored data and navigate to login
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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

  Widget _buildWelcomeHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tertiaryFixedDim,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.locText(en: 'ON DUTY', ar: 'على رأس العمل'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.locText(
                    en: 'Good Morning,\nDr. Hassan!',
                    ar: 'صباح الخير،\nد. حسن!',
                  ),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.locText(
                    en: 'You have 8 appointments today.\nYour clinic queue is active.',
                    ar: 'لديك 8 مواعيد اليوم.\nطابور العيادة لديك نشط الآن.',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.medical_services,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context.locText(en: 'Today\'s Patients', ar: 'مرضى اليوم'),
            '8',
            Icons.people_outline,
            AppColors.primary,
            context.locText(en: '3 completed', ar: 'اكتمل 3'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context.locText(en: 'In Queue', ar: 'في الطابور'),
            '5',
            Icons.queue,
            AppColors.warning,
            context.locText(en: '~2hr wait', ar: '~ساعتان انتظار'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context.locText(en: 'Rating', ar: 'التقييم'),
            '4.9',
            Icons.star_outline,
            AppColors.tertiary,
            context.locText(en: '120 reviews', ar: '120 تقييم'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.locText(en: 'Quick Actions', ar: 'إجراءات سريعة'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context.locText(en: 'Manage Queue', ar: 'إدارة الطابور'),
                context.locText(
                  en: 'View & manage patients',
                  ar: 'عرض وإدارة المرضى',
                ),
                Icons.queue,
                AppColors.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ClinicQueueManagerScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context.locText(en: 'Schedule', ar: 'الجدول'),
                context.locText(en: 'Set availability', ar: 'تحديد التوفر'),
                Icons.calendar_month,
                AppColors.tertiary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ScheduleManagerScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context.locText(en: 'Start Consultation', ar: 'بدء الاستشارة'),
                context.locText(
                  en: 'Begin with next patient',
                  ar: 'ابدأ مع المريض التالي',
                ),
                Icons.video_call,
                AppColors.success,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ConsultationViewScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context.locText(en: 'Medical Records', ar: 'السجل الطبي'),
                context.locText(
                  en: 'View patient history',
                  ar: 'عرض تاريخ المريض',
                ),
                Icons.folder_open,
                AppColors.warning,
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
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
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPatient(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.locText(en: 'Next Patient', ar: 'المريض التالي'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.locText(en: 'WAITING', ar: 'بانتظارك'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fatima Al-Farsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.locText(
                        en: 'Female, 34 years • Queue #4',
                        ar: 'أنثى، 34 سنة • رقم الدور 4',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTag(
                          context.locText(en: 'Heart Checkup', ar: 'فحص القلب'),
                          AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildTag(
                          context.locText(
                            en: 'First Visit',
                            ar: 'الزيارة الأولى',
                          ),
                          AppColors.tertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Reason for visit
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.locText(en: 'REASON FOR VISIT', ar: 'سبب الزيارة'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.locText(
                    en: 'Experiencing chest pain and shortness of breath during physical activities...',
                    ar: 'يعاني من ألم في الصدر وضيق في التنفس أثناء الأنشطة البدنية...',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    context.locText(en: 'View Records', ar: 'عرض السجل'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ConsultationViewScreen(),
                      ),
                    );
                  },
                  child: Text(
                    context.locText(en: 'Start Consult', ar: 'بدء الاستشارة'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.locText(en: 'Today\'s Schedule', ar: 'جدول اليوم'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(context.locText(en: 'View All', ar: 'عرض الكل')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildScheduleItem(
          '09:00',
          'Mohammed Ali',
          context.locText(en: 'Follow-up', ar: 'متابعة'),
          true,
        ),
        _buildScheduleItem(
          '09:30',
          'Sara Ahmed',
          context.locText(en: 'Consultation', ar: 'استشارة'),
          true,
        ),
        _buildScheduleItem(
          '10:00',
          'Khalid Omar',
          context.locText(en: 'ECG Test', ar: 'تخطيط قلب'),
          true,
        ),
        _buildScheduleItem(
          '10:30',
          'Fatima Al-Farsi',
          context.locText(en: 'Heart Checkup', ar: 'فحص القلب'),
          false,
          isCurrent: true,
        ),
        _buildScheduleItem(
          '11:00',
          'Ali Hassan',
          context.locText(en: 'Consultation', ar: 'استشارة'),
          false,
        ),
        _buildScheduleItem(
          '11:30',
          'Maryam Salem',
          context.locText(en: 'Follow-up', ar: 'متابعة'),
          false,
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
    String time,
    String name,
    String type,
    bool completed, {
    bool isCurrent = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isCurrent
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          if (!isCurrent)
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 56,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: completed
                    ? AppColors.textSecondary.withValues(alpha: 0.5)
                    : AppColors.primary,
              ),
            ),
          ),
          // Status indicator
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? AppColors.tertiary
                  : (isCurrent
                        ? AppColors.warning
                        : AppColors.surfaceContainerHigh),
            ),
          ),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: completed
                        ? AppColors.textSecondary.withValues(alpha: 0.6)
                        : AppColors.textPrimary,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          // Status text
          Text(
            completed
                ? context.locText(en: 'Done', ar: 'تم')
                : (isCurrent
                      ? context.locText(en: 'Now', ar: 'الآن')
                      : context.locText(en: 'Upcoming', ar: 'قادم')),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: completed
                  ? AppColors.tertiary
                  : (isCurrent
                        ? AppColors.warning
                        : AppColors.textSecondary.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
