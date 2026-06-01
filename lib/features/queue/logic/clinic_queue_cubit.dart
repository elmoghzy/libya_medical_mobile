import 'dart:convert';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/reverb_echo_service.dart';

enum ClinicQueuePatientStatus { waiting, inProgress, completed }

enum ClinicQueuePatientPriority { normal, high, urgent }

enum QueueAlertType { call, delay }

class ClinicQueuePatient extends Equatable {
  const ClinicQueuePatient({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.age,
    required this.genderEn,
    required this.genderAr,
    required this.queueNumber,
    required this.appointmentDate,
    required this.checkInTime,
    required this.scheduledTime,
    required this.visitTypeEn,
    required this.visitTypeAr,
    required this.status,
    required this.priority,
    this.baseDurationMinutes = 20,
    this.delayMinutes = 0,
  });

  final int id;
  final String nameEn;
  final String nameAr;
  final int age;
  final String genderEn;
  final String genderAr;
  final int queueNumber;
  final DateTime appointmentDate;
  final String checkInTime;
  final String scheduledTime;
  final String visitTypeEn;
  final String visitTypeAr;
  final ClinicQueuePatientStatus status;
  final ClinicQueuePatientPriority priority;
  final int baseDurationMinutes;
  final int delayMinutes;

  int get totalDurationMinutes => baseDurationMinutes + delayMinutes;

  ClinicQueuePatient copyWith({
    ClinicQueuePatientStatus? status,
    int? queueNumber,
    int? baseDurationMinutes,
    int? delayMinutes,
    DateTime? appointmentDate,
  }) {
    return ClinicQueuePatient(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      age: age,
      genderEn: genderEn,
      genderAr: genderAr,
      queueNumber: queueNumber ?? this.queueNumber,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      checkInTime: checkInTime,
      scheduledTime: scheduledTime,
      visitTypeEn: visitTypeEn,
      visitTypeAr: visitTypeAr,
      status: status ?? this.status,
      priority: priority,
      baseDurationMinutes: baseDurationMinutes ?? this.baseDurationMinutes,
      delayMinutes: delayMinutes ?? this.delayMinutes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nameEn,
    nameAr,
    age,
    genderEn,
    genderAr,
    queueNumber,
    appointmentDate,
    checkInTime,
    scheduledTime,
    visitTypeEn,
    visitTypeAr,
    status,
    priority,
    baseDurationMinutes,
    delayMinutes,
  ];
}

class QueueAlertEvent extends Equatable {
  const QueueAlertEvent({
    required this.id,
    required this.patientId,
    required this.type,
    required this.titleEn,
    required this.titleAr,
    required this.messageEn,
    required this.messageAr,
  });

  final int id;
  final int patientId;
  final QueueAlertType type;
  final String titleEn;
  final String titleAr;
  final String messageEn;
  final String messageAr;

  @override
  List<Object?> get props => [
    id,
    patientId,
    type,
    titleEn,
    titleAr,
    messageEn,
    messageAr,
  ];
}

class ClinicQueueState extends Equatable {
  const ClinicQueueState({
    required this.patients,
    required this.trackedPatientId,
    required this.doctorId,
    required this.roomLabel,
    required this.doctorNameEn,
    required this.doctorNameAr,
    required this.specialtyEn,
    required this.specialtyAr,
    required this.alertSequence,
    this.latestAlert,
  });

