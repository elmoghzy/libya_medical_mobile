# Libya Medical - بنية المشروع (Project Structure) 📁

دليل تفصيلي لجميع الملفات والمجلدات في المشروع.

---

## 📊 إحصائيات المشروع

```
Total Files: ~35 Dart files
Lines of Code: ~11,000+ lines
Features: 4 (Auth, Doctors, Bookings, Home)
Screens: 14 screens
```

---

## 🗂️ البنية الكاملة

```
libya_medical_mobile/
│
├── android/                                    # Android Native Code
│   ├── app/
│   │   ├── google-services.json               # Firebase Config
│   │   └── build.gradle                       # Android Build Config
│   └── build.gradle
│
├── ios/                                        # iOS Native Code
│   ├── Runner/
│   │   └── GoogleService-Info.plist           # Firebase Config iOS
│   └── Podfile
│
├── lib/                                        # 🎯 Main Flutter Code
│   │
│   ├── main.dart                              # ⭐ Entry Point (Firebase Init)
│   │
│   ├── core/                                  # 🔧 Shared/Core Features
│   │   │
│   │   ├── di/                                # Dependency Injection
│   │   │   └── injection_container.dart       # GetIt Setup
│   │   │
│   │   ├── network/                           # Network Layer
│   │   │   ├── dio_client.dart                # HTTP Client Singleton
│   │   │   └── api_constants.dart             # API URLs & Endpoints
│   │   │
│   │   ├── theme/                             # Design System
│   │   │   └── app_colors.dart                # App Color Palette
│   │   │
│   │   └── widgets/                           # Reusable Widgets
│   │       ├── bottom_nav_bar.dart            # Bottom Navigation
│   │       └── app_top_bar.dart               # Top App Bar
│   │
│   └── features/                              # 🎨 Feature Modules
│       │
│       ├── auth/                              # 🔐 Authentication Feature
│       │   │
│       │   ├── data/                          # Data Layer
│       │   │   ├── auth_models.dart           # Models (UserRole, AuthResponse, UserModel)
│       │   │   └── auth_remote_data_source.dart  # Firebase + Laravel Auth
│       │   │
│       │   ├── logic/                         # Business Logic (BLoC)
│       │   │   ├── auth_cubit.dart            # Auth Cubit
│       │   │   └── auth_state.dart            # Auth States (Sealed Classes)
│       │   │
│       │   └── presentation/                  # UI Layer
│       │       └── screens/
│       │           ├── login_screen.dart      # Login with OTP
│       │           ├── otp_screen.dart        # OTP Verification
│       │           └── profile_setup_screen.dart  # Profile Setup
│       │
│       ├── doctors/                           # 👨‍⚕️ Doctors Feature
│       │   │
│       │   ├── data/                          # Data Layer
│       │   │   ├── models/
│       │   │   │   └── doctor_model.dart      # DoctorModel, ScheduleModel, AvailableSlotsModel
│       │   │   │
│       │   │   └── datasources/
│       │   │       └── doctors_remote_data_source.dart  # Doctors API Calls
│       │   │
│       │   ├── logic/                         # Business Logic
│       │   │   ├── doctors_cubit.dart         # Doctors List Cubit
│       │   │   ├── doctor_details_cubit.dart  # Single Doctor + Slots Cubit
│       │   │   └── doctors_state.dart         # All Doctor States
│       │   │
│       │   └── presentation/                  # UI Layer
│       │       └── screens/
│       │           ├── doctor_search_screen.dart       # ✅ Search & Filter Doctors
│       │           ├── doctor_profile_screen.dart      # ✅ Doctor Profile + Slots
│       │           ├── clinic_queue_manager_screen.dart  # Doctor Dashboard Queue
│       │           ├── consultation_view_screen.dart     # Consultation Screen
│       │           └── schedule_manager_screen.dart      # Schedule Management
│       │
│       ├── bookings/                          # 📅 Bookings Feature
│       │   │
│       │   ├── data/                          # Data Layer (TODO)
│       │   │   ├── models/
│       │   │   │   └── booking_model.dart     # BookingModel (TODO)
│       │   │   │
│       │   │   └── datasources/
│       │   │       └── bookings_remote_data_source.dart  # Bookings API (TODO)
│       │   │
│       │   ├── logic/                         # Business Logic (TODO)
│       │   │   ├── bookings_cubit.dart        # Bookings Cubit (TODO)
│       │   │   └── bookings_state.dart        # Bookings States (TODO)
│       │   │
│       │   └── presentation/                  # UI Layer
│       │       └── screens/
│       │           ├── booking_confirmation_screen.dart  # ✅ Booking Confirmation
│       │           ├── queue_tracker_screen.dart         # Queue Status Screen
│       │           └── facility_listing_screen.dart      # Rooms Listing
│       │
│       ├── home/                              # 🏠 Home & Dashboards
│       │   └── presentation/
│       │       └── screens/
│       │           ├── splash_screen.dart               # ✅ Splash Screen
│       │           ├── patient_dashboard_screen.dart    # ✅ Patient Dashboard
│       │           └── doctor_dashboard_screen.dart     # ✅ Doctor Dashboard
│       │
│       ├── rooms/                             # 🏥 Rooms Feature (TODO)
│       │   ├── data/
│       │   ├── logic/
│       │   └── presentation/
│       │
│       ├── queue/                             # 📊 Queue Feature (TODO)
│       │   ├── data/
│       │   ├── logic/
│       │   └── presentation/
│       │
│       └── notifications/                     # 🔔 Notifications Feature (TODO)
│           ├── data/
│           ├── logic/
│           └── presentation/
│
├── test/                                      # Unit & Widget Tests
│   └── widget_test.dart
│
├── assets/                                    # Static Assets (if any)
│   ├── images/
│   └── icons/
│
├── pubspec.yaml                               # ⚙️ Dependencies Configuration
├── pubspec.lock                               # Dependency Lock File
│
├── analysis_options.yaml                      # Linter Configuration
│
├── README.md                                  # Project Overview (Original)
├── DOCUMENTATION.md                           # 📘 Full Documentation (NEW)
├── CODE_EXAMPLES.md                           # 💻 Code Examples (NEW)
└── PROJECT_STRUCTURE.md                       # 📁 This File (NEW)
```

