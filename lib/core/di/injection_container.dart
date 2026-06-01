import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/locale_cubit.dart';
import '../services/push_notification_service.dart';
import '../services/reverb_echo_service.dart';
import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/logic/auth_cubit.dart';
import '../../features/bookings/data/datasources/bookings_remote_data_source.dart';
import '../../features/bookings/logic/bookings_cubit.dart';
import '../../features/doctors/data/datasources/doctors_remote_data_source.dart';
import '../../features/doctors/logic/doctor_details_cubit.dart';
import '../../features/doctors/logic/doctors_cubit.dart';
import '../../features/notifications/data/notifications_remote_data_source.dart';
import '../../features/queue/logic/clinic_queue_cubit.dart';

final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // ============ External ============
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // ============ Data Sources ============
  // AuthRemoteDataSource with error handling for platforms without Firebase
  sl.registerLazySingleton<IAuthRemoteDataSource>(() {
    try {
      return AuthRemoteDataSource();
    } catch (e, stackTrace) {
      debugPrint('Error while creating IAuthRemoteDataSource: $e');
      debugPrint('Stack trace:');
      debugPrint('$stackTrace');
      // Return a safe instance that won't crash
      // (sendOtp will throw a proper error when called)
      rethrow;
    }
  });

  sl.registerLazySingleton<IDoctorsRemoteDataSource>(
    () => DoctorsRemoteDataSource(),
  );
  sl.registerLazySingleton<IBookingsRemoteDataSource>(
    () => BookingsRemoteDataSource(),
  );
  sl.registerLazySingleton<INotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSource(),
  );

  // ============ Services ============
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      notificationsRemoteDataSource: sl<INotificationsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<ReverbEchoService>(() => ReverbEchoService());

  // ============ Cubits ============
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      authDataSource: sl<IAuthRemoteDataSource>(),
      sharedPreferences: sl<SharedPreferences>(),
      pushNotificationService: sl<PushNotificationService>(),
    ),
  );

  sl.registerFactory<DoctorsCubit>(
    () => DoctorsCubit(doctorsDataSource: sl<IDoctorsRemoteDataSource>()),
  );

  sl.registerFactory<DoctorDetailsCubit>(
    () => DoctorDetailsCubit(doctorsDataSource: sl<IDoctorsRemoteDataSource>()),
  );

  sl.registerFactory<BookingsCubit>(
    () => BookingsCubit(bookingsDataSource: sl<IBookingsRemoteDataSource>()),
  );

  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<ClinicQueueCubit>(
    () => ClinicQueueCubit(reverbEchoService: sl<ReverbEchoService>()),
  );
}
