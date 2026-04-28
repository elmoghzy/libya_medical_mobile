import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper(this._sharedPreferences);

  static const String lastInstitutionIdKey = 'last_institution_id';
  static const String _legacyInstitutionIdKey = 'institution_id';

  final SharedPreferences _sharedPreferences;

  Future<bool> saveLastInstitutionId(int institutionId) {
    return _sharedPreferences.setInt(lastInstitutionIdKey, institutionId);
  }

  int? getLastInstitutionId() {
    return _sharedPreferences.getInt(lastInstitutionIdKey) ??
        _sharedPreferences.getInt(_legacyInstitutionIdKey);
  }

  Future<bool> clearLastInstitutionId() {
    return _sharedPreferences.remove(lastInstitutionIdKey);
  }
}
