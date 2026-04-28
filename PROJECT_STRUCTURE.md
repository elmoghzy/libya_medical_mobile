# Libya Medical - بنية المشروع الحالية

هذا الملف يصف **البنية الفعلية الحالية** للمشروع داخل الـ workspace بتاريخ `2026-04-18`.

---

## إحصائيات فعلية

```text
lib/ Dart files (excluding .backup): 46
core/ files: 10
features/ files: 35
presentation/screens files: 20
Approx. Dart LOC inside lib/: 18,569
```

---

## الشجرة الفعلية

```text
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   └── locale_cubit.dart
│   ├── network/
│   │   ├── api_constants.dart
│   │   └── dio_client.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app_top_bar.dart
│       ├── bottom_nav_bar.dart
│       └── notifications_screen.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_models.dart
│   │   │   └── auth_remote_data_source.dart
│   │   ├── logic/
│   │   │   ├── auth_cubit.dart
│   │   │   └── auth_state.dart
│   │   ├── presentation/
│   │   │   └── screens/
│   │   │       ├── login_screen.dart
│   │   │       ├── onboarding_screen.dart
│   │   │       ├── otp_screen.dart
│   │   │       ├── phone_verification_screen.dart
│   │   │       ├── profile_setup_screen.dart
│   │   │       └── splash_screen.dart
│   │   └── widgets/
│   │       └── auth_toggle_button.dart
│   │
│   ├── bookings/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── bookings_remote_data_source.dart
│   │   │   └── models/
│   │   │       └── booking_model.dart
│   │   ├── logic/
│   │   │   ├── bookings_cubit.dart
│   │   │   └── bookings_state.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── booking_confirmation_screen.dart
│   │
│   ├── doctors/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── doctors_remote_data_source.dart
│   │   │   └── models/
│   │   │       └── doctor_model.dart
│   │   ├── logic/
│   │   │   ├── doctor_details_cubit.dart
│   │   │   ├── doctors_cubit.dart
│   │   │   └── doctors_state.dart
│   │   └── presentation/
│   │       └── screens/
│   │           ├── clinic_queue_manager_screen.dart
│   │           ├── consultation_view_screen.dart
│   │           ├── doctor_dashboard_screen.dart
│   │           ├── doctor_profile_screen.dart
│   │           ├── doctor_search_screen.dart
│   │           ├── medical_records_screen.dart
│   │           └── schedule_manager_screen.dart
│   │
│   ├── facilities/
│   │   └── presentation/
│   │       └── screens/
│   │           └── facility_listing_screen.dart
│   │
│   ├── home/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── patient_bookings_screen.dart
│   │           ├── patient_dashboard_screen.dart
│   │           ├── patient_profile_screen.dart
│   │           └── patient_tab_navigation.dart
│   │
│   └── queue/
│       ├── logic/
│       │   └── clinic_queue_cubit.dart
│       └── presentation/
│           └── screens/
│               └── queue_tracker_screen.dart
│
└── main.dart
```

---

## ملاحظات بنيوية مهمة

### 1. لا توجد modules مستقلة للغرف أو الإشعارات

على عكس بعض الوثائق القديمة، المشروع **لا يحتوي** على:

- `features/rooms`
- `features/notifications`

بدلًا من ذلك:

- منطق الغرف موجود جزئيًا داخل `bookings`
- شاشة الإشعارات موجودة في `core/widgets/notifications_screen.dart`

### 2. `patient_tab_navigation.dart` ليس شاشة فعلية

هذا الملف موجود داخل `presentation/screens` لكنه helper تنقل فقط:

```dart
void navigateToPatientRootTab(BuildContext context, int index)
```

### 3. هناك ملف backup واحد يجب تجاهله

الملف:

```text
lib/features/bookings/presentation/screens/booking_confirmation_screen.dart.backup
```

هذا الملف ليس جزءًا من التطبيق الفعلي الجاري العمل عليه.

---

## تصنيف الملفات حسب الوظيفة

## Core

### Dependency Injection

- `core/di/injection_container.dart`

### Localization

- `core/localization/app_localizations.dart`
- `core/localization/locale_cubit.dart`

### Network

- `core/network/api_constants.dart`
- `core/network/dio_client.dart`

ملاحظة حالية:

- `ApiConstants` يتضمن الآن endpoint إضافي للمصادقة:
  - `/auth/check-doctor-phone`

### Theme

