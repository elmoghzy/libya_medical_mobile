# Libya Medical - أمثلة برمجية مطابقة للكود الحالي

هذه الأمثلة تعكس **الأسلوب الفعلي المستخدم الآن** داخل المشروع، وليست أمثلة نظرية قديمة.

---

## 1. Bootstrapping التطبيق

مثال من `main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      await Firebase.initializeApp();
    } else {
      debugPrint('Firebase not initialized on this platform. Using Dev Mode.');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        BlocProvider(create: (_) => di.sl<LocaleCubit>()),
        BlocProvider.value(value: di.sl<ClinicQueueCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
```

---

## 2. إرسال OTP من `LoginScreen`

```dart
void _sendOtp() {
  if (_formKey.currentState?.validate() ?? false) {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().sendOtp(_phoneController.text.trim());
  }
}

BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
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
    } else if (state is AuthError) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  },
  builder: (context, state) {
    final isLoading = state is AuthLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : _sendOtp,
      child: Text(isLoading ? 'يرجى الانتظار...' : 'إرسال الرمز'),
    );
  },
)
```

---

## 3. whitelist check قبل Firebase OTP

هذا هو السلوك الفعلي الحالي داخل `auth_remote_data_source.dart`:

```dart
Future<String> sendOtp(String phoneNumber) async {
  await _ensureDoctorPhoneIsWhitelisted(phoneNumber);

  await firebaseAuth.verifyPhoneNumber(
    phoneNumber: _formatPhoneNumberForFirebase(phoneNumber),
    timeout: const Duration(seconds: 60),
    verificationCompleted: _onVerificationCompleted,
    verificationFailed: _onVerificationFailed,
    codeSent: _onCodeSent,
    codeAutoRetrievalTimeout: _onAutoRetrievalTimeout,
  );

  return await _verificationCompleter!.future;
}

Future<void> _ensureDoctorPhoneIsWhitelisted(String phoneNumber) async {
  try {
    final response = await _dioClient.client.post<Map<String, dynamic>>(
      ApiConstants.checkDoctorPhone,
      data: {'phone': _formatPhoneNumberForApi(phoneNumber)},
    );

    final data = response.data;
    if (data == null || data['success'] != true) {
      throw const AuthException(
        'عذراً، رقمك غير مسجل في النظام. يرجى مراجعة إدارة العيادة.',
        code: 'doctor-not-whitelisted',
      );
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 403) {
      throw const AuthException(
        'عذراً، رقمك غير مسجل في النظام. يرجى مراجعة إدارة العيادة.',
        code: 'doctor-not-whitelisted',
      );
    }

    rethrow;
  }
}
```

---

## 4. التحقق من OTP والانتقال حسب الدور

مثال مطابق لطريقة العمل الحالية في `OtpScreen`:

```dart
void _verifyOtp() {
  if (_otpCode.length == 6) {
    context.read<AuthCubit>().verifyOtp(
      verificationId: widget.verificationId,
      smsCode: _otpCode,
      phoneNumber: widget.phoneNumber,
    );
  }
}

void _navigateBasedOnRole(UserRole role, {bool isNewUser = false}) {
  if (isNewUser) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const ProfileSetupScreen()),
      (route) => false,
    );
  } else if (role == UserRole.doctor) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const DoctorDashboardScreen()),
      (route) => false,
    );
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const PatientDashboardScreen()),
      (route) => false,
    );
  }
}
```

---

## 5. تسجيل دخول Dev Mode

هذا موجود فعليًا في `LoginScreen` لاختبار التطبيق على البيئات التي لا تدعم Firebase Phone Auth:

```dart
Future<void> _skipAuthForDev(UserRole role) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('access_token', 'dev_token');
  await prefs.setString(
    'user_role',
    role == UserRole.patient ? 'patient' : 'doctor',
  );
  await prefs.setInt('user_id', 999);

  if (!mounted) return;

  if (role == UserRole.doctor) {
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
```

---

## 6. جلب قائمة الأطباء + البحث + الفلترة

```dart
class _DoctorSearchViewState extends State<_DoctorSearchView> {
  final _searchController = TextEditingController();
  String? _selectedFilter;

  void _onSearchChanged(String query) {
    context.read<DoctorsCubit>().searchDoctors(query);
  }

  void _onFilterSelected(String? specialty) {
    setState(() => _selectedFilter = specialty);
    context.read<DoctorsCubit>().filterBySpecialty(specialty);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        if (state is DoctorsLoading) {
          return const CircularProgressIndicator();
        }

        if (state is DoctorsLoaded) {
          final doctors = state.filteredDoctors ?? state.doctors;
          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return ListTile(title: Text(doctor.name));
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
```

---

## 6. جلب تفاصيل الطبيب والمواعيد المتاحة

```dart
BlocProvider(
  create: (_) => sl<DoctorDetailsCubit>()
    ..fetchDoctorDetailsAndSlots(
      doctorId,
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    ),
  child: _DoctorProfileView(doctorId: doctorId),
)
```

```dart
void _onDateSelected(DateTime date) {
  setState(() {
    _selectedDate = date;
    _selectedSlot = null;
  });

  context.read<DoctorDetailsCubit>().fetchSlotsForDate(
    widget.doctorId,
    DateFormat('yyyy-MM-dd').format(date),
  );
}
```

---

## 7. إنشاء حجز طبي عبر `BookingsCubit`

مثال مطابق لـ `BookingConfirmationScreen`:

