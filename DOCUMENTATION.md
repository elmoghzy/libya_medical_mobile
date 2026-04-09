# Libya Medical Mobile App - التوثيق الشامل 📱

## 📋 نظرة عامة

**Libya Medical** هو تطبيق Flutter لإدارة الحجوزات الطبية في ليبيا. يربط المرضى بالأطباء ويوفر نظام حجز متطور مع تتبع قوائم الانتظار (Queue Tracking).

### 🎯 الهدف من التطبيق

- حجز مواعيد مع الأطباء بسهولة
- تتبع قوائم الانتظار في الوقت الفعلي
- حجز الغرف الطبية
- إدارة الإشعارات
- مصادقة آمنة باستخدام Firebase OTP

---

## 🏗️ معمارية المشروع (Clean Architecture)

المشروع يتبع **Clean Architecture Pattern** مع **BLoC/Cubit** لإدارة الحالة:

```
lib/
├── core/                           # المكونات المشتركة
│   ├── di/                         # Dependency Injection
│   │   └── injection_container.dart
│   ├── network/                    # طبقة الشبكة
│   │   ├── dio_client.dart        # HTTP Client
│   │   └── api_constants.dart     # API URLs
│   ├── theme/                      # تصميم التطبيق
│   │   └── app_colors.dart
│   └── widgets/                    # Widgets مشتركة
│       ├── bottom_nav_bar.dart
│       └── app_top_bar.dart
│
├── features/                       # الميزات الرئيسية
│   ├── auth/                       # Authentication Feature
│   │   ├── data/
│   │   │   ├── auth_models.dart
│   │   │   └── auth_remote_data_source.dart
│   │   ├── logic/
│   │   │   ├── auth_cubit.dart
│   │   │   └── auth_state.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── otp_screen.dart
│   │
│   ├── doctors/                    # Doctors Feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── doctor_model.dart
│   │   │   └── datasources/
│   │   │       └── doctors_remote_data_source.dart
│   │   ├── logic/
│   │   │   ├── doctors_cubit.dart
│   │   │   ├── doctor_details_cubit.dart
│   │   │   └── doctors_state.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── doctor_search_screen.dart
│   │           ├── doctor_profile_screen.dart
│   │           └── ...
│   │
│   ├── bookings/                   # Bookings Feature
│   │   └── presentation/
│   │       └── screens/
│   │           └── booking_confirmation_screen.dart
│   │
│   └── home/                       # Home & Dashboards
│       └── presentation/
│           └── screens/
│               ├── splash_screen.dart
│               ├── patient_dashboard_screen.dart
│               └── doctor_dashboard_screen.dart
│
└── main.dart                       # نقطة البداية
```

---

## 📦 التقنيات المستخدمة

### Dependencies الرئيسية

```yaml
dependencies:
  flutter_bloc: ^9.1.1          # State Management
  equatable: ^2.0.8             # Value Equality
  dio: ^5.9.2                   # HTTP Client
  get_it: ^9.2.1                # Dependency Injection
  shared_preferences: ^2.5.5    # Local Storage
  intl: ^0.20.2                 # Date Formatting
  
  # Firebase Authentication
  firebase_core: ^3.13.0
  firebase_auth: ^5.6.1
```

### المعمارية

- **State Management:** BLoC/Cubit Pattern
- **DI:** GetIt (Service Locator)
- **HTTP Client:** Dio with Interceptors
- **Local Storage:** SharedPreferences
- **Authentication:** Firebase Phone Auth + Laravel Sanctum

---

## 🔐 نظام المصادقة (Authentication)

### تدفق المصادقة (Auth Flow)

```
1. المستخدم يدخل رقم الهاتف (+218XXXXXXXXX)
   ↓
2. LoginScreen → sendOtp()
   ↓
3. Firebase يرسل SMS code
   ↓
4. OtpSent state → navigate to OtpScreen
   ↓
5. المستخدم يدخل 6 أرقام
   ↓
6. OtpScreen → verifyOtp()
   ↓
7. Firebase Verification → get UID
   ↓
8. Laravel API: POST /api/auth/verify-phone
   Request: { phone: "+218...", firebase_uid: "..." }
   Response: { token: "...", role: "patient", user: {...} }
   ↓
9. حفظ Token + Role في SharedPreferences
   ↓
10. AuthSuccess → navigate حسب الـ role
    - patient → PatientDashboardScreen
    - doctor → DoctorDashboardScreen
```

### الملفات الرئيسية

#### `lib/features/auth/data/auth_models.dart`