  factory ClinicQueueState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    return const ClinicQueueState(
      trackedPatientId: 4,
      doctorId: 1,
      roomLabel: 'A-104',
      doctorNameEn: 'Dr. Ahmed Hassan',
      doctorNameAr: 'د. أحمد حسن',
      specialtyEn: 'Cardiologist',
      specialtyAr: 'أخصائي قلب',
      alertSequence: 0,
      patients: [],
    ).copyWith(
      patients: [
        ClinicQueuePatient(
          id: 1,
          nameEn: 'Mohammed Ali',
          nameAr: 'محمد علي',
          age: 45,
          genderEn: 'Male',
          genderAr: 'ذكر',
          queueNumber: 1,
          appointmentDate: today,
          checkInTime: '12:45',
          scheduledTime: '13:00',
          visitTypeEn: 'Follow-up',
          visitTypeAr: 'متابعة',
          status: ClinicQueuePatientStatus.completed,
          priority: ClinicQueuePatientPriority.normal,
        ),
        ClinicQueuePatient(
          id: 2,
          nameEn: 'Sara Ahmed',
          nameAr: 'سارة أحمد',
          age: 28,
          genderEn: 'Female',
          genderAr: 'أنثى',
          queueNumber: 2,
          appointmentDate: today,
          checkInTime: '13:20',
          scheduledTime: '13:30',
          visitTypeEn: 'Consultation',
          visitTypeAr: 'استشارة',
          status: ClinicQueuePatientStatus.completed,
          priority: ClinicQueuePatientPriority.normal,
        ),
        ClinicQueuePatient(
          id: 3,
          nameEn: 'Khalid Omar',
          nameAr: 'خالد عمر',
          age: 52,
          genderEn: 'Male',
          genderAr: 'ذكر',
          queueNumber: 3,
          appointmentDate: today,
          checkInTime: '13:50',
          scheduledTime: '14:00',
          visitTypeEn: 'ECG Test',
          visitTypeAr: 'تخطيط قلب',
          status: ClinicQueuePatientStatus.inProgress,
          priority: ClinicQueuePatientPriority.high,
        ),
        ClinicQueuePatient(
          id: 4,
          nameEn: 'Fatima Al-Farsi',
          nameAr: 'فاطمة الفارسي',
          age: 34,
          genderEn: 'Female',
          genderAr: 'أنثى',
          queueNumber: 4,
          appointmentDate: today,
          checkInTime: '14:00',
          scheduledTime: '14:10',
          visitTypeEn: 'Heart Checkup',
          visitTypeAr: 'فحص قلب',
          status: ClinicQueuePatientStatus.waiting,
          priority: ClinicQueuePatientPriority.urgent,
        ),
        ClinicQueuePatient(
          id: 5,
          nameEn: 'Ali Hassan',
          nameAr: 'علي حسن',
          age: 67,
          genderEn: 'Male',
          genderAr: 'ذكر',
          queueNumber: 5,
          appointmentDate: today,
          checkInTime: '14:20',
          scheduledTime: '14:30',
          visitTypeEn: 'Consultation',
          visitTypeAr: 'استشارة',
          status: ClinicQueuePatientStatus.waiting,
          priority: ClinicQueuePatientPriority.high,
        ),
        ClinicQueuePatient(
          id: 6,
          nameEn: 'Maryam Salem',
          nameAr: 'مريم سالم',
          age: 41,
          genderEn: 'Female',
          genderAr: 'أنثى',
          queueNumber: 6,
          appointmentDate: today,
          checkInTime: '14:40',
          scheduledTime: '14:50',
          visitTypeEn: 'Follow-up',
          visitTypeAr: 'متابعة',
          status: ClinicQueuePatientStatus.waiting,
          priority: ClinicQueuePatientPriority.normal,
        ),
        ClinicQueuePatient(
          id: 7,
          nameEn: 'Ibrahim Saleh',
          nameAr: 'إبراهيم صالح',
          age: 50,
          genderEn: 'Male',
          genderAr: 'ذكر',
          queueNumber: 1,
          appointmentDate: yesterday,
          checkInTime: '10:30',
          scheduledTime: '10:40',
          visitTypeEn: 'Consultation',
          visitTypeAr: 'استشارة',
          status: ClinicQueuePatientStatus.completed,
          priority: ClinicQueuePatientPriority.normal,
        ),
        ClinicQueuePatient(
          id: 8,
          nameEn: 'Noura Ali',
          nameAr: 'نورة علي',
          age: 39,
          genderEn: 'Female',
          genderAr: 'أنثى',
          queueNumber: 2,
          appointmentDate: yesterday,
          checkInTime: '11:10',
          scheduledTime: '11:20',
          visitTypeEn: 'Heart Checkup',
          visitTypeAr: 'فحص قلب',
          status: ClinicQueuePatientStatus.completed,
          priority: ClinicQueuePatientPriority.high,
        ),
        ClinicQueuePatient(
          id: 9,
          nameEn: 'Huda Salem',
          nameAr: 'هدى سالم',
          age: 31,
          genderEn: 'Female',
          genderAr: 'أنثى',
          queueNumber: 1,
          appointmentDate: tomorrow,
          checkInTime: '09:50',
          scheduledTime: '10:00',
          visitTypeEn: 'Follow-up',
          visitTypeAr: 'متابعة',
          status: ClinicQueuePatientStatus.waiting,
          priority: ClinicQueuePatientPriority.normal,
        ),
        ClinicQueuePatient(
          id: 10,
          nameEn: 'Omar Khaled',
          nameAr: 'عمر خالد',
          age: 44,
          genderEn: 'Male',
          genderAr: 'ذكر',
          queueNumber: 2,
          appointmentDate: tomorrow,
          checkInTime: '10:15',
          scheduledTime: '10:25',
          visitTypeEn: 'ECG Test',
          visitTypeAr: 'تخطيط قلب',
          status: ClinicQueuePatientStatus.waiting,
          priority: ClinicQueuePatientPriority.high,
        ),
      ],
    );
  }

