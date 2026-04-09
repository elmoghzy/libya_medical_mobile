# Libya Medical - أمثلة برمجية (Code Examples) 💻

دليل شامل لكيفية استخدام الكود في المشروع مع أمثلة عملية.

---

## 📑 جدول المحتويات

1. [Authentication Examples](#authentication-examples)
2. [Doctors Feature Examples](#doctors-feature-examples)
3. [BLoC Pattern Examples](#bloc-pattern-examples)
4. [API Integration Examples](#api-integration-examples)
5. [Navigation Examples](#navigation-examples)
6. [Error Handling Examples](#error-handling-examples)

---

## 🔐 Authentication Examples

### مثال 1: تسجيل الدخول بـ OTP

```dart
// في LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  void _sendOtp() {
    final phone = _phoneController.text;
    
    // Validation
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم هاتف صحيح')),
      );
      return;
    }
    
    // Format phone number: +218XXXXXXXXX
    final formattedPhone = phone.startsWith('+') ? phone : '+$phone';
    
    // Call Cubit
    context.read<AuthCubit>().sendOtp(formattedPhone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          // Navigate to OTP Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                verificationId: state.verificationId,
                phoneNumber: state.phoneNumber,
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading || state is OtpSending;
        
        return Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                hintText: '+218912345678',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _sendOtp,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('إرسال رمز التحقق'),
            ),
          ],
        );
      },
    );
  }
}
```

### مثال 2: التحقق من OTP

```dart
// في OtpScreen
class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  void _verifyOtp() {
    final code = _otpController.text;
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز مكون من 6 أرقام')),
      );
      return;
    }
    
    context.read<AuthCubit>().verifyOtp(
      widget.verificationId,
      code,
      widget.phoneNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Navigate based on role
          if (state.role == UserRole.patient) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isVerifying = state is OtpVerifying;
        
        return Column(
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'رمز التحقق',
              ),
            ),
            ElevatedButton(
              onPressed: isVerifying ? null : _verifyOtp,
              child: isVerifying
                  ? const CircularProgressIndicator()
                  : const Text('تحقق'),
            ),
          ],
        );
      },
    );
  }
}
```

### مثال 3: تسجيل الخروج

```dart
// في أي شاشة
void _signOut() async {
  await context.read<AuthCubit>().signOut();
  
  if (mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

// في AppBar
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: _signOut,
    ),
  ],
)
```

### مثال 4: التحقق من حالة تسجيل الدخول

```dart
// في main.dart أو SplashScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final roleStr = prefs.getString('user_role');
    
    if (!mounted) return;
    
    if (token != null && roleStr != null) {
      // User is logged in
      final role = roleStr == 'patient' ? UserRole.patient : UserRole.doctor;
      
      if (role == UserRole.patient) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
        );
      }
    } else {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

---

## 👨‍⚕️ Doctors Feature Examples

### مثال 1: جلب قائمة الأطباء

```dart
// في DoctorSearchScreen
class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  @override
  void initState() {
    super.initState();
    // جلب الأطباء عند فتح الشاشة
    context.read<DoctorsCubit>().fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsCubit, DoctorsState>(
      builder: (context, state) {
        // Loading State
        if (state is DoctorsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        // Error State
        if (state is DoctorsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DoctorsCubit>().fetchDoctors();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        
        // Loaded State
        if (state is DoctorsLoaded) {
          final doctors = state.filteredDoctors ?? state.doctors;
          
          if (doctors.isEmpty) {
            return const Center(
              child: Text('لا يوجد أطباء متاحين'),
            );
          }
          
          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorCard(
                doctor: doctor,
                onTap: () => _navigateToProfile(doctor),
              );
            },
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  void _navigateToProfile(DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorProfileScreen(
          doctorId: doctor.id,
          doctorName: doctor.name,
        ),
      ),
    );
  }
}
```

### مثال 2: البحث والفلترة

```dart
// في DoctorSearchScreen
class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    
    // Listen to search changes
    _searchController.addListener(() {
      context.read<DoctorsCubit>().searchDoctors(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'ابحث عن طبيب أو تخصص',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<DoctorsCubit>().clearFilters();
                    },
                  )
                : null,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Specialty Filter
        BlocBuilder<DoctorsCubit, DoctorsState>(
          builder: (context, state) {
            List<String> specialties = [];
            
            if (state is DoctorsLoaded) {
              // Extract unique specialties
              specialties = state.doctors
                  .map((d) => d.specialty)
                  .toSet()
                  .toList()
                ..sort();
            }
            
            return DropdownButton<String>(
              value: _selectedSpecialty,
              hint: const Text('اختر التخصص'),
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('جميع التخصصات'),
                ),
                ...specialties.map((spec) {
                  return DropdownMenuItem(
                    value: spec,
                    child: Text(spec),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedSpecialty = value);
                context.read<DoctorsCubit>().filterBySpecialty(value);
              },
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Results
        Expanded(
          child: BlocBuilder<DoctorsCubit, DoctorsState>(
            builder: (context, state) {
              // ... بناء القائمة
            },
          ),
        ),
      ],
    );
  }
}
```

### مثال 3: صفحة الدكتور مع المواعيد

```dart
// في DoctorProfileScreen
class _DoctorProfileViewState extends State<_DoctorProfileView> {
  late DateTime _selectedDate;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
      builder: (context, state) {
        // Loading
        if (state is DoctorDetailsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Error
        if (state is DoctorDetailsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text(state.message),
                ElevatedButton(
                  onPressed: () {
                    context.read<DoctorDetailsCubit>()
                        .fetchDoctorDetailsAndSlots(
                          widget.doctorId,
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                        );
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        
        // Loaded
        if (state is DoctorDetailsLoaded || state is SlotsLoading) {
          final doctor = state is DoctorDetailsLoaded 
              ? state.doctor 
              : (state as SlotsLoading).doctor;
          
          final slots = state is DoctorDetailsLoaded 
              ? state.availableSlots?.slots ?? []
              : [];
          
          final isLoadingSlots = state is SlotsLoading;
          
          return Column(
            children: [
              // Doctor Info Card
              _buildDoctorInfo(doctor),
              
              const SizedBox(height: 24),
              
              // Date Picker
              _buildDatePicker(),
              
              const SizedBox(height: 24),
              
              // Time Slots
              if (isLoadingSlots)
                const CircularProgressIndicator()
              else if (slots.isEmpty)
                const Text('لا توجد مواعيد متاحة في هذا اليوم')
              else
                _buildTimeSlots(slots),
              
              const Spacer(),
              
              // Book Button
              _buildBookButton(doctor),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDatePicker() {
    final dates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null;
              });
              
              context.read<DoctorDetailsCubit>().fetchSlotsForDate(
                widget.doctorId,
                DateFormat('yyyy-MM-dd').format(date),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primary 
                      : AppColors.surfaceContainerLow,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected 
                          ? AppColors.onPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? AppColors.onPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(List<String> slots) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slots.map((slot) {
        final isSelected = _selectedSlot == slot;
        
        // Convert 24h to 12h format
        final time = _formatTime24To12(slot);
        
        return GestureDetector(
          onTap: () {
            setState(() => _selectedSlot = slot);
            context.read<DoctorDetailsCubit>().selectSlot(slot);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primary 
                    : AppColors.surfaceContainerLow,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected 
                    ? AppColors.onPrimary 
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTime24To12(String time24) {
    // "09:00" → "9:00 AM"
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '$hour:$minute $period';
  }

  Widget _buildBookButton(DoctorModel doctor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _selectedSlot == null ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingConfirmationScreen(
                doctorId: doctor.id,
                doctorName: doctor.name,
                specialty: doctor.specialty,
                fee: doctor.consultationFee,
                date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                time: _formatTime24To12(_selectedSlot!),
                bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
                bookingTime: _selectedSlot,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text('احجز الآن'),
      ),
    );
  }
}
```

---

## 🎯 BLoC Pattern Examples

### مثال 1: إنشاء Cubit جديد

```dart
// State
sealed class BookingsState extends Equatable {
  const BookingsState();
  
  @override
  List<Object?> get props => [];
}

final class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

final class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

final class BookingCreated extends BookingsState {
  const BookingCreated({required this.booking});
  
  final BookingModel booking;
  
  @override
  List<Object?> get props => [booking];
}

final class BookingsError extends BookingsState {
  const BookingsError({required this.message});
  
  final String message;
  
  @override
  List<Object?> get props => [message];
}

// Cubit
class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit({required IBookingsRemoteDataSource bookingsDataSource})
      : _bookingsDataSource = bookingsDataSource,
        super(const BookingsInitial());

  final IBookingsRemoteDataSource _bookingsDataSource;

  Future<void> createBooking({
    required int doctorId,
    required String bookingDate,
    required String bookingTime,
  }) async {
    emit(const BookingsLoading());

    try {
      final booking = await _bookingsDataSource.createBooking(
        bookableType: 'doctor',
        bookableId: doctorId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
      );

      emit(BookingCreated(booking: booking));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'فشل إنشاء الحجز';
      emit(BookingsError(message: message));
    } catch (e) {
      emit(BookingsError(message: 'حدث خطأ: ${e.toString()}'));
    }
  }
}
```

### مثال 2: استخدام BlocProvider

```dart
// في الشاشة الرئيسية
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
        ),
        BlocProvider<DoctorsCubit>(
          create: (_) => sl<DoctorsCubit>(),
        ),
      ],
      child: MaterialApp(
        home: const SplashScreen(),
      ),
    );
  }
}

// أو في شاشة فردية
class DoctorProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorDetailsCubit>()
        ..fetchDoctorDetailsAndSlots(doctorId, date),
      child: _DoctorProfileView(),
    );
  }
}
```

### مثال 3: BlocListener vs BlocBuilder vs BlocConsumer

```dart
// BlocListener - للأحداث (Navigation, SnackBar)
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: LoginForm(),
)

// BlocBuilder - لبناء UI
BlocBuilder<DoctorsCubit, DoctorsState>(
  builder: (context, state) {
    if (state is DoctorsLoading) {
      return const CircularProgressIndicator();
    }
    if (state is DoctorsLoaded) {
      return DoctorsList(doctors: state.doctors);
    }
    return const SizedBox.shrink();
  },
)

// BlocConsumer - كلاهما معاً
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    // Handle side effects
  },
  builder: (context, state) {
    // Build UI
  },
)
```

---

## 🌐 API Integration Examples

### مثال 1: إنشاء Data Source

```dart
// Interface
abstract class IBookingsRemoteDataSource {
  Future<BookingModel> createBooking({
    required String bookableType,
    required int bookableId,
    required String bookingDate,
    required String bookingTime,
    String? endDate,
  });
  
  Future<List<BookingModel>> getMyBookings();
  Future<BookingModel> cancelBooking(int bookingId);
}

// Implementation
class BookingsRemoteDataSource implements IBookingsRemoteDataSource {
  final DioClient _dioClient = DioClient.instance;

  @override
  Future<BookingModel> createBooking({
    required String bookableType,
    required int bookableId,
    required String bookingDate,
    required String bookingTime,
    String? endDate,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.bookings,
        data: {
          'bookable_type': bookableType,
          'bookable_id': bookableId,
          'booking_date': bookingDate,
          'booking_time': bookingTime,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['success'] == true) {
        return BookingModel.fromJson(response.data['data']);
      } else {
        throw BookingsException(
          message: response.data['message'] ?? 'Failed to create booking',
        );
      }
    } on DioException catch (e) {
      throw BookingsException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        code: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.bookings);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw BookingsException(
          message: response.data['message'] ?? 'Failed to fetch bookings',
        );
      }
    } on DioException catch (e) {
      throw BookingsException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        code: e.response?.statusCode,
      );
    }
  }
}
```

### مثال 2: Custom Exception

```dart
class BookingsException implements Exception {
  BookingsException({
    required this.message,
    this.code,
  });

  final String message;
  final int? code;

  @override
  String toString() => 'BookingsException: $message (code: $code)';
}
```

---

## 🧭 Navigation Examples

### مثال 1: Navigation بسيط

```dart
// Push
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const NextScreen()),
);

// Push with data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DoctorProfileScreen(
      doctorId: doctor.id,
      doctorName: doctor.name,
    ),
  ),
);