```dart
enum UserRole { patient, doctor }

class AuthResponse {
  final String token;
  final UserRole role;
  final UserModel user;
}

class UserModel {
  final int id;
  final String name;
  final String phone;
  final UserRole role;
}
```

#### `lib/features/auth/data/auth_remote_data_source.dart`

**Methods:**
- `sendOtp(String phoneNumber)` - يرسل OTP عبر Firebase
- `verifyOtp(String verificationId, String smsCode)` - يتحقق من الكود
- `authenticateWithBackend(String uid, String phone)` - يتصل بـ Laravel API
- `signOut()` - تسجيل الخروج

#### `lib/features/auth/logic/auth_state.dart`

```dart
sealed class AuthState extends Equatable {
  - AuthInitial
  - AuthLoading
  - OtpSending
  - OtpSent(String verificationId, String phoneNumber)
  - OtpVerifying
  - AuthSuccess(UserRole role, UserModel user)
  - AuthError(String message)
}
```

#### `lib/features/auth/logic/auth_cubit.dart`

**Methods:**
- `sendOtp(String phoneNumber)`
- `verifyOtp(String verificationId, String smsCode, String phoneNumber)`
- `resendOtp(String phoneNumber)`
- `signOut()`

---

## 👨‍⚕️ ميزة الأطباء (Doctors Feature)

### Data Models

#### `lib/features/doctors/data/models/doctor_model.dart`

```dart
class DoctorModel {
  final int id;
  final String name;
  final String specialty;
  final String consultationFee;
  final bool isActive;
  final List<ScheduleModel>? schedules;
}

class ScheduleModel {
  final int id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int avgConsultationTime;
}

class AvailableSlotsModel {
  final List<ScheduleModel> schedules;
  final List<String> slots;  // ["09:00", "09:20", "09:40"]
}
```

### Data Source

#### `lib/features/doctors/data/datasources/doctors_remote_data_source.dart`

**Methods:**

```dart
// GET /api/doctors
Future<List<DoctorModel>> getDoctors()

// GET /api/doctors/{id}
Future<DoctorModel> getDoctorDetails(int doctorId)

// GET /api/doctors/{id}/slots?date=YYYY-MM-DD
Future<AvailableSlotsModel> getAvailableSlots(int doctorId, String date)
```

### State Management

#### `lib/features/doctors/logic/doctors_cubit.dart`

**للقائمة الرئيسية:**

```dart
Methods:
  - fetchDoctors()           // جلب جميع الأطباء
  - refreshDoctors()         // تحديث القائمة
  - searchDoctors(query)     // البحث بالاسم أو التخصص
  - filterBySpecialty(spec)  // فلتر بالتخصص
  - clearFilters()           // إزالة الفلاتر
```

**States:**
- `DoctorsInitial`
- `DoctorsLoading`
- `DoctorsLoaded(doctors, filteredDoctors, searchQuery, selectedSpecialty)`
- `DoctorsError(message, code)`

#### `lib/features/doctors/logic/doctor_details_cubit.dart`

**لصفحة الدكتور الواحد:**

```dart
Methods:
  - fetchDoctorDetailsAndSlots(doctorId, date)  // جلب التفاصيل + المواعيد
  - fetchDoctorDetails(doctorId)                // التفاصيل فقط
  - fetchSlotsForDate(doctorId, date)           // المواعيد فقط
  - selectSlot(slot)                            // اختيار موعد
  - clearSelectedSlot()                         // إلغاء الاختيار
  - reset()                                     // إعادة تعيين
```

**States:**
- `DoctorDetailsInitial`
- `DoctorDetailsLoading`
- `DoctorDetailsLoaded(doctor, availableSlots, selectedDate, selectedSlot)`
- `SlotsLoading(doctor, selectedDate)` - للتحديثات الجزئية
- `DoctorDetailsError(message)`

**Features:**
- ✅ Caching: الدكتور يُحفظ مؤقتاً لتجنب إعادة التحميل عند تغيير التاريخ
- ✅ Parallel Fetching: جلب التفاصيل والمواعيد معاً
- ✅ Partial Updates: تحديث المواعيد فقط عند تغيير التاريخ

### UI Screens

#### `lib/features/doctors/presentation/screens/doctor_search_screen.dart`

**Features:**
- ✅ Search Bar - البحث بالاسم أو التخصص
- ✅ Specialty Filter - فلتر التخصصات
- ✅ Doctor Cards - عرض البطاقات مع الصور
- ✅ Pull to Refresh - التحديث بالسحب
- ✅ Loading State - مؤشر التحميل
- ✅ Error Handling - معالجة الأخطاء
- ✅ Empty State - حالة القائمة الفارغة

