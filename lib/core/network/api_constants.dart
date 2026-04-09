class ApiConstants {
  ApiConstants._();

  // Android emulator access to the host machine's Laravel server.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String accessTokenKey = 'access_token';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

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

  // Rooms Endpoints
  static const String rooms = '/rooms';

  // Notifications Endpoints
  static const String notifications = '/notifications';
  static const String deviceToken = '/notifications/device-token';
}