---

## 📄 ملفات مهمة (Key Files)

### 1. `lib/main.dart` - نقطة البداية

```dart
Responsibilities:
  ✅ Initialize Firebase
  ✅ Initialize Dependencies (GetIt)
  ✅ Setup BlocProviders
  ✅ Configure MaterialApp
  ✅ Set initial route (SplashScreen)
```

### 2. `lib/core/di/injection_container.dart` - DI Setup

```dart
Registered Services:
  ✅ SharedPreferences (Singleton)
  ✅ AuthRemoteDataSource (Singleton)
  ✅ DoctorsRemoteDataSource (Singleton)
  ✅ AuthCubit (Factory)
  ✅ DoctorsCubit (Factory)
  ✅ DoctorDetailsCubit (Factory)
```

### 3. `lib/core/network/dio_client.dart` - HTTP Client

```dart
Features:
  ✅ Singleton Pattern
  ✅ Base URL Configuration
  ✅ Request Interceptor (Add Token)
  ✅ Response Interceptor (Logging)
  ✅ Error Handling
```

### 4. `lib/core/network/api_constants.dart` - API Endpoints

```dart
Contains:
  ✅ Base URL
  ✅ Auth Endpoints
  ✅ Doctors Endpoints
  ✅ Bookings Endpoints
  ✅ Rooms Endpoints
  ✅ Queue Endpoints
  ✅ Notifications Endpoints
```

---

## 🎯 Features Breakdown

### 1. Auth Feature (100% Complete ✅)

```
lib/features/auth/
├── data/
│   ├── auth_models.dart                       (148 lines)
│   │   ├── UserRole enum
│   │   ├── AuthResponse class
│   │   └── UserModel class
│   │
│   └── auth_remote_data_source.dart           (243 lines)
│       ├── sendOtp()
│       ├── verifyOtp()
│       ├── authenticateWithBackend()
│       └── signOut()
│
├── logic/
│   ├── auth_cubit.dart                        (187 lines)
│   │   ├── sendOtp()
│   │   ├── verifyOtp()
│   │   ├── resendOtp()
│   │   └── signOut()
│   │
│   └── auth_state.dart                        (86 lines)
│       ├── AuthInitial
│       ├── AuthLoading
│       ├── OtpSending
│       ├── OtpSent
│       ├── OtpVerifying
│       ├── AuthSuccess
│       └── AuthError
│
└── presentation/screens/
    ├── login_screen.dart                      (450+ lines)
    │   └── BlocConsumer<AuthCubit>
    │
    ├── otp_screen.dart                        (380+ lines)
    │   └── BlocConsumer<AuthCubit>
    │
    └── profile_setup_screen.dart              (520+ lines)
```

