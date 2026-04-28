# Libya Medical Mobile

تطبيق Flutter ثنائي اللغة (عربي/إنجليزي) لإدارة تجربة المريض والطبيب داخل منظومة **Libya Medical**.

الحالة الحالية للمشروع تعتمد على مزيج من:
- تكامل حقيقي مع API في ميزات `auth`, `doctors`, `bookings`
- محاكاة محلية `local state` في ميزات `queue`, `consultation`, `schedule`, `medical records`
- شاشات واجهة ثابتة/نصف تفاعلية مثل `facilities`

## Current Snapshot

- Flutter app with `46` Dart files داخل `lib/`
- حوالي `18.5k` سطر Dart فعليًا داخل `lib/` بدون ملفات النسخ الاحتياطية
- `6` مجالات رئيسية داخل `features/`
- `20` ملف داخل `presentation/screens` منها شاشة helper واحدة (`patient_tab_navigation.dart`)
- يدعم دورين: `patient` و `doctor`
- يدعم لغتين: `ar`, `en`

## Main Functional Areas

- **Authentication**
  - Splash + onboarding + phone verification + OTP login
  - Laravel whitelist pre-check عبر `/auth/check-doctor-phone` قبل إرسال Firebase OTP
  - Firebase Phone Auth على المنصات المدعومة
  - في حالة عدم تسجيل الرقم داخل النظام تظهر الرسالة:
    `عذراً، رقمك غير مسجل في النظام. يرجى مراجعة إدارة العيادة.`
  - أزرار Dev Mode في `login_screen.dart` للأجهزة/البيئات غير المناسبة لفايربيز

- **Doctors**
  - جلب قائمة الأطباء من API
  - البحث والفلترة حسب الاسم/التخصص
  - عرض تفاصيل الطبيب والمواعيد المتاحة

- **Bookings**
  - إنشاء حجز طبي عبر API
  - جلب الحجوزات الحالية والسجل
  - منطق جاهز لإلغاء الحجز وتسجيل الحضور داخل الـ Cubit/Data Source

- **Queue**
  - تتبع طابور محلي باستخدام `ClinicQueueCubit`
  - استدعاء المريض، إضافة تأخير، إكمال الاستشارة، تقدير وقت الانتظار

- **Doctor Workspace**
  - Doctor dashboard
  - Clinic queue manager
  - Consultation view
  - Schedule manager
  - Medical records screen

## Important Notes

- `LoginScreen -> AuthCubit -> AuthRemoteDataSource` يمر الآن أولًا على backend whitelist check قبل أي `verifyPhoneNumber`.
- الـ OTP الحقيقي يحتاج **Laravel backend شغال** ويدعم endpoint: `/auth/check-doctor-phone` بالإضافة إلى Firebase config.
- `lib/core/widgets/notifications_screen.dart` موجودة حاليًا كواجهة مستقلة داخل الـ worktree، لكنها **غير مربوطة مركزيًا بعد** مع كل أزرار الإشعارات.
- `FacilityListingScreen` ما زالت تعتمد على بيانات محلية ثابتة، وليست مرتبطة بـ API.
- `MedicalRecordsScreen` مضافة حديثًا ومربوطة من شاشة الطبيب والاستشارة، لكنها تعتمد على بيانات محلية مشتقة من `ClinicQueueCubit`.

## Docs Index

- [DOCUMENTATION.md](./DOCUMENTATION.md): التوثيق التفصيلي للحالة الحالية
- [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md): بنية الملفات والمجلدات الفعلية
- [CODE_EXAMPLES.md](./CODE_EXAMPLES.md): أمثلة برمجية مطابقة للكود الحالي

## Run

```bash
flutter pub get
flutter run
```

إذا كنت تعمل على Linux Desktop أو Windows Desktop فـ Firebase Phone Auth لن يعمل؛ استخدم أزرار `Dev Mode` في شاشة تسجيل الدخول.

## Last Updated

`2026-04-18`
