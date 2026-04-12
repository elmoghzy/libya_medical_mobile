import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(instance != null, 'AppLocalizations is not initialized.');
    return instance!;
  }

  bool get isArabic => locale.languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Libya Medical',
      'language': 'Language',
      'switchToArabic': 'Switch to Arabic',
      'switchToEnglish': 'Switch to English',
      'home': 'Home',
      'search': 'Search',
      'bookings': 'Bookings',
      'profile': 'Profile',
      'queue': 'Queue',
      'schedule': 'Schedule',
      'welcome': 'Welcome',
      'enterPhonePrompt':
          'Enter your phone number to receive a verification code.',
      'phoneNumber': 'Phone Number',
      'invalidPhone': 'Enter a valid Libyan phone number',
      'emptyPhone': 'Please enter your phone number',
      'sendOtp': 'Send OTP',
      'pleaseWait': 'Please wait...',
      'smsCodeInfo': 'We will send you a 6-digit verification code via SMS.',
      'devModeOnly': 'Development Mode Only',
      'loginAsPatient': 'Login as Patient',
      'loginAsDoctor': 'Login as Doctor',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'helpCenter': 'Help Center',
      'retry': 'Retry',
      'devModeLoggedInAs': 'DEV MODE: Logged in as {role}',
      'patient': 'Patient',
      'doctor': 'Doctor',
      'scheduleManagerTitle': 'Schedule Manager',
      'scheduleManagerSubtitle': 'Set your weekly availability',
      'published': 'Published',
      'week': 'Week',
      'editAll': 'Edit All',
      'noAvailabilityTitle': 'No Availability Set',
      'noAvailabilityMessage':
          'You haven\'t set any working hours for this day.\nTap the button below to add a time slot.',
      'addTimeSlot': 'Add Time Slot',
      'clinicHours': 'Clinic Hours',
      'clinic': 'Clinic',
      'surgery': 'Surgery',
      'teleconsult': 'Teleconsult',
      'edit': 'Edit',
      'duplicate': 'Duplicate',
      'delete': 'Delete',
      'thisWeeksSummary': 'This Week\'s Summary',
      'totalHours': 'Total Hours',
      'workingDays': 'Working Days',
      'slots': 'Slots',
      'slotType': 'SLOT TYPE',
      'startTime': 'START TIME',
      'endTime': 'END TIME',
      'repeat': 'REPEAT',
      'thisDayOnly': 'This Day Only',
      'everyWeek': 'Every Week',
      'cancel': 'Cancel',
      'hoursShort': '{hours}h',
      'hoursMinutesShort': '{hours}h {minutes}m',
    },
    'ar': {
      'appName': 'ليبيا الطبية',
      'language': 'اللغة',
      'switchToArabic': 'التحويل إلى العربية',
      'switchToEnglish': 'التحويل إلى الإنجليزية',
      'home': 'الرئيسية',
      'search': 'بحث',
      'bookings': 'الحجوزات',
      'profile': 'الملف الشخصي',
      'queue': 'الطابور',
      'schedule': 'الجدول',
      'welcome': 'مرحبًا',
      'enterPhonePrompt': 'أدخل رقم هاتفك لاستلام رمز التحقق.',
      'phoneNumber': 'رقم الهاتف',
      'invalidPhone': 'أدخل رقم هاتف ليبي صحيح',
      'emptyPhone': 'يرجى إدخال رقم الهاتف',
      'sendOtp': 'إرسال الرمز',
      'pleaseWait': 'يرجى الانتظار...',
      'smsCodeInfo': 'سنرسل لك رمز تحقق مكوّن من 6 أرقام عبر الرسائل.',
      'devModeOnly': 'وضع التطوير فقط',
      'loginAsPatient': 'دخول كمريض',
      'loginAsDoctor': 'دخول كطبيب',
      'privacyPolicy': 'سياسة الخصوصية',
      'termsOfService': 'شروط الاستخدام',
      'helpCenter': 'مركز المساعدة',
      'retry': 'إعادة المحاولة',
      'devModeLoggedInAs': 'وضع التطوير: تم تسجيل الدخول كـ {role}',
      'patient': 'مريض',
      'doctor': 'طبيب',
      'scheduleManagerTitle': 'إدارة الجدول',
      'scheduleManagerSubtitle': 'حدّد مواعيد توفرك الأسبوعية',
      'published': 'منشور',
      'week': 'الأسبوع',
      'editAll': 'تعديل الكل',
      'noAvailabilityTitle': 'لا توجد أوقات متاحة',
      'noAvailabilityMessage':
          'لم تقم بتحديد ساعات العمل لهذا اليوم.\nاضغط الزر بالأسفل لإضافة فترة زمنية.',
      'addTimeSlot': 'إضافة فترة زمنية',
      'clinicHours': 'ساعات العيادة',
      'clinic': 'عيادة',
      'surgery': 'عمليات',
      'teleconsult': 'استشارة عن بُعد',
      'edit': 'تعديل',
      'duplicate': 'نسخ',
      'delete': 'حذف',
      'thisWeeksSummary': 'ملخص هذا الأسبوع',
      'totalHours': 'إجمالي الساعات',
      'workingDays': 'أيام العمل',
      'slots': 'الفترات',
      'slotType': 'نوع الفترة',
      'startTime': 'وقت البداية',
      'endTime': 'وقت النهاية',
      'repeat': 'التكرار',
      'thisDayOnly': 'هذا اليوم فقط',
      'everyWeek': 'كل أسبوع',
      'cancel': 'إلغاء',
      'hoursShort': '{hours} س',
      'hoursMinutesShort': '{hours} س {minutes} د',
    },
  };

  String tr(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String trWithArgs(String key, Map<String, String> args) {
    var value = tr(key);
    args.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String locText({required String en, required String ar}) {
    return l10n.isArabic ? ar : en;
  }

  String get localeCode => l10n.locale.languageCode;
}