**Total:** ~2,014 lines

### 2. Doctors Feature (100% Complete ✅)

```
lib/features/doctors/
├── data/
│   ├── models/
│   │   └── doctor_model.dart                  (258 lines)
│   │       ├── DoctorModel
│   │       ├── ScheduleModel
│   │       └── AvailableSlotsModel
│   │
│   └── datasources/
│       └── doctors_remote_data_source.dart    (186 lines)
│           ├── getDoctors()
│           ├── getDoctorDetails()
│           └── getAvailableSlots()
│
├── logic/
│   ├── doctors_cubit.dart                     (132 lines)
│   │   ├── fetchDoctors()
│   │   ├── refreshDoctors()
│   │   ├── searchDoctors()
│   │   ├── filterBySpecialty()
│   │   └── clearFilters()
│   │
│   ├── doctor_details_cubit.dart              (182 lines)
│   │   ├── fetchDoctorDetailsAndSlots()
│   │   ├── fetchDoctorDetails()
│   │   ├── fetchSlotsForDate()
│   │   ├── selectSlot()
│   │   └── clearSelectedSlot()
│   │
│   └── doctors_state.dart                     (168 lines)
│       ├── DoctorsInitial
│       ├── DoctorsLoading
│       ├── DoctorsLoaded
│       ├── DoctorsError
│       ├── DoctorDetailsInitial
│       ├── DoctorDetailsLoading
│       ├── DoctorDetailsLoaded
│       ├── DoctorDetailsError
│       └── SlotsLoading
│
└── presentation/screens/
    ├── doctor_search_screen.dart              (650+ lines)
    │   └── BlocBuilder<DoctorsCubit>
    │
    ├── doctor_profile_screen.dart             (750+ lines)
    │   └── BlocBuilder<DoctorDetailsCubit>
    │
    ├── clinic_queue_manager_screen.dart       (580+ lines)
    ├── consultation_view_screen.dart          (420+ lines)
    └── schedule_manager_screen.dart           (490+ lines)

```

**Total:** ~3,816 lines

### 3. Bookings Feature (20% Complete 🚧)

```
lib/features/bookings/
├── data/                                      (TODO)
│   ├── models/
│   │   └── booking_model.dart
│   │
│   └── datasources/
│       └── bookings_remote_data_source.dart
│
├── logic/                                     (TODO)
│   ├── bookings_cubit.dart
│   └── bookings_state.dart
│
└── presentation/screens/
    ├── booking_confirmation_screen.dart       (620+ lines) ✅
    ├── queue_tracker_screen.dart              (580+ lines) ✅
    └── facility_listing_screen.dart           (540+ lines) ✅
```

**Total:** ~1,740 lines (UI only)

### 4. Home Feature (100% Complete ✅)

```
lib/features/home/presentation/screens/
├── splash_screen.dart                         (180+ lines) ✅
├── patient_dashboard_screen.dart              (850+ lines) ✅
└── doctor_dashboard_screen.dart               (720+ lines) ✅
```

**Total:** ~1,750 lines

---

## 🧩 Core Components

### 1. Dependency Injection

```
lib/core/di/injection_container.dart           (42 lines)
```

**Pattern:** Service Locator (GetIt)

**Lifecycle:**
- `registerSingleton` → Instantiated once, lives forever
- `registerLazySingleton` → Instantiated on first use, lives forever
- `registerFactory` → New instance on each call

### 2. Network Layer

```
lib/core/network/
├── dio_client.dart                            (120+ lines)
│   └── Singleton HTTP Client
│
└── api_constants.dart                         (85+ lines)
    └── All API Endpoints
```

### 3. Theme System

```
lib/core/theme/
└── app_colors.dart                            (45 lines)
    ├── Primary Colors
    ├── Secondary Colors
    ├── Tertiary Colors
    ├── Surface Colors
    ├── Status Colors
    └── Text Colors
```