- `core/theme/app_colors.dart`
- `core/theme/app_theme.dart`

### Shared Widgets

- `core/widgets/app_top_bar.dart`
- `core/widgets/bottom_nav_bar.dart`
- `core/widgets/notifications_screen.dart`

---

## Features حسب المصدر

## API-backed بدرجة واضحة

- `auth`
- `doctors`
- `bookings`

## Local state / simulated

- `queue`
- أجزاء كبيرة من `doctors/presentation/screens`
- أجزاء من `home`

## Static / mock-heavy UI

- `facilities`
- أجزاء من `profile`, `schedule`, `medical records`

---

## الشاشات الفعلية حسب المجال

## Auth Screens

- `LoginScreen`
- `OnboardingScreen`
- `OtpScreen`
- `PhoneVerificationScreen`
- `ProfileSetupScreen`
- `SplashScreen`

## Patient / Shared Screens

- `PatientDashboardScreen`
- `PatientBookingsScreen`
- `PatientProfileScreen`
- `DoctorSearchScreen`
- `DoctorProfileScreen`
- `BookingConfirmationScreen`
- `FacilityListingScreen`
- `QueueTrackerScreen`

## Doctor Screens

- `DoctorDashboardScreen`
- `ClinicQueueManagerScreen`
- `ConsultationViewScreen`
- `ScheduleManagerScreen`
- `MedicalRecordsScreen`

---

## أهم الملفات حسب المسؤولية

### App Bootstrap

- `main.dart`
  - Firebase init
  - DI init
  - MultiBlocProvider
  - MaterialApp

### Auth

- `auth_remote_data_source.dart`
  - doctor whitelist pre-check via backend
  - Firebase Phone Auth
  - backend auth
- `auth_cubit.dart`
  - auth state orchestration
  - maps whitelist rejection to `AuthError`

### Auth Flow المختصر الحالي

- `LoginScreen`
  - إدخال رقم الهاتف
  - عرض `SnackBar` بالأخطاء القادمة من `AuthCubit`
- `AuthCubit.sendOtp`
  - validation
  - loading state
  - call to remote data source
- `AuthRemoteDataSource.sendOtp`
  - `POST /auth/check-doctor-phone`
  - if allowed -> `FirebaseAuth.verifyPhoneNumber`
  - if rejected -> `AuthException('عذراً، رقمك غير مسجل في النظام. يرجى مراجعة إدارة العيادة.')`

### Doctors

- `doctors_remote_data_source.dart`
  - doctors API calls
- `doctors_cubit.dart`
  - list/search/filter
- `doctor_details_cubit.dart`
  - doctor details + slots + cache

### Bookings

- `bookings_remote_data_source.dart`
  - create/fetch/cancel/check-in
- `bookings_cubit.dart`
  - booking workflows

### Queue

- `clinic_queue_cubit.dart`
  - simulated queue engine
  - queue alerts
  - timing estimates

### Doctor Workspace

- `doctor_dashboard_screen.dart`
- `clinic_queue_manager_screen.dart`
- `consultation_view_screen.dart`
- `medical_records_screen.dart`
- `schedule_manager_screen.dart`

---

## الملفات المضافة أو المعدلة حديثًا

هذه الملفات تمثل آخر ما ظهر في التطبيق داخل الـ worktree الحالي:

- `lib/features/doctors/presentation/screens/medical_records_screen.dart`
- `lib/core/widgets/notifications_screen.dart`
- `lib/features/doctors/presentation/screens/consultation_view_screen.dart`
- `lib/features/doctors/presentation/screens/doctor_dashboard_screen.dart`
- `lib/features/doctors/presentation/screens/schedule_manager_screen.dart`

---

## ما الذي لا تعكسه البنية القديمة بدقة

- عدد الملفات لم يعد `~35`
- الشاشات لم تعد `14`
- `queue` لم تعد مجرد placeholder
- `bookings` لم تعد TODO فقط
- `medical_records_screen.dart` موجودة فعليًا الآن
- `notifications_screen.dart` موجودة لكن خارج feature module مستقل

---

## توصيف مختصر للبنية الحالية

يمكن وصف المشروع الآن كالتالي:

- **Feature-first**
- **Cubit-driven**
- **API + Local hybrid**
- **Shared UI components in core**
- **Partial clean separation, without domain layer**

هذا الوصف أقرب كثيرًا للحالة الفعلية الحالية من الوصف القديم.