  final List<ClinicQueuePatient> patients;
  final int trackedPatientId;
  final int doctorId;
  final String roomLabel;
  final String doctorNameEn;
  final String doctorNameAr;
  final String specialtyEn;
  final String specialtyAr;
  final int alertSequence;
  final QueueAlertEvent? latestAlert;

  ClinicQueueState copyWith({
    List<ClinicQueuePatient>? patients,
    int? trackedPatientId,
    int? doctorId,
    String? roomLabel,
    String? doctorNameEn,
    String? doctorNameAr,
    String? specialtyEn,
    String? specialtyAr,
    int? alertSequence,
    QueueAlertEvent? latestAlert,
    bool preserveLatestAlert = true,
  }) {
    return ClinicQueueState(
      patients: patients ?? this.patients,
      trackedPatientId: trackedPatientId ?? this.trackedPatientId,
      doctorId: doctorId ?? this.doctorId,
      roomLabel: roomLabel ?? this.roomLabel,
      doctorNameEn: doctorNameEn ?? this.doctorNameEn,
      doctorNameAr: doctorNameAr ?? this.doctorNameAr,
      specialtyEn: specialtyEn ?? this.specialtyEn,
      specialtyAr: specialtyAr ?? this.specialtyAr,
      alertSequence: alertSequence ?? this.alertSequence,
      latestAlert: preserveLatestAlert
          ? (latestAlert ?? this.latestAlert)
          : latestAlert,
    );
  }

  List<ClinicQueuePatient> get orderedPatients {
    final sorted = [...patients];
    sorted.sort((a, b) => a.queueNumber.compareTo(b.queueNumber));
    return sorted;
  }

  ClinicQueuePatient? patientById(int patientId) {
    for (final patient in patients) {
      if (patient.id == patientId) {
        return patient;
      }
    }
    return null;
  }

  ClinicQueuePatient? get trackedPatient => patientById(trackedPatientId);

