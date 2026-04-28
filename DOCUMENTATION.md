# Libya Medical Mobile App - التوثيق الحالي

هذا الملف يصف **الحالة الفعلية الحالية** للمشروع كما هي موجودة في الكود داخل الـ workspace بتاريخ `2026-04-18`.

> مهم: هذا التوثيق مبني على الكود الحالي نفسه، بما في ذلك الملفات المضافة حديثًا مثل `medical_records_screen.dart` و `notifications_screen.dart`. وجود ملف لا يعني دائمًا أن الميزة مربوطة بالكامل داخل كل مسارات التطبيق، لذلك تم توضيح ما هو "مربوط فعليًا" وما هو "موجود لكن غير مفعّل بالكامل".

---

## نظرة عامة

**Libya Medical Mobile** هو تطبيق Flutter ثنائي اللغة يقدّم تجربتين أساسيتين:

- تجربة **المريض**: onboarding, login/OTP, البحث عن الأطباء، الحجز، متابعة الحجوزات، وتتبع الطابور.
- تجربة **الطبيب**: dashboard, إدارة الطابور، عرض الاستشارة، الجدول، والسجل الطبي.

التطبيق يستخدم:

- `flutter_bloc` لإدارة الحالة
- `get_it` لحقن التبعيات
- `dio` لطلبات الشبكة
- `shared_preferences` للتخزين المحلي
- `firebase_core` + `firebase_auth` لتسجيل الدخول عبر OTP

---

## تغيير مهم حديثًا في الـ Auth

من تاريخ `2026-04-18`، إرسال OTP لم يعد يبدأ مباشرة من Firebase.

الترتيب الحالي داخل التطبيق هو:

1. `LoginScreen` يستدعي `AuthCubit.sendOtp`
2. `AuthCubit` يستدعي `AuthRemoteDataSource.sendOtp`
3. `AuthRemoteDataSource` يرسل `POST /auth/check-doctor-phone`
4. إذا كانت الاستجابة `success: true`:
   - يتم استدعاء `FirebaseAuth.verifyPhoneNumber`
5. إذا كانت الاستجابة `403` أو `success: false`:
   - يتم رمي `AuthException` بالرسالة العربية:
   - `عذراً، رقمك غير مسجل في النظام. يرجى مراجعة إدارة العيادة.`
6. `AuthCubit` يحول الخطأ إلى `AuthError`
7. `LoginScreen` يعرض نفس الرسالة داخل `SnackBar`

هذا يعني أن الـ OTP الحقيقي أصبح يعتمد على:

- Firebase configuration
- Laravel backend متاح
- endpoint whitelist مفعل على backend

---

## Snapshot فعلي للمشروع

- عدد ملفات Dart داخل `lib/`: `46`
- إجمالي أسطر Dart داخل `lib/` بدون ملفات `.backup`: `18569`
- مجالات العمل الرئيسية داخل `features/`: `6`
- ملفات `presentation/screens`: `20`
- اللغات المدعومة: `العربية`, `الإنجليزية`
- الأدوار المدعومة: `patient`, `doctor`

### المجالات الموجودة فعليًا

- `auth`
- `bookings`
- `doctors`
- `facilities`
- `home`
- `queue`

### ملاحظة مهمة

لا توجد حاليًا مجلدات مستقلة باسم:

- `features/rooms`
- `features/notifications`

لكن يوجد:

- منطق للحجوزات الخاصة بالغرف داخل `BookingsCubit`
- واجهة مستقلة للإشعارات داخل `lib/core/widgets/notifications_screen.dart`

---

## المعمارية الحالية

المشروع منظم بصورة قريبة من **feature-first + Cubit architecture** أكثر من كونه Clean Architecture صارمًا بالكامل.

### ما هو منظم بوضوح

- `core/` للمشترك بين جميع الميزات
- `features/<feature>/data` للـ models و data sources
- `features/<feature>/logic` للـ cubits/states
- `features/<feature>/presentation/screens` للشاشات

### ما ليس مفصولًا بالكامل

- لا توجد طبقة `domain/` مستقلة
- بعض الشاشات الكبيرة تحتوي منطق UI كثيف وبيانات mock محلية
- بعض الميزات تعمل محليًا بالكامل بدون repository/API layer منفصل

---

## Bootstrap وتشغيل التطبيق

### `lib/main.dart`

التطبيق يبدأ من `main()` ويقوم بالآتي:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. محاولة تهيئة Firebase فقط على:
   - Android
   - iOS
   - Web
   - macOS