```dart
void _confirmBooking() {
  context.read<BookingsCubit>().createDoctorBooking(
    doctorId: widget.doctorId,
    date: widget.bookingDate,
    time: widget.bookingTime,
  );
}

BlocConsumer<BookingsCubit, BookingsState>(
  listener: (context, state) {
    if (state is BookingCreated) {
      final queueNumber = state.booking.queueNumber ?? 0;
      _showSuccessDialog(queueNumber);
    } else if (state is BookingsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    final isLoading = state is BookingsLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : _confirmBooking,
      child: Text(isLoading ? 'جاري التأكيد...' : 'تأكيد الحجز'),
    );
  },
)
```

---

## 8. جلب الحجوزات الحالية للمريض

```dart
BlocProvider(
  create: (_) => sl<BookingsCubit>()..fetchMyBookings(),
  child: const PatientBookingsScreen(),
)
```

```dart
if (state is BookingsLoaded) {
  final upcoming = state.bookings.where((booking) {
    return booking.status == 'confirmed' ||
        booking.status == 'checked_in' ||
        booking.status == 'in_progress';
  }).toList();

  final history = state.bookings.where((booking) {
    return booking.status == 'completed' || booking.status == 'cancelled';
  }).toList();
}
```

---

## 9. التنقل بين تبويبات المريض من أي شاشة

المشروع لا يستخدم router مركزي؛ بل helper بسيط:

```dart
void navigateToPatientRootTab(BuildContext context, int index) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => PatientDashboardScreen(initialTabIndex: index),
    ),
    (route) => false,
  );
}
```

مثال استخدام:

```dart
bottomNavigationBar: AppBottomNavBar(
  currentIndex: 2,
  onTap: (index) {
    if (index == 2) return;
    navigateToPatientRootTab(context, index);
  },
)
```

---

## 10. تشغيل الطابور محليًا داخل `ClinicQueueCubit`

```dart
final queueCubit = context.read<ClinicQueueCubit>();

queueCubit.callPatient(patientId);
queueCubit.addDelayToActivePatient(minutes: 10);
queueCubit.completePatient(patientId);
```

أمثلة على القراءات:

```dart
final waitMinutes = queueCubit.waitMinutesFor(patient.id);
final patientsAhead = queueCubit.patientsAheadOf(patient.id);
final estimatedStart = queueCubit.estimatedStartMinutesFor(patient.id);
```

---

## 11. ربط زر `السجل الطبي`

هذا هو الأسلوب المستخدم الآن في `doctor_dashboard_screen.dart` و `consultation_view_screen.dart`:

```dart
Navigator.push(
  context,
  MaterialPageRoute<void>(
    builder: (_) => const MedicalRecordsScreen(),
  ),
);
```

ولتمرير مريض محدد من شاشة الاستشارة:

```dart
Navigator.push(
  context,
  MaterialPageRoute<void>(
    builder: (_) => MedicalRecordsScreen(patientId: widget.patientId),
  ),
);
```

---

## 12. الفلترة داخل الوصفة الطبية والتحاليل

مثال من `ConsultationViewScreen`:

```dart
final _prescriptionSearchController = TextEditingController();
final _labSearchController = TextEditingController();

Widget _buildSearchField({
  required TextEditingController controller,
  required String hintText,
}) {
  return TextField(
    controller: controller,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
    ),
  );
}
```

ومنطق المطابقة الحالي:

```dart
bool _matchesSearchQuery(String query, List<String> values) {
  final normalizedQuery = query.toLowerCase();

  for (final value in values) {
    final localizedValue = _localizedClinicalText(value).toLowerCase();
    if (value.toLowerCase().contains(normalizedQuery) ||
        localizedValue.contains(normalizedQuery)) {
      return true;
    }
  }

  return false;
}
```

---

## 13. تغيير الأسبوع داخل `ScheduleManagerScreen`

هذا جزء من الإصلاح الحالي لأسهم التنقل:

```dart
DateTime _weekStart = DateTime(2024, 10, 21);

void _changeWeek(int offset) {
  setState(() {
    _weekStart = _weekStart.add(Duration(days: offset * 7));
  });
}

DateTime _dateForIndex(int index) {
  return _weekStart.add(Duration(days: index));
}
```

واستخدامه في الأزرار:

```dart
IconButton(
  onPressed: () => _changeWeek(-1),
  icon: const Icon(Icons.chevron_left),
)

IconButton(
  onPressed: () => _changeWeek(1),
  icon: const Icon(Icons.chevron_right),
)
```

---

## 14. شاشة الإشعارات الحالية

`NotificationsScreen` موجودة فعليًا لكن ليست مدمجة بالكامل بعد:

```dart
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthCubit>().currentRole;

    return BlocBuilder<ClinicQueueCubit, ClinicQueueState>(
      builder: (context, queueState) {
        // Build local notification cards from role + queue state
      },
    );
  }
}
```

---

## 15. قراءة سريعة لحالة المشروع من الكود

إذا كنت تريد التحقق سريعًا من الواقع الحالي:

- ابحث عن الشاشات:

```bash
find lib/features -path '*/presentation/screens/*.dart' ! -name '*.backup' | sort
```

- راجع الملفات المشتركة:

```bash
find lib/core -type f | sort
```

- راجع التبعيات المسجلة:

```bash
sed -n '1,220p' lib/core/di/injection_container.dart
```

---

## ملاحظات دقة

- الأمثلة هنا مكتوبة بما يطابق signatures الحالية في المشروع
- لا يوجد ذكر لحالات أو ملفات غير موجودة فعليًا
- تم حذف الأمثلة القديمة التي كانت تشير إلى `OtpSending` أو بنى غير مستخدمة الآن