  ClinicQueuePatient? get activePatient {
    for (final patient in orderedPatients) {
      if (patient.status == ClinicQueuePatientStatus.inProgress) {
        return patient;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    patients,
    trackedPatientId,
    doctorId,
    roomLabel,
    doctorNameEn,
    doctorNameAr,
    specialtyEn,
    specialtyAr,
    alertSequence,
    latestAlert,
  ];
}

class ClinicQueueCubit extends Cubit<ClinicQueueState> {
  ClinicQueueCubit({required ReverbEchoService reverbEchoService})
    : _reverbEchoService = reverbEchoService,
      super(ClinicQueueState.initial());

  final ReverbEchoService _reverbEchoService;
  int? _listeningDoctorId;

  bool canCallPatient(int patientId) {
    final patient = state.patientById(patientId);
    if (patient == null || patient.status != ClinicQueuePatientStatus.waiting) {
      return false;
    }

    if (state.activePatient != null) {
      return false;
    }

    ClinicQueuePatient? nextWaiting;
    for (final queuePatient in state.orderedPatients) {
      if (queuePatient.status == ClinicQueuePatientStatus.waiting) {
        nextWaiting = queuePatient;
        break;
      }
    }

    return nextWaiting?.id == patientId;
  }

  void callPatient(int patientId) {
    if (!canCallPatient(patientId)) {
      return;
    }

    final patient = state.patientById(patientId);
    if (patient == null) {
      return;
    }

    final updatedPatients = state.patients
        .map(
          (item) => item.id == patientId
              ? item.copyWith(status: ClinicQueuePatientStatus.inProgress)
              : item,
        )
        .toList(growable: false);

    final alertId = state.alertSequence + 1;

    emit(
      state.copyWith(
        patients: updatedPatients,
        alertSequence: alertId,
        latestAlert: QueueAlertEvent(
          id: alertId,
          patientId: patientId,
          type: QueueAlertType.call,
          titleEn: 'Please proceed to the clinic now',
          titleAr: 'يرجى التوجه إلى العيادة الآن',
          messageEn:
              '${patient.nameEn}, the doctor has called your turn in room ${state.roomLabel}.',
          messageAr:
              '${patient.nameAr}، الطبيب استدعاك الآن في الغرفة ${state.roomLabel}.',
        ),
      ),
    );
  }

  void completePatient(int patientId) {
    final patient = state.patientById(patientId);
    if (patient == null ||
        patient.status == ClinicQueuePatientStatus.completed) {
      return;
    }

    final updatedPatients = state.patients
        .map(
          (item) => item.id == patientId
              ? item.copyWith(status: ClinicQueuePatientStatus.completed)
              : item,
        )
        .toList(growable: false);

    emit(state.copyWith(patients: updatedPatients));
  }

  void addPatient({
    required String name,
    required int age,
    required bool isFemale,
    required String visitTypeEn,
    required String visitTypeAr,
    required ClinicQueuePatientPriority priority,
    int baseDurationMinutes = 20,
    DateTime? scheduledDate,
  }) {
    final date = _normalizeDate(scheduledDate ?? DateTime.now());
    final patientId = _nextPatientId;
    final queueNumber = _nextQueueNumberForDate(date);
    final nowMinutes = _roundUpToFive(_currentMinutes());
    final scheduledStartMinutes = nextAvailableStartMinutes(forDate: date);

    final newPatient = ClinicQueuePatient(
      id: patientId,
      nameEn: name,
      nameAr: name,
      age: age,
      genderEn: isFemale ? 'Female' : 'Male',
      genderAr: isFemale ? 'أنثى' : 'ذكر',
      queueNumber: queueNumber,
      appointmentDate: date,
      checkInTime: _formatStorageTime(nowMinutes),
      scheduledTime: _formatStorageTime(scheduledStartMinutes),
      visitTypeEn: visitTypeEn,
      visitTypeAr: visitTypeAr,
      status: ClinicQueuePatientStatus.waiting,
      priority: priority,
      baseDurationMinutes: baseDurationMinutes,
    );

    emit(
      state.copyWith(
        patients: [...state.patients, newPatient],
        preserveLatestAlert: true,
      ),
    );
  }

  List<ClinicQueuePatient> patientsForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return state.orderedPatients
        .where(
          (patient) => _isSameDate(patient.appointmentDate, normalizedDate),
        )
        .toList(growable: false);
  }

  int waitingCountForDate(DateTime date) {
    return patientsForDate(date)
        .where((patient) => patient.status == ClinicQueuePatientStatus.waiting)
        .length;
  }

  int activeCountForDate(DateTime date) {
    return patientsForDate(date)
        .where(
          (patient) => patient.status == ClinicQueuePatientStatus.inProgress,
        )
        .length;
  }

  int completedCountForDate(DateTime date) {
    return patientsForDate(date)
        .where(
          (patient) => patient.status == ClinicQueuePatientStatus.completed,
        )
        .length;
  }

  int totalPatientsForDate(DateTime date) => patientsForDate(date).length;

  void addDelayToActivePatient({int minutes = 10}) {
    final activePatient = state.activePatient;
    final trackedPatient = state.trackedPatient;

    if (activePatient == null || trackedPatient == null) {
      return;
    }

    final oldStarts = estimatedStartMinutesByPatient();

    final updatedPatients = state.patients
        .map(
          (patient) => patient.id == activePatient.id
              ? patient.copyWith(delayMinutes: patient.delayMinutes + minutes)
              : patient,
        )
        .toList(growable: false);

    final newStarts = estimatedStartMinutesByPatient(updatedPatients);
    final oldTrackedStart = oldStarts[trackedPatient.id];
    final newTrackedStart = newStarts[trackedPatient.id];

    QueueAlertEvent? alert = state.latestAlert;
    var nextAlertId = state.alertSequence;

    if (oldTrackedStart != null &&
        newTrackedStart != null &&
        newTrackedStart > oldTrackedStart &&
        trackedPatient.status == ClinicQueuePatientStatus.waiting) {
      nextAlertId += 1;
      alert = QueueAlertEvent(
        id: nextAlertId,
        patientId: trackedPatient.id,
        type: QueueAlertType.delay,
        titleEn: 'Your appointment time has been updated',
        titleAr: 'تم تحديث وقت موعدك',
        messageEn:
            'The current consultation is taking longer than expected. Your new estimated time is ${formatClock(newTrackedStart)}.',
        messageAr:
            'الكشف الحالي استغرق وقتًا أطول من المتوقع. وقتك الجديد المتوقع هو ${formatClock(newTrackedStart, useArabicPeriod: true)}.',
      );
    }

    emit(
      state.copyWith(
        patients: updatedPatients,
        alertSequence: nextAlertId,
        latestAlert: alert,
      ),
    );
  }

  Map<int, int> estimatedStartMinutesByPatient([
    List<ClinicQueuePatient>? sourcePatients,
  ]) {
    final patients = [...(sourcePatients ?? state.patients)];
    patients.sort((a, b) => a.queueNumber.compareTo(b.queueNumber));

    final starts = <int, int>{};
    int? cursor;

    for (final patient in patients) {
      final scheduledMinutes = _parseTime(patient.scheduledTime);
      final estimatedStart = cursor == null
          ? scheduledMinutes
          : math.max(scheduledMinutes, cursor);

      starts[patient.id] = estimatedStart;
      cursor = estimatedStart + patient.totalDurationMinutes;
    }

    return starts;
  }

  int estimatedStartMinutesFor(int patientId) {
    return estimatedStartMinutesByPatient()[patientId] ??
        _parseTime(state.patientById(patientId)?.scheduledTime ?? '00:00');
  }

  int delayMinutesFor(int patientId) {
    final patient = state.patientById(patientId);
    if (patient == null) {
      return 0;
    }

    return estimatedStartMinutesFor(patientId) -
        _parseTime(patient.scheduledTime);
  }

  int waitMinutesFor(int patientId) {
    final patient = state.patientById(patientId);
    if (patient == null ||
        patient.status == ClinicQueuePatientStatus.completed) {
      return 0;
    }

    if (patient.status == ClinicQueuePatientStatus.inProgress) {
      return 0;
    }

    var waitMinutes = 0;
    for (final item in state.orderedPatients) {
      if (item.id == patientId) {
        break;
      }
      if (item.status != ClinicQueuePatientStatus.completed) {
        waitMinutes += item.totalDurationMinutes;
      }
    }
    return waitMinutes;
  }

  int patientsAheadOf(int patientId) {
    final patient = state.patientById(patientId);
    if (patient == null) {
      return 0;
    }

    var count = 0;
    for (final item in state.orderedPatients) {
      if (item.id == patientId) {
        break;
      }
      if (item.status != ClinicQueuePatientStatus.completed) {
        count += 1;
      }
    }
    return count;
  }

  int get completedCount => state.patients
      .where((patient) => patient.status == ClinicQueuePatientStatus.completed)
      .length;

  int get activeCount => state.patients
      .where((patient) => patient.status == ClinicQueuePatientStatus.inProgress)
      .length;

  int get waitingCount => state.patients
      .where((patient) => patient.status == ClinicQueuePatientStatus.waiting)
      .length;

  int get totalPatients => state.patients.length;

  int nextAvailableStartMinutes({DateTime? forDate}) {
    final orderedPatients = forDate == null
        ? state.orderedPatients
        : patientsForDate(forDate);
    if (orderedPatients.isEmpty) {
      return _roundUpToFive(_currentMinutes());
    }

    final lastPatient = orderedPatients.last;
    final estimatedStarts = estimatedStartMinutesByPatient();
    final lastPatientStart =
        estimatedStarts[lastPatient.id] ??
        _parseTime(lastPatient.scheduledTime);
    final lastPatientEnd = lastPatientStart + lastPatient.totalDurationMinutes;

    return math.max(_roundUpToFive(_currentMinutes()), lastPatientEnd);
  }

  String formatClock(int totalMinutes, {bool useArabicPeriod = false}) {
    final normalized = totalMinutes % (24 * 60);
    final hour24 = normalized ~/ 60;
    final minute = normalized % 60;
    final period = hour24 >= 12
        ? (useArabicPeriod ? 'م' : 'PM')
        : (useArabicPeriod ? 'ص' : 'AM');
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final hourText = hour12.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText $period';
  }

  int get _nextPatientId {
    var maxId = 0;
    for (final patient in state.patients) {
      if (patient.id > maxId) {
        maxId = patient.id;
      }
    }
    return maxId + 1;
  }

  int _nextQueueNumberForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    var maxQueueNumber = 0;
    for (final patient in state.patients) {
      if (_isSameDate(patient.appointmentDate, normalizedDate) &&
          patient.queueNumber > maxQueueNumber) {
        maxQueueNumber = patient.queueNumber;
      }
    }
    return maxQueueNumber + 1;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _currentMinutes() {
    final now = DateTime.now();
    return (now.hour * 60) + now.minute;
  }

  int _roundUpToFive(int totalMinutes) {
    final remainder = totalMinutes % 5;
    if (remainder == 0) {
      return totalMinutes;
    }
    return totalMinutes + (5 - remainder);
  }

  String _formatStorageTime(int totalMinutes) {
    final normalized = totalMinutes % (24 * 60);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    final hours = int.tryParse(parts.first) ?? 0;
    final minutes = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return (hours * 60) + minutes;
  }

  Future<void> startQueueListener({required int doctorId}) async {
    if (doctorId <= 0) {
      return;
    }

    if (_listeningDoctorId == doctorId) {
      return;
    }

    await stopQueueListener();
    _listeningDoctorId = doctorId;

    await _reverbEchoService.initialize();
    _reverbEchoService.listenToQueueChannel(
      doctorId: doctorId,
      onEvent: _handleQueueStatusEvent,
    );
  }

  Future<void> stopQueueListener() async {
    _listeningDoctorId = null;
    _reverbEchoService.leaveChannel();
  }

  void _handleQueueStatusEvent(dynamic data) {
    final payload = _normalizePayload(data);
    final bookingId = _parseIntSafely(payload['booking_id']);
    if (bookingId == null) {
      return;
    }

    final updatedStatus = _mapBackendStatus(payload['status']);
    final queueNumber = _parseIntSafely(payload['queue_number']);

    final updatedPatients = state.patients
        .map(
          (patient) => patient.id == bookingId
              ? patient.copyWith(
                  status: updatedStatus ?? patient.status,
                  queueNumber: queueNumber ?? patient.queueNumber,
                )
              : patient,
        )
        .toList(growable: false);

    emit(state.copyWith(patients: updatedPatients));
  }

  ClinicQueuePatientStatus? _mapBackendStatus(dynamic value) {
    if (value == null) {
      return null;
    }

    final status = value.toString();
    switch (status) {
      case 'waiting':
      case 'confirmed':
      case 'checked_in':
        return ClinicQueuePatientStatus.waiting;
      case 'in_progress':
        return ClinicQueuePatientStatus.inProgress;
      case 'completed':
      case 'cancelled':
        return ClinicQueuePatientStatus.completed;
      default:
        return null;
    }
  }

  Map<String, dynamic> _normalizePayload(dynamic data) {
    if (data is Map) {
      final mapped = Map<String, dynamic>.from(data as Map);
      final nested = mapped['data'];
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
      if (nested is String && nested.isNotEmpty) {
        try {
          final decoded = jsonDecode(nested);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded as Map);
          }
        } catch (_) {
          return mapped;
        }
      }
      return mapped;
    }

    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded as Map);
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    return <String, dynamic>{};
  }

  int? _parseIntSafely(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }
}