3. تخطي Firebase على Linux/Windows Desktop مع رسالة Dev Mode
4. تهيئة التبعيات عبر `initDependencies()`
5. تشغيل `MyApp`

### الـ BlocProviders العالمية

داخل `MyApp` يتم تسجيل:

- `AuthCubit`
- `LocaleCubit`
- `ClinicQueueCubit`

وهذا مهم لأن:

- حالة اللغة متاحة على مستوى التطبيق كله
- حالة الطابور المحلية متاحة لشاشات المريض والطبيب

---

## الترجمة والواجهة

### الترجمة

الملف: `lib/core/localization/app_localizations.dart`

الحالة الحالية:

- الترجمة **يدوية** داخل Map محلية
- اللغات المدعومة حاليًا: `ar`, `en`
- يوجد extension مهم:
  - `context.l10n`
  - `context.locText(en: ..., ar: ...)`

### الثيم

الملف: `lib/core/theme/app_theme.dart`

الحالة الحالية:

- `ThemeData` واحد فاتح `lightTheme`
- Material 3 مفعّل
- `InputDecorationTheme` موحد
- `ElevatedButtonTheme` موحد
- الألوان الأساسية معرفة في `app_colors.dart`

---

## المكونات المشتركة

### `AppTopBar`

الملف: `lib/core/widgets/app_top_bar.dart`

يدعم:

- عنوان اختياري
- زر رجوع عبر `showBackButton`
- زر تغيير اللغة
- زر إشعارات
- Avatar بسيط

الحالة الفعلية الآن:

- زر الإشعارات **ليس موصولًا مركزيًا في كل مكان**
- `onNotificationTap` مستخدم فعليًا فقط في:
  - `PatientDashboardScreen`

### `AppBottomNavBar`

الملف: `lib/core/widgets/bottom_nav_bar.dart`

الحالة الحالية:

- نسخة للمريض:
  - Home
  - Search
  - Bookings
  - Profile
- نسخة للطبيب:
  - Home
  - Queue
  - Schedule
  - Profile

### `NotificationsScreen`

الملف: `lib/core/widgets/notifications_screen.dart`

الحالة الحالية:

- شاشة مستقلة موجودة داخل الكود
- تعرض بطاقات إشعارات مبنية على:
  - `AuthCubit.currentRole`
  - `ClinicQueueCubit`
- **غير مربوطة حتى الآن بشكل عام** من `AppTopBar`

---

## Dependency Injection

الملف: `lib/core/di/injection_container.dart`

المسجل فعليًا:

- `SharedPreferences` كـ singleton
- `IAuthRemoteDataSource`
- `IDoctorsRemoteDataSource`
- `IBookingsRemoteDataSource`
- `AuthCubit`
- `DoctorsCubit`
- `DoctorDetailsCubit`
- `BookingsCubit`
- `LocaleCubit`
- `ClinicQueueCubit`

هذا يعني أن المشروع **لا يعتمد فقط على Auth/Doctors** كما كان مذكورًا سابقًا، بل `Bookings` و `Locale` و `Queue` أيضًا موصولة فعليًا.

---

## الشبكة والـ API

### `ApiConstants`

الملف: `lib/core/network/api_constants.dart`

الحالة الحالية:

- `baseUrl` الحالي هو:

```dart
http://10.0.2.2:8000/api
```

### Endpoints المعرفة فعليًا

- Auth
  - `/auth/verify-phone`
  - `/auth/check-doctor-phone`
  - `/auth/register`
  - `/auth/login`
  - `/auth/logout`
- Doctors
  - `/doctors`
  - `/doctors/{id}`
  - `/doctors/{id}/slots`
- Bookings
  - `/bookings`
  - `/bookings/{id}`
  - `/bookings/{id}/queue-status`
  - `/bookings/{id}/cancel`
  - `/bookings/{id}/check-in`
- Rooms
  - `/rooms`
- Notifications
  - `/notifications`
  - `/notifications/device-token`

### `DioClient`

الملف: `lib/core/network/dio_client.dart`

الحالة الحالية:

- Singleton بسيط
- يضيف:
  - `Accept: application/json`
  - `Content-Type: application/json`
- يحقن `Authorization: Bearer <token>` تلقائيًا من `SharedPreferences`

لا توجد حاليًا:

- response logging interceptor متقدم
- refresh token flow
- retry policy

---

## حالة الميزات بالتفصيل

## 1. Auth

المجلد: `lib/features/auth`

### الملفات الموجودة فعليًا

