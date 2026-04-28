import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/auth_models.dart';
import '../../features/auth/logic/auth_cubit.dart';
import '../../features/queue/logic/clinic_queue_cubit.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthCubit>().currentRole;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _NotificationsHeader(
              title: context.locText(en: 'Notifications', ar: 'الإشعارات'),
            ),
            Expanded(
              child: BlocBuilder<ClinicQueueCubit, ClinicQueueState>(
                builder: (context, queueState) {
                  final notifications = _buildNotifications(
                    context,
                    role,
                    queueState,
                  );

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _NotificationCard(item: item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_NotificationItem> _buildNotifications(
    BuildContext context,
    UserRole role,
    ClinicQueueState queueState,
  ) {
    final trackedPatient = queueState.trackedPatient;
    final activePatient = queueState.activePatient;
    final waitingCount = queueState.patients
        .where((patient) => patient.status == ClinicQueuePatientStatus.waiting)
        .length;

    final latestAlert = queueState.latestAlert;
    final items = <_NotificationItem>[];

    if (latestAlert != null) {
      items.add(
        _NotificationItem(
          icon: latestAlert.type == QueueAlertType.call
              ? Icons.notifications_active_rounded
              : Icons.schedule_send_rounded,
          color: latestAlert.type == QueueAlertType.call
              ? AppColors.error
              : AppColors.warning,
          title: context.l10n.isArabic
              ? latestAlert.titleAr
              : latestAlert.titleEn,
          message: context.l10n.isArabic
              ? latestAlert.messageAr
              : latestAlert.messageEn,
          timeLabel: context.locText(en: 'Just now', ar: 'الآن'),
        ),
      );
    }

    if (role == UserRole.doctor) {
      items.addAll([
        _NotificationItem(
          icon: Icons.people_alt_outlined,
          color: AppColors.primary,
          title: context.locText(en: 'Queue overview', ar: 'نظرة على الطابور'),
          message: context.locText(
            en: '$waitingCount patients are still waiting for consultation today.',
            ar: 'يوجد $waitingCount مرضى ما زالوا بانتظار الاستشارة اليوم.',
          ),
          timeLabel: context.locText(en: '5 min ago', ar: 'منذ 5 دقائق'),
        ),
        _NotificationItem(
          icon: Icons.person_search_outlined,
          color: AppColors.tertiary,
          title: context.locText(
            en: 'Current patient update',
            ar: 'تحديث المريض الحالي',
          ),
          message: activePatient == null
              ? context.locText(
                  en: 'No consultation is currently active in the room.',
                  ar: 'لا توجد استشارة نشطة حاليًا داخل الغرفة.',
                )
              : context.locText(
                  en: '${activePatient.nameEn} is currently in consultation in room ${queueState.roomLabel}.',
                  ar: '${activePatient.nameAr} داخل الاستشارة حاليًا في الغرفة ${queueState.roomLabel}.',
                ),
          timeLabel: context.locText(en: '12 min ago', ar: 'منذ 12 دقيقة'),
        ),
        _NotificationItem(
          icon: Icons.event_available_outlined,
          color: AppColors.success,
          title: context.locText(en: 'Schedule reminder', ar: 'تذكير بالجدول'),
          message: context.locText(
            en: 'Your next clinic slot starts at 4:00 PM this afternoon.',
            ar: 'فترة العيادة التالية تبدأ الساعة 4:00 مساءً اليوم.',
          ),
          timeLabel: context.locText(en: '30 min ago', ar: 'منذ 30 دقيقة'),
        ),
      ]);
    } else {
      items.addAll([
        _NotificationItem(
          icon: Icons.local_hospital_outlined,
          color: AppColors.primary,
          title: context.locText(
            en: 'Queue tracking update',
            ar: 'تحديث تتبع الطابور',
          ),
          message: trackedPatient == null
              ? context.locText(
                  en: 'Your tracked queue is ready for updates.',
                  ar: 'تتبع الطابور الخاص بك جاهز للتحديثات.',
                )
              : context.locText(
                  en: 'Queue #${trackedPatient.queueNumber} for ${trackedPatient.nameEn} is assigned to room ${queueState.roomLabel}.',
                  ar: 'الدور رقم ${trackedPatient.queueNumber} للمريضة ${trackedPatient.nameAr} مخصص للغرفة ${queueState.roomLabel}.',
                ),
          timeLabel: context.locText(en: 'Just now', ar: 'الآن'),
        ),
        _NotificationItem(
          icon: Icons.calendar_month_outlined,
          color: AppColors.tertiary,
          title: context.locText(
            en: 'Appointment reminder',
            ar: 'تذكير بالموعد',
          ),
          message: context.locText(
            en: 'Your cardiology follow-up is scheduled for tomorrow at 2:10 PM.',
            ar: 'موعد المتابعة القلبية غدًا الساعة 2:10 مساءً.',
          ),
          timeLabel: context.locText(en: '20 min ago', ar: 'منذ 20 دقيقة'),
        ),
        _NotificationItem(
          icon: Icons.receipt_long_outlined,
          color: AppColors.warning,
          title: context.locText(
            en: 'Medical record ready',
            ar: 'السجل الطبي جاهز',
          ),
          message: context.locText(
            en: 'The latest visit summary and prescription are available now.',
            ar: 'ملخص الزيارة الأخيرة والوصفة الطبية متاحان الآن.',
          ),
          timeLabel: context.locText(en: '1 hour ago', ar: 'منذ ساعة'),
        ),
      ]);
    }

    return items;
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.timeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary.withValues(alpha: 0.82),
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

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.timeLabel,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String timeLabel;
}
