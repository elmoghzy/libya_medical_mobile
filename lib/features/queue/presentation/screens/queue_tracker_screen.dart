import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../home/presentation/screens/patient_tab_navigation.dart';
import '../../logic/clinic_queue_cubit.dart';

class QueueTrackerScreen extends StatefulWidget {
  const QueueTrackerScreen({super.key});

  @override
  State<QueueTrackerScreen> createState() => _QueueTrackerScreenState();
}

class _QueueTrackerScreenState extends State<QueueTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final ClinicQueueCubit _queueCubit;

  @override
  void initState() {
    super.initState();
    _queueCubit = context.read<ClinicQueueCubit>();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueCubit.startQueueListener(doctorId: _queueCubit.state.doctorId);
    });
  }

  @override
  void dispose() {
    _queueCubit.stopQueueListener();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicQueueCubit, ClinicQueueState>(
      builder: (context, queueState) {
        final queueCubit = context.read<ClinicQueueCubit>();
        final patient = queueState.trackedPatient;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Column(
            children: [
              const AppTopBar(showBackButton: true),
              Expanded(
                child: patient == null
                    ? _buildEmptyState()
                    : patient.status == ClinicQueuePatientStatus.completed
                    ? _buildEmptyState(isCompleted: true)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildQueueStatusCard(
                              queueCubit,
                              queueState,
                              patient,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    context.locText(
                                      en: 'Est. Wait',
                                      ar: 'الانتظار المتوقع',
                                    ),
                                    patient.status ==
                                            ClinicQueuePatientStatus.inProgress
                                        ? context.locText(en: 'Now', ar: 'الآن')
                                        : context.locText(
                                            en: '~${queueCubit.waitMinutesFor(patient.id)} min',
                                            ar: '~${queueCubit.waitMinutesFor(patient.id)} دقيقة',
                                          ),
                                    Icons.timer_outlined,
                                    AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    context.locText(
                                      en: 'Queue #',
                                      ar: 'رقم الدور',
                                    ),
                                    '${patient.queueNumber}',
                                    Icons.confirmation_number_outlined,
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    context.locText(en: 'Room', ar: 'الغرفة'),
                                    queueState.roomLabel,
                                    Icons.meeting_room_outlined,
                                    AppColors.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildQueueProgress(
                              queueCubit,
                              queueState,
                              patient,
                            ),
                            const SizedBox(height: 24),
                            _buildDoctorInfo(queueState),
                            const SizedBox(height: 24),
                            _buildTipsSection(queueCubit, patient),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 2,
            onTap: (index) {
              if (index == 2) {
                return;
              }
              navigateToPatientRootTab(context, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({bool isCompleted = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted
                  ? context.locText(
                      en: 'Your consultation has been completed',
                      ar: 'اكتملت استشارتك بنجاح',
                    )
                  : context.locText(
                      en: 'No active queue right now',
                      ar: 'لا يوجد طابور نشط الآن',
                    ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted
                  ? context.locText(
                      en: 'You can return to bookings for your next appointment.',
                      ar: 'يمكنك العودة إلى الحجوزات لمراجعة موعدك التالي.',
                    )
                  : context.locText(
                      en: 'Queue updates will appear here once your appointment is active.',
                      ar: 'ستظهر تحديثات الطابور هنا عندما يصبح موعدك نشطًا.',
                    ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStatusCard(
    ClinicQueueCubit queueCubit,
    ClinicQueueState queueState,
    ClinicQueuePatient patient,
  ) {
    final patientsAhead = queueCubit.patientsAheadOf(patient.id);
    final totalPending = queueState.orderedPatients
        .where((item) => item.status != ClinicQueuePatientStatus.completed)
        .length;
    final estimatedStart = queueCubit.estimatedStartMinutesFor(patient.id);
    final delayMinutes = queueCubit.delayMinutesFor(patient.id);

    final headline = patient.status == ClinicQueuePatientStatus.inProgress
        ? context.locText(en: 'It is your turn now', ar: 'حان دورك الآن')
        : patientsAhead == 0
        ? context.locText(
            en: 'You are next in line',
            ar: 'أنت التالي في الطابور',
          )
        : context.locText(
            en: '$patientsAhead patients ahead of you',
            ar: 'يوجد $patientsAhead مرضى قبلك',
          );

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.tertiaryFixedDim,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tertiaryFixedDim.withValues(
                              alpha:
                                  0.5 +
                                  0.5 *
                                      math.sin(
                                        _pulseController.value * 2 * math.pi,
                                      ),
                            ),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  context.locText(
                    en: 'LIVE QUEUE TRACKING',
                    ar: 'تتبع مباشر للطابور',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha:
                              0.1 +
                              0.15 *
                                  math.sin(
                                    _pulseController.value * 2 * math.pi,
                                  ),
                        ),
                        width: 3,
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.locText(en: 'POSITION', ar: 'الترتيب'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${patientsAhead + 1}',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      context.locText(
                        en: 'of $totalPending',
                        ar: 'من $totalPending',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.locText(
              en: 'Expected ${queueCubit.formatClock(estimatedStart)} in room ${queueState.roomLabel}',
              ar: 'الموعد المتوقع ${queueCubit.formatClock(estimatedStart, useArabicPeriod: true)} في الغرفة ${queueState.roomLabel}',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          if (delayMinutes > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                context.locText(
                  en: 'Updated due to doctor delay: +$delayMinutes min',
                  ar: 'تم تحديث الموعد بسبب تأخر الطبيب: +$delayMinutes دقيقة',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueProgress(
    ClinicQueueCubit queueCubit,
    ClinicQueueState queueState,
    ClinicQueuePatient patient,
  ) {
    final completed = queueCubit.completedCount;
    final remaining = queueCubit.totalPatients - completed;
    final progress = queueCubit.totalPatients == 0
        ? 0.0
        : completed / queueCubit.totalPatients;
    final estimatedStart = queueCubit.estimatedStartMinutesFor(patient.id);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            context.locText(en: 'Queue Progress', ar: 'تقدّم الطابور'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: AppColors.surfaceContainerLow,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.tertiary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.locText(
                  en: '$completed patients served',
                  ar: 'تمت خدمة $completed مرضى',
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              Text(
                context.locText(
                  en: '$remaining remaining',
                  ar: 'المتبقي $remaining',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimelineItem(
            context.locText(en: 'Check-in', ar: 'تسجيل الحضور'),
            patient.checkInTime,
            true,
            true,
          ),
          _buildTimelineItem(
            context.locText(en: 'Scheduled Time', ar: 'وقت الحجز'),
            patient.scheduledTime,
            true,
            true,
          ),
          _buildTimelineItem(
            context.locText(en: 'Expected Consultation', ar: 'الوقت المتوقع'),
            context.locText(
              en: queueCubit.formatClock(estimatedStart),
              ar: queueCubit.formatClock(estimatedStart, useArabicPeriod: true),
            ),
            patient.status == ClinicQueuePatientStatus.inProgress,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    bool isCompleted,
    bool hasLine,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.tertiary
                    : AppColors.surfaceContainerLow,
                border: isCompleted
                    ? null
                    : Border.all(color: AppColors.outlineVariant, width: 2),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (hasLine)
              Container(
                width: 2,
                height: 32,
                color: isCompleted
                    ? AppColors.tertiary.withValues(alpha: 0.3)
                    : AppColors.surfaceContainerLow,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
                    color: isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted
                        ? AppColors.tertiary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo(ClinicQueueState queueState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person, size: 28, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.isArabic
                      ? queueState.doctorNameAr
                      : queueState.doctorNameEn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.isArabic
                      ? '${queueState.specialtyAr} • الغرفة ${queueState.roomLabel}'
                      : '${queueState.specialtyEn} • Room ${queueState.roomLabel}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              context.locText(en: 'Available', ar: 'متاح'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(
    ClinicQueueCubit queueCubit,
    ClinicQueuePatient patient,
  ) {
    final isInProgress = patient.status == ClinicQueuePatientStatus.inProgress;
    final estimatedStart = queueCubit.estimatedStartMinutesFor(patient.id);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.tertiary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                context.locText(en: 'What Happens Next', ar: 'ماذا سيحدث الآن'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            isInProgress
                ? context.locText(
                    en: 'You have been called. Head to the clinic room now.',
                    ar: 'تم استدعاؤك. توجّه الآن إلى غرفة العيادة.',
                  )
                : context.locText(
                    en: 'If the doctor is delayed, your expected time updates automatically.',
                    ar: 'إذا تأخر الطبيب، سيتم تحديث الوقت المتوقع لموعدك تلقائيًا.',
                  ),
          ),
          const SizedBox(height: 10),
          _buildTipItem(
            context.locText(
              en: 'Current expected time: ${queueCubit.formatClock(estimatedStart)}',
              ar: 'الوقت المتوقع الحالي: ${queueCubit.formatClock(estimatedStart, useArabicPeriod: true)}',
            ),
          ),
          const SizedBox(height: 10),
          _buildTipItem(
            context.locText(
              en: 'Keep notifications enabled to receive immediate call alerts.',
              ar: 'اترك الإشعارات مفعلة حتى يصلك تنبيه الاستدعاء فورًا.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.tertiary.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