### 4. Shared Widgets

```
lib/core/widgets/
├── bottom_nav_bar.dart                        (180+ lines)
│   ├── Patient Navigation (5 tabs)
│   └── Doctor Navigation (5 tabs)
│
└── app_top_bar.dart                           (85+ lines)
    ├── Title
    ├── Back Button
    └── Actions
```

---

## 📦 Dependencies (pubspec.yaml)

### Production Dependencies

```yaml
flutter_bloc: ^9.1.1           # State Management (BLoC/Cubit)
equatable: ^2.0.8              # Value Equality for States
dio: ^5.9.2                    # HTTP Client
get_it: ^9.2.1                 # Dependency Injection
shared_preferences: ^2.5.5     # Local Storage (Token, Role)
intl: ^0.20.2                  # Date Formatting (DateFormat)
firebase_core: ^3.13.0         # Firebase Core SDK
firebase_auth: ^5.6.1          # Firebase Authentication (Phone)
cupertino_icons: ^1.0.8        # iOS Style Icons
```

### Dev Dependencies

```yaml
flutter_test: sdk: flutter     # Testing Framework
flutter_lints: ^5.0.0          # Linting Rules
```

---

## 🎨 Screens Status

### ✅ Implemented & Working

| Screen | Path | Lines | Status |
|--------|------|-------|--------|
| Splash Screen | `home/presentation/screens/splash_screen.dart` | 180 | ✅ Complete |
| Login Screen | `auth/presentation/screens/login_screen.dart` | 450 | ✅ Complete + API |
| OTP Screen | `auth/presentation/screens/otp_screen.dart` | 380 | ✅ Complete + API |
| Profile Setup | `auth/presentation/screens/profile_setup_screen.dart` | 520 | ✅ Complete (UI) |
| Patient Dashboard | `home/presentation/screens/patient_dashboard_screen.dart` | 850 | ✅ Complete (UI) |
| Doctor Dashboard | `home/presentation/screens/doctor_dashboard_screen.dart` | 720 | ✅ Complete (UI) |
| Doctor Search | `doctors/presentation/screens/doctor_search_screen.dart` | 650 | ✅ Complete + API |
| Doctor Profile | `doctors/presentation/screens/doctor_profile_screen.dart` | 750 | ✅ Complete + API |
| Booking Confirmation | `bookings/presentation/screens/booking_confirmation_screen.dart` | 620 | ✅ Complete (UI) |
| Queue Tracker | `bookings/presentation/screens/queue_tracker_screen.dart` | 580 | ✅ Complete (UI) |
| Facility Listing | `bookings/presentation/screens/facility_listing_screen.dart` | 540 | ✅ Complete (UI) |
| Clinic Queue Manager | `doctors/presentation/screens/clinic_queue_manager_screen.dart` | 580 | ✅ Complete (UI) |
| Consultation View | `doctors/presentation/screens/consultation_view_screen.dart` | 420 | ✅ Complete (UI) |
| Schedule Manager | `doctors/presentation/screens/schedule_manager_screen.dart` | 490 | ✅ Complete (UI) |

**Total: 14 screens | ~7,730 lines**

---

## 🔨 TODO Features

### Phase 1: Bookings API Integration

```
lib/features/bookings/
├── data/
│   ├── models/booking_model.dart              ❌ TODO
│   └── datasources/bookings_remote_data_source.dart  ❌ TODO
│
└── logic/
    ├── bookings_cubit.dart                    ❌ TODO
    └── bookings_state.dart                    ❌ TODO
```

### Phase 2: Rooms Feature

```
lib/features/rooms/
├── data/
│   ├── models/room_model.dart                 ❌ TODO
│   └── datasources/rooms_remote_data_source.dart  ❌ TODO
│
└── logic/
    ├── rooms_cubit.dart                       ❌ TODO
    └── rooms_state.dart                       ❌ TODO
```

### Phase 3: Queue Tracking

```
lib/features/queue/
├── data/
│   ├── models/queue_model.dart                ❌ TODO
│   └── datasources/queue_remote_data_source.dart  ❌ TODO
│
└── logic/
    ├── queue_cubit.dart                       ❌ TODO
    └── queue_state.dart                       ❌ TODO
```

### Phase 4: Notifications

