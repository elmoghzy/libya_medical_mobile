import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(_initialLocale(_prefs));

  static const _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  static Locale _initialLocale(SharedPreferences prefs) {
    final code = prefs.getString(_localeKey);
    if (code == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) {
      return;
    }

    emit(locale);
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleLocale() {
    return setLocale(
      state.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar'),
    );
  }
}