import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../home/presentation/screens/patient_dashboard_screen.dart';
import '../../../queue/logic/clinic_queue_cubit.dart';
import '../../logic/bookings_cubit.dart';
import '../../logic/bookings_state.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    this.specialty,
    this.fee,
    required this.date,
    required this.time,
    required this.bookingDate,
    required this.bookingTime,
  });

  final int doctorId;
  final String doctorName;
  final String? specialty;
  final String? fee;
  final String date; // Display format
  final String time; // Display format
  final String bookingDate; // API format: YYYY-MM-DD
  final String bookingTime; // API format: HH:MM

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingsCubit>(),
      child: _BookingConfirmationView(
        doctorId: doctorId,
        doctorName: doctorName,
        specialty: specialty,
        fee: fee,
        date: date,
        time: time,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
      ),
    );
  }
}

class _BookingConfirmationView extends StatefulWidget {
  const _BookingConfirmationView({
    required this.doctorId,
    required this.doctorName,
    this.specialty,
    this.fee,
    required this.date,
    required this.time,
    required this.bookingDate,
    required this.bookingTime,
  });

  final int doctorId;
  final String doctorName;
  final String? specialty;
  final String? fee;
  final String date;
  final String time;
  final String bookingDate;
  final String bookingTime;

  @override
  State<_BookingConfirmationView> createState() =>
      _BookingConfirmationViewState();
}

class _BookingConfirmationViewState extends State<_BookingConfirmationView> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _confirmBooking() {
    context.read<BookingsCubit>().createDoctorBooking(
      doctorId: widget.doctorId,
      date: widget.bookingDate,
      time: widget.bookingTime,
    );
  }

  void _showSuccessDialog(int queueNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.check,
                size: 32,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تم تأكيد الحجز!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('تم حجز موعدك بنجاح', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'رقمك في قائمة الانتظار',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#$queueNumber',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientDashboardScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text(
                'العودة للرئيسية',
                style: TextStyle(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AppTopBar(title: 'تأكيد الحجز'),
      body: BlocConsumer<BookingsCubit, BookingsState>(
        listener: (context, state) {
          if (state is BookingCreated) {
            final queueNumber = state.booking.queueNumber ?? 0;

            context.read<ClinicQueueCubit>().addPatient(
              name: 'مريض جديد (حجز $queueNumber)',
              age: 30,
              isFemale: false,
              visitTypeEn: 'New consultation',
              visitTypeAr: 'كشف جديد',
              priority: ClinicQueuePatientPriority.normal,
            );

            _showSuccessDialog(queueNumber);
          } else if (state is BookingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is BookingsLoading;
          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDoctorCard(),
                      const SizedBox(height: 24),
                      _buildDetailsCard(),
                      const SizedBox(height: 24),
                      _buildReasonField(),
                      const SizedBox(height: 24),
                      _buildNotes(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'تأكيد الحجز',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('جاري تأكيد الحجز...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                widget.doctorName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.specialty != null)
                    Text(
                      widget.specialty!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  if (widget.fee != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.fee} دينار',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل الموعد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(widget.date, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(widget.time, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سبب الزيارة (اختياري)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'اذكر سبب الزيارة...',
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: 8),
              const Text(
                'ملاحظات مهمة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• يرجى الحضور قبل 15 دقيقة',
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            '• أحضر معك بطاقة التأمين',
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            '• يمكنك الإلغاء قبل ساعتين',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