- `data/auth_models.dart`
- `data/auth_remote_data_source.dart`
- `logic/auth_cubit.dart`
- `logic/auth_state.dart`
- `presentation/screens/login_screen.dart`
- `presentation/screens/onboarding_screen.dart`
- `presentation/screens/otp_screen.dart`
- `presentation/screens/phone_verification_screen.dart`
- `presentation/screens/profile_setup_screen.dart`
- `presentation/screens/splash_screen.dart`
- `widgets/auth_toggle_button.dart`

### ما يعمل فعليًا

- Splash screen يقرأ:
  - `access_token`
  - `user_role`
- إذا كانت الجلسة موجودة:
  - يوجّه إلى `PatientDashboardScreen` أو `DoctorDashboardScreen`
- إذا لم توجد جلسة:
  - يذهب إلى `OnboardingScreen`

### مسارات المصادقة الحالية

يوجد **مساران** في المشروع:

1. `OnboardingScreen -> PhoneVerificationScreen`
2. `LoginScreen -> OtpScreen`

### `AuthRemoteDataSource`

يدعم فعليًا:

- `sendOtp`
- `verifyOtp`
- `authenticateWithBackend`
- `signOut`

### تدفق `sendOtp` الحالي

`sendOtp` لم يعد مجرد Firebase call.

التسلسل الحالي:

1. تهيئة الرقم إلى صيغة API/Firebase
2. استدعاء `POST /auth/check-doctor-phone`
3. لو backend رفض الرقم:
   - يتم رمي `AuthException`
   - الـ code المستخدم حاليًا: `doctor-not-whitelisted`
   - الرسالة:
   - `عذراً، رقمك غير مسجل في النظام. يرجى مراجعة إدارة العيادة.`
4. لو backend وافق:
   - يتم استدعاء `FirebaseAuth.verifyPhoneNumber`
5. عند نجاح `codeSent`:
   - يتم إصدار `OtpSent` من الـ Cubit

### مسؤولية `AuthCubit` في هذا التدفق

- يمسك `AuthException` القادمة من data source
- يحولها إلى `AuthError(message, code, canRetry)`
- في حالة `doctor-not-whitelisted`:
  - `canRetry` تكون `false`
  - لذلك لا يظهر زر retry داخل الـ `SnackBar`

### مسؤولية `LoginScreen`

- تعرض `SnackBar` باستخدام **نفس** `state.message` بدون إعادة صياغة
- هذا مهم لأن رسالة whitelist عربية ومقصودة لتوجيه المستخدم إلى إدارة العيادة

### ملاحظات مهمة

- Firebase Phone Auth يعمل فقط على المنصات المدعومة
- OTP الحقيقي يحتاج الآن backend whitelist check ناجح قبل Firebase
- على Linux/Windows Desktop، يتم الاعتماد على **Dev Mode** الموجود في `LoginScreen`
- `AuthState` الحالية تتضمن:
  - `AuthInitial`
  - `AuthLoading`
  - `OtpSent`
  - `OtpVerifying`
  - `AuthSuccess`
  - `AuthAuthenticated`
  - `AuthLoggedOut`
  - `AuthError`
- `ProfileSetupScreen` موجودة كواجهة إعداد ملف شخصي، لكنها حاليًا تنتهي إلى `PatientDashboardScreen` فقط عند الإكمال، بغض النظر عن الدور المختار داخل الشاشة

### اختلاف مهم عن التوثيق القديم

- لا توجد حالة باسم `OtpSending`
- يوجد `AuthAuthenticated` و `AuthLoggedOut`
- الـ onboarding flow موجود فعليًا، ولم يكن موثقًا بشكل كافٍ

---

## 2. Doctors

المجلد: `lib/features/doctors`

### Data layer

- `DoctorModel`
- `ScheduleModel`
- `AvailableSlotsModel`
- `DoctorsRemoteDataSource`

### Logic layer

- `DoctorsCubit`
- `DoctorDetailsCubit`
- `DoctorsState`
- `DoctorDetailsState`

### API-backed features

- `DoctorSearchScreen`
  - fetch doctors from API
  - search by name/specialty
  - filter by specialty
  - refresh data

- `DoctorProfileScreen`
  - fetch doctor details
  - fetch available slots
  - cache doctor object locally داخل cubit
  - update slots عند تغيير التاريخ
  - navigate إلى `BookingConfirmationScreen`

### Doctor workspace screens

- `DoctorDashboardScreen`
- `ClinicQueueManagerScreen`
- `ConsultationViewScreen`
- `ScheduleManagerScreen`
- `MedicalRecordsScreen`

الحالة الحالية لهذه الشاشات:

- ليست معتمدة على backend حقيقي
- تعتمد على:
  - local UI state
  - `ClinicQueueCubit`
  - بيانات mock داخل الشاشة