// Pop
Navigator.pop(context);

// Pop with result
Navigator.pop(context, 'result');
```

### مثال 2: Navigation مع Replacement

```dart
// Replace current screen
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const DashboardScreen()),
);

// Clear stack and navigate
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (route) => false,
);
```

---

## ⚠️ Error Handling Examples

### مثال 1: Try-Catch في Cubit

```dart
Future<void> fetchData() async {
  emit(const DataLoading());

  try {
    final data = await _dataSource.getData();
    emit(DataLoaded(data: data));
  } on DioException catch (e) {
    // Network errors
    if (e.type == DioExceptionType.connectionTimeout) {
      emit(const DataError(message: 'انتهت مهلة الاتصال'));
    } else if (e.type == DioExceptionType.connectionError) {
      emit(const DataError(message: 'لا يوجد اتصال بالإنترنت'));
    } else if (e.response?.statusCode == 401) {
      emit(const DataError(message: 'غير مصرح لك'));
    } else if (e.response?.statusCode == 422) {
      final errors = e.response?.data['errors'];
      emit(DataError(message: errors.toString()));
    } else {
      emit(DataError(message: e.message ?? 'حدث خطأ في الشبكة'));
    }
  } on CustomException catch (e) {
    emit(DataError(message: e.message));
  } catch (e) {
    emit(DataError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
  }
}
```

### مثال 2: Error Widget

```dart
Widget buildErrorWidget(String message, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}
```

---

## 🎨 UI Component Examples

### مثال 1: Custom Button

```dart
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
```

### مثال 2: Doctor Card Component

```dart
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  doctor.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.consultationFee} دينار',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

هذه الأمثلة تغطي معظم الحالات الشائعة في المشروع. استخدمها كمرجع عند كتابة كود جديد! 🚀
