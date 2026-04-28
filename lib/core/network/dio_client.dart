import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_constants.dart';
import '../storage/shared_preferences_helper.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final prefsHelper = SharedPreferencesHelper(prefs);
          final token = prefs.getString(ApiConstants.accessTokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final institutionId = prefsHelper.getLastInstitutionId();
          if (institutionId != null) {
            options.headers['X-Institution-ID'] = institutionId.toString();
          }

          handler.next(options);
        },
      ),
    );
  }

  static final DioClient _instance = DioClient._internal();

  late final Dio _dio;

  static DioClient get instance => _instance;

  Dio get client => _dio;
}