### إضافات حديثة في الـ doctor workflow

- `MedicalRecordsScreen` أضيفت حديثًا
- `ConsultationViewScreen` تحتوي الآن على:
  - بحث داخل `الوصفة الطبية`
  - بحث داخل `التحاليل`
- `ScheduleManagerScreen` أصبح فيها:
  - تنقل أسبوعي فعلي بالسهمين يمين/يسار

---

## 3. Bookings

المجلد: `lib/features/bookings`

### الحالة الفعلية

ميزة `bookings` ليست "TODO" فقط كما كان في التوثيق القديم، بل يوجد بها:

- model فعلي `BookingModel`
- data source فعلي `BookingsRemoteDataSource`
- cubit فعلي `BookingsCubit`
- states فعلية `BookingsState`
- شاشة UI مربوطة جزئيًا `BookingConfirmationScreen`

### `BookingsRemoteDataSource`

يدعم فعليًا:

- `createBooking`
- `getMyBookings`
- `cancelBooking`
- `checkInBooking`

### `BookingsCubit`

يدعم فعليًا:

- `createDoctorBooking`
- `createRoomBooking`
- `fetchMyBookings`
- `refreshBookings`
- `cancelBooking`
- `checkInBooking`
- `filterByStatus`
- `getUpcomingBookings`
- `getPastBookings`

### الشاشات المرتبطة

- `BookingConfirmationScreen`
  - تستخدم `createDoctorBooking`
  - تعرض dialog نجاح مع رقم الدور

- `PatientBookingsScreen`
  - تجلب الحجوزات من API
  - تقسيم إلى:
    - Upcoming
    - History
  - تدعم `RefreshIndicator`

### ملاحظات دقيقة

- منطق حجز الغرف موجود في الـ cubit/data source
- لكن لا يوجد حاليًا flow واجهة مكتمل يربط `FacilityListingScreen` مباشرة بـ `createRoomBooking`
- `PatientBookingsScreen` تعرض الحجوزات ولكن لا تملك حتى الآن أزرار UI مباشرة للإلغاء أو تسجيل الحضور داخل البطاقة نفسها

---

## 4. Queue

المجلد: `lib/features/queue`

### الحالة الحالية

ميزة `queue` في هذا المشروع تعمل كمحاكاة محلية قوية نسبيًا عبر:

- `ClinicQueueCubit`
- `QueueTrackerScreen`

### ما يقدمه `ClinicQueueCubit`

- patient list initial state
- `callPatient`
- `completePatient`
- `addPatient`
- `addDelayToActivePatient`
- `estimatedStartMinutesByPatient`
- `waitMinutesFor`
- `patientsAheadOf`
- إحصاءات:
  - `completedCount`
  - `activeCount`
  - `waitingCount`
  - `totalPatients`

### تنبيهات الطابور

يوجد نوعان:

- `QueueAlertType.call`
- `QueueAlertType.delay`

ويتم تخزين آخر تنبيه في:

- `ClinicQueueState.latestAlert`

### الشاشات المستفيدة

- `QueueTrackerScreen`
- `PatientDashboardScreen`
- `ClinicQueueManagerScreen`
- `ConsultationViewScreen`
- `MedicalRecordsScreen`

### ملاحظة مهمة

هذه الميزة **ليست مربوطة حاليًا بـ API حقيقي أو WebSocket**، لكنها مستخدمة فعليًا داخل التطبيق لتشغيل تجربة المريض والطبيب محليًا.

---

## 5. Home / Patient Experience

المجلد: `lib/features/home`

### الشاشات الفعلية

- `PatientDashboardScreen`
- `PatientBookingsScreen`
- `PatientProfileScreen`
- `patient_tab_navigation.dart` helper

### `PatientDashboardScreen`

تحتوي على:

- bottom navigation داخلي
- live queue card
- CTA grid
- upcoming appointments section
- live status section
- dialog يظهر عند وصول `latestAlert` للمريض المتعقَّب

### ملاحظة

زر الجرس في `PatientDashboardScreen` موصول حاليًا إلى:

- `QueueTrackerScreen`

وليس إلى شاشة إشعارات عامة بعد.

---

## 6. Facilities

المجلد: `lib/features/facilities`

### `FacilityListingScreen`

الحالة الحالية:

- شاشة UI موجودة
- تحتوي:
  - hero section
  - search bar
  - filter chips
  - quick stats
  - قائمة مرافق ثابتة محليًا

### دقة التوثيق هنا

هذه الشاشة **ليست API-backed حاليًا**، وتستخدم بيانات mock داخل `_facilities`.