**BLoC Integration:**
```dart
BlocBuilder<DoctorsCubit, DoctorsState>(
  builder: (context, state) {
    if (state is DoctorsLoading) return Loading();
    if (state is DoctorsError) return ErrorWidget();
    if (state is DoctorsLoaded) return DoctorsList();
  }
)
```

#### `lib/features/doctors/presentation/screens/doctor_profile_screen.dart`

**Features:**
- ✅ Doctor Info - الاسم، التخصص، السعر
- ✅ Date Picker - اختيار التاريخ (7 أيام قادمة)
- ✅ Time Slots - عرض المواعيد المتاحة
- ✅ 12-Hour Format - تنسيق الوقت (9:00 AM)
- ✅ Slot Selection - اختيار الموعد
- ✅ Loading Indicators - مؤشرات التحميل
- ✅ Auto-Refresh Slots - تحديث تلقائي عند تغيير التاريخ

**Flow:**
```dart
1. BlocProvider creates DoctorDetailsCubit
2. fetchDoctorDetailsAndSlots(doctorId, todayDate)
3. User selects date → fetchSlotsForDate(doctorId, newDate)
4. User selects slot → selectSlot(slot)
5. User taps "احجز الآن" → Navigate to BookingConfirmationScreen
```

---

## 🔗 تكامل API (API Integration)

### Base Configuration

**File:** `lib/core/network/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000';  // Android Emulator
  static const String apiPath = '/api';
  
  // Auth Endpoints
  static const String verifyPhone = '/auth/verify-phone';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  
  // Doctors Endpoints
  static const String doctors = '/doctors';
  static String doctorDetails(int id) => '/doctors/$id';
  static String doctorSlots(int id) => '/doctors/$id/slots';
  
  // Bookings Endpoints
  static const String bookings = '/bookings';
  static String bookingDetails(int id) => '/bookings/$id';
  static String queueStatus(int id) => '/bookings/$id/queue-status';
  static String cancelBooking(int id) => '/bookings/$id/cancel';
  static String checkIn(int id) => '/bookings/$id/check-in';
}
```

### HTTP Client

**File:** `lib/core/network/dio_client.dart`

```dart
class DioClient {
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;
  
  late Dio _dio;
  
  Features:
    ✅ Singleton Pattern
    ✅ Request/Response Interceptors
    ✅ Auto Token Injection
    ✅ Error Handling
    ✅ Logging
}
```

### API Response Format

#### Standard Response (معظم Endpoints)

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

#### Auth Verify-Phone Response (استثناء)

```json
{
  "token": "1|xxxx",
  "role": "patient",
  "user": {
    "id": 1,
    "name": "Name",
    "phone": "+218..."
  }
}
```

### Error Handling

```dart
try {
  final result = await dataSource.fetchData();
  emit(Success(result));
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    emit(Error('Unauthorized'));
  } else if (e.response?.statusCode == 422) {
    emit(Error('Validation Error'));
  } else {
    emit(Error('Network Error'));
  }
} catch (e) {
  emit(Error('Unexpected Error: $e'));
}
```

---

## 💉 حقن التبعيات (Dependency Injection)

**File:** `lib/core/di/injection_container.dart`

```dart
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============ External ============
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // ============ Data Sources ============
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSource()
  );
  
  sl.registerLazySingleton<IDoctorsRemoteDataSource>(
    () => DoctorsRemoteDataSource()
  );

  // ============ Cubits ============
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      authDataSource: sl<IAuthRemoteDataSource>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );
  
  sl.registerFactory<DoctorsCubit>(
    () => DoctorsCubit(
      doctorsDataSource: sl<IDoctorsRemoteDataSource>(),
    ),
  );
  
  sl.registerFactory<DoctorDetailsCubit>(
    () => DoctorDetailsCubit(
      doctorsDataSource: sl<IDoctorsRemoteDataSource>(),
    ),
  );
}
```

### استخدام DI في التطبيق

```dart
// في main.dart
void main() async {
  await initDependencies();
  runApp(MyApp());
}

// في الشاشات
BlocProvider(
  create: (_) => sl<AuthCubit>(),
  child: LoginScreen(),
)

// أو مباشرة
context.read<DoctorsCubit>().fetchDoctors();
```

---

## 🎨 نظام التصميم (Design System)

### الألوان (Colors)

**File:** `lib/core/theme/app_colors.dart`

```dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00435A);
  static const Color primaryContainer = Color(0xFF005C7A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF64D8D8);
  static const Color onSecondary = Color(0xFF003738);
  
  // Tertiary Colors
  static const Color tertiary = Color(0xFF004546);
  static const Color tertiaryFixedDim = Color(0xFF64D8D8);
  
  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color onSurface = Color(0xFF191C1D);
  
  // Status Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF64D8D8);
  static const Color warning = Color(0xFFF59E0B);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF191C1D);
  static const Color textSecondary = Color(0xFF3F4948);
  static const Color textDisabled = Color(0xFF7A8C8A);
}
```

### الـ Widgets المشتركة

#### `lib/core/widgets/bottom_nav_bar.dart`

```dart
BottomNavBar({
  required int currentIndex,
  required Function(int) onTap,
  bool isDoctor = false,
})

Screens:
  - Patient: Home, Search, Queue, Notifications, Profile
  - Doctor: Home, Schedule, Queue, Notifications, Profile
```

#### `lib/core/widgets/app_top_bar.dart`

```dart
AppTopBar({
  String? title,
  bool showBack = false,
  List<Widget>? actions,
})
```

---

## 📱 الشاشات المنفذة (Implemented Screens)

### ✅ Auth Screens
1. **Splash Screen** - شاشة البداية
2. **Login Screen** - تسجيل الدخول بـ OTP
3. **OTP Screen** - إدخال رمز التحقق
4. **Profile Setup Screen** - إعداد الملف الشخصي

### ✅ Patient Screens
5. **Patient Dashboard** - لوحة التحكم للمريض
6. **Doctor Search** - البحث عن الأطباء
7. **Doctor Profile** - ملف الطبيب + المواعيد
8. **Booking Confirmation** - تأكيد الحجز
9. **Facility Listing** - قائمة الغرف
10. **Queue Tracker** - تتبع قائمة الانتظار

### ✅ Doctor Screens
11. **Doctor Dashboard** - لوحة التحكم للطبيب
12. **Clinic Queue Manager** - إدارة قائمة الانتظار
13. **Consultation View** - عرض الاستشارة
14. **Schedule Manager** - إدارة الجدول

---

## 🚀 كيفية التشغيل

### المتطلبات

```bash
# Flutter SDK
flutter --version
# Flutter 3.x or higher

# Firebase CLI (Optional)
npm install -g firebase-tools

# Android Studio / VS Code
# Android Emulator أو جهاز حقيقي
```

### خطوات التشغيل

#### 1. Clone المشروع

```bash
git clone [repository-url]
cd libya_medical_mobile
```

#### 2. تثبيت Dependencies

```bash
flutter pub get
```

#### 3. إعداد Firebase

```bash
# تأكد من وجود
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

#### 4. تشغيل Laravel Backend

```bash
# في مجلد Laravel API
php artisan serve
# سيعمل على http://localhost:8000
```

#### 5. تشغيل التطبيق

```bash
# تشغيل على Emulator
flutter run

# أو build APK
flutter build apk --release

# APK موجود في:
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔧 الإعدادات المهمة

### تغيير Base URL

**في حالة استخدام Laravel على السيرفر:**

```dart
// lib/core/network/api_constants.dart
class ApiConstants {
  // للـ Android Emulator → localhost
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  // للـ iOS Simulator → localhost
  static const String baseUrl = 'http://localhost:8000';
  
  // للجهاز الحقيقي → IP Address
  static const String baseUrl = 'http://192.168.1.X:8000';
  
  // للـ Production
  static const String baseUrl = 'https://your-domain.com';
}
```

### تنسيق رقم الهاتف

```dart
// Firebase يحتاج: +218XXXXXXXXX
// Laravel API يحتاج: 218XXXXXXXXX (بدون +)

// في auth_remote_data_source.dart
String formatPhoneForFirebase(String phone) {
  if (!phone.startsWith('+')) return '+$phone';
  return phone;
}

String formatPhoneForApi(String phone) {
  return phone.replaceFirst('+', '');
}
```

---

## 📊 حالة المشروع (Project Status)

### ✅ مكتمل (Completed)

| Feature | Progress | Files |
|---------|----------|-------|
| **Auth System** | 100% | 6 files |
| **Doctors List** | 100% | 5 files |
| **Doctor Profile** | 100% | 3 files |
| **Search & Filter** | 100% | Integrated |
| **Available Slots** | 100% | Integrated |
| **UI Screens** | 100% | 14 screens |
| **DI Setup** | 100% | 1 file |
| **Network Layer** | 100% | 2 files |

### 🚧 قيد التنفيذ (In Progress)

