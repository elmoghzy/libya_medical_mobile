import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../doctors/presentation/screens/doctor_search_screen.dart';
import '../../../facilities/presentation/screens/facility_listing_screen.dart';
import '../../../queue/logic/clinic_queue_cubit.dart';
import '../../../queue/presentation/screens/queue_tracker_screen.dart';
import 'patient_bookings_screen.dart';
import 'patient_profile_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  late int _currentNavIndex;
  int? _lastHandledAlertId;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialTabIndex < 0
        ? 0
        : (widget.initialTabIndex > 3 ? 3 : widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClinicQueueCubit, ClinicQueueState>(
      listenWhen: (previous, current) =>
          previous.latestAlert?.id != current.latestAlert?.id,
      listener: (context, state) {
        final alert = state.latestAlert;
        if (alert == null ||
            alert.patientId != state.trackedPatientId ||
            _lastHandledAlertId == alert.id) {
          return;
        }

        _lastHandledAlertId = alert.id;
        _showQueueAlertDialog(alert);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildHomeTab(),
            const DoctorSearchScreen(embedded: true),
            const PatientBookingsScreen(embedded: true),
            const PatientProfileScreen(embedded: true),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        const AppTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeroSection(),
                const SizedBox(height: 16),
                _buildLiveQueueCard(),
                const SizedBox(height: 24),
                _buildCTAGrid(),
                const SizedBox(height: 32),
                _buildUpcomingAppointments(),
                const SizedBox(height: 24),
                _buildLiveStatus(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openQueueTracker() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const QueueTrackerScreen()),
    );
  }

  Future<void> _showQueueAlertDialog(QueueAlertEvent alert) async {
    if (!mounted) {
      return;
    }

    final isArabic = context.l10n.isArabic;
    final title = isArabic ? alert.titleAr : alert.titleEn;
    final message = isArabic ? alert.messageAr : alert.messageEn;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: alert.type == QueueAlertType.call
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    alert.type == QueueAlertType.call
                        ? Icons.notifications_active_rounded
                        : Icons.schedule_send_rounded,
                    size: 38,
                    color: alert.type == QueueAlertType.call
                        ? AppColors.error
                        : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _openQueueTracker();
                    },
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    label: Text(
                      context.locText(
                        en: 'Open Live Queue',
                        ar: 'افتح التتبع المباشر',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(context.locText(en: 'Dismiss', ar: 'إغلاق')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection() {
    final helloText = context.locText(
      en: 'Hello, Ahmed Al-Farsi',
      ar: 'مرحبًا، أحمد الفارسي',
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image placeholder
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 150,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.locText(en: 'WELCOME BACK', ar: 'مرحبًا بعودتك'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.success.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                helloText,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.locText(
                  en: 'Your health journey is our priority. Explore our specialized services and world-class facilities today.',
                  ar: 'رحلتك الصحية هي أولويتنا. استكشف خدماتنا الطبية المتخصصة والمرافق المتاحة بسهولة.',
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCTAGrid() {
    return Row(
      children: [
        Expanded(
          child: _CTACard(
            icon: Icons.medical_information,
            title: context.locText(en: 'Book Doctor', ar: 'احجز طبيب'),
            subtitle: context.locText(
              en: 'Access top-rated specialists in medicine.',
              ar: 'اطلع على أفضل الأطباء المتخصصين واحجز بسرعة.',
            ),
            buttonText: context.locText(
              en: 'Schedule Visit',
              ar: 'احجز موعدًا',
            ),
            isPrimary: true,
            onTap: () {
              setState(() => _currentNavIndex = 1);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _CTACard(
            icon: Icons.bed_outlined,
            title: context.locText(en: 'Book Room', ar: 'احجز غرفة'),
            subtitle: context.locText(
              en: 'Reserve premium medical recovery suites.',
              ar: 'احجز غرف الرعاية والتعافي المتاحة داخل المستشفى.',
            ),
            buttonText: context.locText(
              en: 'Check Availability',
              ar: 'تحقق من التوفر',
            ),
            isPrimary: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const FacilityListingScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveQueueCard() {
    return BlocBuilder<ClinicQueueCubit, ClinicQueueState>(
      builder: (context, queueState) {
        final queueCubit = context.read<ClinicQueueCubit>();
        final patient = queueState.trackedPatient;

        if (patient == null ||
            patient.status == ClinicQueuePatientStatus.completed) {
          return const SizedBox.shrink();
        }

        final estimatedStart = queueCubit.estimatedStartMinutesFor(patient.id);
        final delayMinutes = queueCubit.delayMinutesFor(patient.id);
        final waitMinutes = queueCubit.waitMinutesFor(patient.id);
        final statusText = patient.status == ClinicQueuePatientStatus.inProgress
            ? context.locText(
                en: 'The doctor is ready for you now',
                ar: 'الطبيب جاهز لك الآن',
              )
            : delayMinutes > 0
            ? context.locText(
                en: 'Your appointment moved by $delayMinutes minutes',
                ar: 'تم تحريك موعدك بمقدار $delayMinutes دقيقة',
              )
            : context.locText(
                en: 'Your turn is approaching',
                ar: 'دورك يقترب الآن',
              );

        return GestureDetector(
          onTap: _openQueueTracker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withValues(alpha: 0.08),
                  AppColors.warning.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    patient.status == ClinicQueuePatientStatus.inProgress
                        ? Icons.notifications_active_rounded
                        : Icons.access_time_filled_rounded,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.locText(
                          en: 'Live Queue Update',
                          ar: 'تحديث مباشر للطابور',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.82,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QueueBadge(
                            text: context.locText(
                              en: 'Expected ${queueCubit.formatClock(estimatedStart)}',
                              ar: 'المتوقع ${queueCubit.formatClock(estimatedStart, useArabicPeriod: true)}',
                            ),
                          ),
                          _QueueBadge(
                            text: context.locText(
                              en: 'Wait ~$waitMinutes min',
                              ar: 'الانتظار ~$waitMinutes دقيقة',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingAppointments() {
    final noMoreAppointments = context.locText(
      en: 'No other appointments\nscheduled this week',
      ar: 'لا توجد مواعيد أخرى\nمجدولة هذا الأسبوع',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.locText(
                    en: 'Upcoming Appointments',
                    ar: 'المواعيد القادمة',
                  ),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.locText(
                    en: "Don't miss your next medical checkup",
                    ar: 'لا تفوّت موعدك الطبي القادم',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                context.locText(en: 'View All', ar: 'عرض الكل'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Appointment cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AppointmentCard(
                doctorName: context.locText(
                  en: 'Dr. Selim Khoury',
                  ar: 'د. سليم خوري',
                ),
                specialty: context.locText(
                  en: 'Senior Cardiologist',
                  ar: 'استشاري أمراض القلب',
                ),
                date: context.locText(
                  en: 'Tomorrow, Oct 24, 2023',
                  ar: 'غدًا، 24 أكتوبر 2023',
                ),
                time: context.locText(
                  en: '10:30 AM - 11:15 AM',
                  ar: '10:30 ص - 11:15 ص',
                ),
                isConfirmed: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerHigh,
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.outline,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      noMoreAppointments,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Live indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.locText(
                  en: 'FACILITY LIVE STATUS',
                  ar: 'حالة المرافق المباشرة',
                ),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Status items
          Row(
            children: [
              _StatusItem(
                label: context.locText(en: 'Radiology Lab', ar: 'مختبر الأشعة'),
                value: context.locText(en: 'Normal Wait', ar: 'انتظار طبيعي'),
                isAlert: false,
              ),
              const SizedBox(width: 24),
              _StatusItem(
                label: context.locText(en: 'Emergency Care', ar: 'قسم الطوارئ'),
                value: context.locText(en: 'High Activity', ar: 'ازدحام مرتفع'),
                isAlert: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CTACard extends StatelessWidget {
  const _CTACard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : AppColors.tertiary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isPrimary ? AppColors.textPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isPrimary
                  ? AppColors.textSecondary.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: Size.zero,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.isConfirmed,
  });

  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
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
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.locText(en: 'CONFIRMED', ar: 'مؤكد'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Doctor info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date & time
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.surfaceContainerHigh),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    context.locText(en: 'Reschedule', ar: 'إعادة جدولة'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    context.locText(en: 'Pre-Check', ar: 'تسجيل مسبق'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.label,
    required this.value,
    required this.isAlert,
  });

  final String label;
  final String value;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isAlert ? AppColors.error : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _QueueBadge extends StatelessWidget {
  const _QueueBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