---

## الشاشات الموجودة فعليًا

### Auth

1. `SplashScreen`
2. `OnboardingScreen`
3. `PhoneVerificationScreen`
4. `LoginScreen`
5. `OtpScreen`
6. `ProfileSetupScreen`

### Patient / Shared

7. `PatientDashboardScreen`
8. `DoctorSearchScreen`
9. `DoctorProfileScreen`
10. `BookingConfirmationScreen`
11. `FacilityListingScreen`
12. `PatientBookingsScreen`
13. `PatientProfileScreen`
14. `QueueTrackerScreen`

### Doctor

15. `DoctorDashboardScreen`
16. `ClinicQueueManagerScreen`
17. `ConsultationViewScreen`
18. `ScheduleManagerScreen`
19. `MedicalRecordsScreen`

### Helper file داخل screens

20. `patient_tab_navigation.dart`

---

## الملفات التي تغيّرت فعليًا في الـ worktree الحالي

هذه الملفات موجودة الآن في الشجرة المحلية ويجب اعتبارها ضمن الحالة الحالية:

- `lib/features/doctors/presentation/screens/medical_records_screen.dart`
- `lib/core/widgets/notifications_screen.dart`
- `lib/features/doctors/presentation/screens/consultation_view_screen.dart`
- `lib/features/doctors/presentation/screens/doctor_dashboard_screen.dart`
- `lib/features/doctors/presentation/screens/schedule_manager_screen.dart`

### أثر هذه التغييرات

- إضافة شاشة سجل طبي للطبيب
- ربط زر `السجل الطبي` في الداشبورد والاستشارة
- إضافة بحث داخل الوصفة الطبية والتحاليل
- إصلاح أسهم تغيير الأسبوع في الجدول
- تجهيز شاشة إشعارات مستقلة لم يتم ربطها بالكامل بعد

---

## الفجوات الحالية

### Notifications

- يوجد endpoint constants
- توجد شاشة UI مستقلة
- لا يوجد Cubit/Data Source/flow كامل بعد
- لا يوجد ربط مركزي كامل من `AppTopBar`

### Facilities / Rooms

- لا يوجد `rooms` feature module منفصل
- لا يوجد API integration حاليًا لشاشة المرافق

### Consultation / Records

- الاستشارة تعمل محليًا
- السجل الطبي يعمل محليًا
- لا يوجد حفظ فعلي backend للملاحظات أو التحاليل أو الوصفات داخل هذه الشاشات

### Navigation consistency

- بعض الشاشات تستخدم `AppTopBar`
- بعض الشاشات ما زالت تستخدم `AppBar` أو back handling يدوي
- السلوك ليس موحدًا بالكامل بعد على كل الصفحات

---

## كيفية التشغيل حاليًا

### المتطلبات

- Flutter SDK حديث
- Android emulator أو device
- Laravel backend متاح إذا أردت اختبار ميزات API
- Firebase configured إذا أردت OTP حقيقي

### خطوات التشغيل

```bash
flutter pub get
flutter run
```

### ملاحظات التشغيل

- على Android emulator يستخدم المشروع:

```dart
http://10.0.2.2:8000/api
```

- الـ backend يجب أن يوفّر endpoint:

```text
/auth/check-doctor-phone
```

- بدون هذا الـ endpoint لن يرسل التطبيق Firebase OTP من `LoginScreen`
- على Linux/Windows Desktop لن يعمل Firebase Phone Auth
- استخدم `Dev Mode` من `LoginScreen` لاختبار الدخول المحلي بسرعة

---

## تقييم الحالة الحالية

### ميزات قوية ومتصلة فعليًا

- Auth
- Doctors list/details/slots
- Doctor booking creation
- Bookings fetching

### ميزات تعمل محليًا داخل التطبيق

- Queue simulation
- Queue tracker
- Doctor queue management
- Consultation workspace
- Schedule manager
- Medical records screen

### ميزات ما زالت واجهات أو تجهيزات جزئية

- Facilities/rooms UI
- General notifications integration
- Backend persistence for consultation data

---

## خلاصة دقيقة

المشروع الحالي **ليس مجرد UI mockup**، وفي نفس الوقت **ليس API-complete بالكامل**.

الوصف الأدق هو:

- API-backed في:
  - auth
  - doctors
  - bookings
- local-simulated في:
  - queue
  - consultation
  - doctor schedule
  - medical records
- static/mock UI في:
  - facilities
  - بعض أجزاء dashboard/profile/settings

هذا هو الوضع الحقيقي الحالي للتطبيق داخل الكود بتاريخ `2026-04-18`.