| Feature | Progress | Status |
|---------|----------|--------|
| **Bookings Creation** | 20% | تحتاج `POST /api/bookings` |
| **Rooms Feature** | 0% | لم تبدأ |
| **Queue Tracking** | 0% | UI جاهز، تحتاج API |
| **Notifications** | 0% | لم تبدأ |

### 📝 الخطوات القادمة (Next Steps)

#### Phase 1: Bookings Feature

```
□ Create BookingsRemoteDataSource
  - POST /api/bookings
  - GET /api/bookings
  - POST /api/bookings/{id}/cancel

□ Create BookingsCubit + States
  - createBooking()
  - fetchMyBookings()
  - cancelBooking()

□ Update BookingConfirmationScreen
  - API integration
  - Success/Error handling
  - Navigation
```

#### Phase 2: Rooms Feature

```
□ Create RoomsRemoteDataSource
  - GET /api/rooms?booking_date=X&end_date=Y

□ Create RoomsCubit + States
  - fetchRooms()
  - filterByDate()

□ Update FacilityListingScreen
  - BLoC integration
  - Real data
```

#### Phase 3: Queue Tracking

```
□ Create QueueRemoteDataSource
  - GET /api/bookings/{id}/queue-status
  - POST /api/bookings/{id}/check-in

□ Create QueueCubit + States
  - fetchQueueStatus()
  - checkIn()
  - Auto-refresh every X seconds

□ Update QueueTrackerScreen
  - Real-time updates
  - WebSocket (optional)
```

#### Phase 4: Notifications

```
□ Create NotificationsRemoteDataSource
  - GET /api/notifications
  - POST /api/notifications/{id}/read
  - POST /api/notifications/device-token

□ Setup FCM (Firebase Cloud Messaging)
  - Device token registration
  - Background notifications
  - Foreground handlers

□ Create NotificationsCubit + States
  - fetchNotifications()
  - markAsRead()
```

---

## 🐛 المشاكل الشائعة (Common Issues)

### 1. Firebase Auth Error

```
Error: PERMISSION_DENIED
```

**الحل:**
- تأكد من تفعيل Phone Authentication في Firebase Console
- تأكد من وجود `google-services.json` و `GoogleService-Info.plist`

### 2. Network Error

```
DioException: Connection refused
```

**الحل:**
```dart
// Android Emulator → 10.0.2.2
// iOS Simulator → localhost
// Real Device → Your Computer's IP (192.168.1.X)

// تأكد من Laravel يعمل:
php artisan serve --host=0.0.0.0
```

### 3. Gradle Build Error

```
Corrupted cache
```

**الحل:**
```bash
flutter clean
rm -rf ~/.gradle/caches/
flutter pub get
flutter build apk
```

### 4. BLoC State Not Updating

```dart
// ❌ Wrong
context.read<AuthCubit>().state;

// ✅ Correct
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) { ... }
)
```

---

## 📚 الموارد والمراجع (Resources)

### Documentation

- [Flutter Docs](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev/)
- [Dio Package](https://pub.dev/packages/dio)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [GetIt DI](https://pub.dev/packages/get_it)

### Laravel API

- **Base URL:** `{{APP_URL}}/api`
- **Documentation:** `LIBYA_MEDICAL_API_DOCS.md` (مرفق مع المشروع)

### Design Assets

- **Figma/HTML:** `/path/to/stitch.zip` (التصميمات الأصلية)
- **Icons:** Material Icons + Custom Assets

---

## 👥 الفريق (Team)

- **Mobile Developer:** Flutter + Clean Architecture
- **Backend Developer:** Laravel API + Firebase
- **UI/UX Designer:** HTML Mockups
- **Product Owner:** Libya Medical Team

---

## 📄 الترخيص (License)

هذا المشروع ملك لـ **Libya Medical** ومحمي بحقوق الطبع والنشر.

---

## 📞 الدعم (Support)

للمساعدة أو الأسئلة:
- **Email:** support@libya-medical.ly
- **Phone:** +218 XXX XXX XXX

---

## 🎯 الخلاصة

المشروع في حالة ممتازة مع:
- ✅ Auth System كامل ومتكامل
- ✅ Doctors Feature كامل (List + Details + Slots)
- ✅ Clean Architecture بشكل صحيح
- ✅ BLoC Pattern متبع بدقة
- ✅ UI Screens جميعها منفذة
- 🚧 Bookings, Rooms, Queue, Notifications تحتاج API Integration

**الخطوة التالية المقترحة:** إكمال **Bookings Feature** لإتمام رحلة المستخدم الكاملة من البحث → الحجز → التتبع.

---

**آخر تحديث:** 2026-04-08  
**الإصدار:** 1.0.0-alpha