```
lib/features/notifications/
├── data/
│   ├── models/notification_model.dart         ❌ TODO
│   └── datasources/notifications_remote_data_source.dart  ❌ TODO
│
└── logic/
    ├── notifications_cubit.dart               ❌ TODO
    └── notifications_state.dart               ❌ TODO
```

---

## 📊 Code Statistics

### By Feature

| Feature | Files | Lines | Completion |
|---------|-------|-------|------------|
| Auth | 6 | ~2,014 | 100% ✅ |
| Doctors | 9 | ~3,816 | 100% ✅ |
| Bookings | 3 | ~1,740 | 20% 🚧 |
| Home | 3 | ~1,750 | 100% ✅ |
| Core | 6 | ~650 | 100% ✅ |
| **Total** | **27** | **~9,970** | **75%** |

### By Layer

| Layer | Files | Lines | Status |
|-------|-------|-------|--------|
| Data (Models + DataSources) | 8 | ~2,450 | 65% |
| Logic (Cubits + States) | 6 | ~1,100 | 65% |
| Presentation (Screens) | 14 | ~7,730 | 100% |
| Core | 6 | ~650 | 100% |
| **Total** | **34** | **~11,930** | **75%** |

---

## 🎯 Next Steps

### Immediate Priority

1. **Bookings Data Layer**
   ```
   Create: booking_model.dart
   Create: bookings_remote_data_source.dart
   Implement: POST /api/bookings
   ```

2. **Bookings Logic Layer**
   ```
   Create: bookings_cubit.dart
   Create: bookings_state.dart
   Implement: createBooking(), getMyBookings()
   ```

3. **Integrate Booking Confirmation**
   ```
   Update: booking_confirmation_screen.dart
   Add: BlocConsumer<BookingsCubit>
   Call API on "Confirm" button
   ```

---

## 📚 Documentation Files

```
PROJECT ROOT/
├── README.md                    # Basic Project Info (Original)
├── DOCUMENTATION.md             # Complete Documentation (23 KB)
├── CODE_EXAMPLES.md             # Code Examples & Patterns (32 KB)
└── PROJECT_STRUCTURE.md         # This File - File Tree (15 KB)
```

**Total Documentation: ~70 KB / ~2,500 lines**

---

## 🔍 How to Navigate This Project

### For New Developers

1. **Start Here:**
   - Read `DOCUMENTATION.md` - فهم المشروع بالكامل
   - Read `CODE_EXAMPLES.md` - تعلم الأنماط البرمجية
   - Read `PROJECT_STRUCTURE.md` - فهم بنية الملفات

2. **Explore Code:**
   - `lib/main.dart` - نقطة البداية
   - `lib/core/` - المكونات المشتركة
   - `lib/features/auth/` - مثال كامل على Feature

3. **Add New Feature:**
   - Follow Clean Architecture pattern
   - Copy structure from `features/auth/` or `features/doctors/`
   - Register in `injection_container.dart`

### For Code Review

1. **Check Data Layer:**
   - Models have `fromJson()` and `toJson()`
   - DataSources handle exceptions properly
   - API endpoints match backend

2. **Check Logic Layer:**
   - Cubits extend `Cubit<State>`
   - States are sealed classes with Equatable
   - Error handling is comprehensive

3. **Check Presentation Layer:**
   - Use BlocBuilder/BlocConsumer
   - Handle all state cases (Loading, Success, Error)
   - No business logic in UI

---

## 🎨 File Naming Conventions

```
✅ Correct:
- auth_cubit.dart
- doctor_model.dart
- login_screen.dart
- api_constants.dart

❌ Wrong:
- AuthCubit.dart
- DoctorModel.dart
- LoginScreen.dart
- APIConstants.dart
```

**Rule:** `snake_case` for files, `PascalCase` for classes

---

## 📝 Notes

- **Clean Architecture:** Data → Logic → Presentation
- **BLoC Pattern:** Cubit for state management
- **DI:** GetIt for dependency injection
- **API Client:** Dio with Interceptors
- **Local Storage:** SharedPreferences for tokens
- **Firebase:** Phone Authentication only

---

**Last Updated:** 2026-04-08  
**Version:** 1.0.0-alpha  
**Total Files:** ~35 Dart files  
**Total Lines:** ~11,000+ lines
