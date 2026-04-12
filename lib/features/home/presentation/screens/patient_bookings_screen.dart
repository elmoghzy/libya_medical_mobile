import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../bookings/data/models/booking_model.dart';
import '../../../bookings/logic/bookings_cubit.dart';
import '../../../bookings/logic/bookings_state.dart';
import 'patient_tab_navigation.dart';

class PatientBookingsScreen extends StatelessWidget {
  const PatientBookingsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingsCubit>()..fetchMyBookings(),
      child: _PatientBookingsView(embedded: embedded),
    );
  }
}

class _PatientBookingsView extends StatelessWidget {
  const _PatientBookingsView({required this.embedded});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        AppTopBar(title: context.l10n.tr('bookings')),
        Expanded(
          child: BlocConsumer<BookingsCubit, BookingsState>(
            listener: (context, state) {
              if (state is BookingsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is BookingsLoading || state is BookingsInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is BookingsError) {
                return _BookingsErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<BookingsCubit>().fetchMyBookings(),
                );
              }

              if (state is BookingsLoaded) {
                final upcoming = state.bookings
                    .where(_isUpcomingBooking)
                    .toList();
                final history = state.bookings
                    .where(_isHistoryBooking)
                    .toList();

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<BookingsCubit>().refreshBookings(),
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    children: [
                      _BookingsSummaryCard(
                        total: state.bookings.length,
                        upcoming: upcoming.length,
                      ),
                      const SizedBox(height: 24),
                      if (state.bookings.isEmpty) const _EmptyBookingsView(),
                      if (upcoming.isNotEmpty) ...[
                        _SectionTitle(
                          title: context.locText(
                            en: 'Upcoming Bookings',
                            ar: 'الحجوزات القادمة',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...upcoming.map(
                          (booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BookingCard(booking: booking),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (history.isNotEmpty) ...[
                        _SectionTitle(
                          title: context.locText(
                            en: 'History',
                            ar: 'السجل',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...history.map(
                          (booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BookingCard(booking: booking),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: content,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          navigateToPatientRootTab(context, index);
        },
      ),
    );
  }

  static bool _isUpcomingBooking(BookingModel booking) {
    return booking.status == 'confirmed' ||
        booking.status == 'checked_in' ||
        booking.status == 'in_progress';
  }

  static bool _isHistoryBooking(BookingModel booking) {
    return booking.status == 'completed' || booking.status == 'cancelled';
  }
}

class _BookingsSummaryCard extends StatelessWidget {
  const _BookingsSummaryCard({required this.total, required this.upcoming});

  final int total;
  final int upcoming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.tertiary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: context.locText(
                en: 'Total Bookings',
                ar: 'إجمالي الحجوزات',
              ),
              value: '$total',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryItem(
              label: context.locText(en: 'Upcoming', ar: 'القادمة'),
              value: '$upcoming',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final details = booking.bookable;
    final isDoctor = booking.isDoctor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDoctor ? Icons.medical_services : Icons.bed_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details?.name ??
                          context.locText(
                            en: 'Booking #${booking.id}',
                            ar: 'حجز #${booking.id}',
                          ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDoctor
                          ? (details?.specialty ??
                                context.locText(
                                  en: 'Medical appointment',
                                  ar: 'موعد طبي',
                                ))
                          : (details?.roomNumber != null
                                ? context.locText(
                                    en: 'Room ${details!.roomNumber}',
                                    ar: 'غرفة ${details.roomNumber}',
                                  )
                                : context.locText(
                                    en: 'Room booking',
                                    ar: 'حجز غرفة',
                                  )),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: booking.statusDisplayText),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.calendar_today_outlined,
                text: booking.bookingDate,
              ),
              _InfoPill(icon: Icons.access_time, text: booking.bookingTime),
              if (booking.queueNumber != null)
                _InfoPill(
                  icon: Icons.confirmation_number_outlined,
                  text: context.locText(
                    en: 'Queue #${booking.queueNumber}',
                    ar: 'رقم الدور ${booking.queueNumber}',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookingsView extends StatelessWidget {
  const _EmptyBookingsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 16),
          Text(
            context.locText(
              en: 'No bookings yet',
              ar: 'لا توجد حجوزات حتى الآن',
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.locText(
              en: 'Once you book a new appointment, it will appear here.',
              ar: 'عند حجز موعد جديد سيظهر هنا مباشرة.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsErrorView extends StatelessWidget {
  const _BookingsErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                context.l10n.tr('retry'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
