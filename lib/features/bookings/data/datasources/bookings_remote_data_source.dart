import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/booking_model.dart';

/// Interface for Bookings Remote Data Source
abstract class IBookingsRemoteDataSource {
  /// Create a new booking (doctor or room)
  Future<BookingModel> createBooking(Map<String, dynamic> bookingData);

  /// Get all bookings for the authenticated user
  Future<List<BookingModel>> getMyBookings();

  /// Cancel a booking
  Future<BookingModel> cancelBooking(int bookingId);

  /// Check in to a booking (for queue tracking)
  Future<BookingModel> checkInBooking(int bookingId);
}

/// Implementation of Bookings Remote Data Source
class BookingsRemoteDataSource implements IBookingsRemoteDataSource {
  final DioClient _dioClient = DioClient.instance;

  @override
  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _dioClient.client.post(
        ApiConstants.bookings,
        data: bookingData,
      );

      if (response.data['success'] == true) {
        return BookingModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw BookingsException(
          message: response.data['message'] as String? ?? 'فشل إنشاء الحجز',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        // Handle specific error codes
        if (statusCode == 409) {
          // Conflict - slot already booked or duplicate booking
          throw BookingsException(
            message: data['message'] as String? ?? 'هذا الموعد محجوز بالفعل',
            code: statusCode,
          );
        } else if (statusCode == 400) {
          // Bad request - doctor/room not available
          throw BookingsException(
            message:
                data['message'] as String? ?? 'غير متاح للحجز في الوقت الحالي',
            code: statusCode,
          );
        } else if (statusCode == 422) {
          // Validation error
          final errors = data['errors'];
          String errorMessage = 'خطأ في البيانات المدخلة';
          if (errors != null && errors is Map) {
            errorMessage = errors.values.first[0] as String;
          }
          throw BookingsException(message: errorMessage, code: statusCode);
        } else if (statusCode == 401) {
          throw BookingsException(
            message: 'يجب تسجيل الدخول أولاً',
            code: statusCode,
          );
        }
      }

      // Network error
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw BookingsException(
          message: 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw BookingsException(message: 'لا يوجد اتصال بالإنترنت');
      }

      throw BookingsException(message: e.message ?? 'حدث خطأ في الشبكة');
    } catch (e) {
      if (e is BookingsException) rethrow;
      throw BookingsException(message: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dioClient.client.get(
        ApiConstants.bookings,
      );

      if (response.data['success'] == true) {
        final List<dynamic> bookingsData = response.data['data'] as List;
        return bookingsData
            .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw BookingsException(
          message: response.data['message'] as String? ?? 'فشل جلب الحجوزات',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw BookingsException(message: 'يجب تسجيل الدخول أولاً', code: 401);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw BookingsException(
          message: 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw BookingsException(message: 'لا يوجد اتصال بالإنترنت');
      }

      throw BookingsException(message: e.message ?? 'حدث خطأ في الشبكة');
    } catch (e) {
      if (e is BookingsException) rethrow;
      throw BookingsException(message: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> cancelBooking(int bookingId) async {
    try {
      final response = await _dioClient.client.post(
        ApiConstants.cancelBooking(bookingId),
      );

      if (response.data['success'] == true) {
        return BookingModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw BookingsException(
          message: response.data['message'] as String? ?? 'فشل إلغاء الحجز',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 400) {
          throw BookingsException(
            message: data['message'] as String? ?? 'لا يمكن إلغاء هذا الحجز',
            code: statusCode,
          );
        } else if (statusCode == 404) {
          throw BookingsException(message: 'الحجز غير موجود', code: statusCode);
        } else if (statusCode == 401) {
          throw BookingsException(
            message: 'يجب تسجيل الدخول أولاً',
            code: statusCode,
          );
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw BookingsException(
          message: 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw BookingsException(message: 'لا يوجد اتصال بالإنترنت');
      }

      throw BookingsException(message: e.message ?? 'حدث خطأ في الشبكة');
    } catch (e) {
      if (e is BookingsException) rethrow;
      throw BookingsException(message: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> checkInBooking(int bookingId) async {
    try {
      final response = await _dioClient.client.post(
        ApiConstants.checkIn(bookingId),
      );

      if (response.data['success'] == true) {
        return BookingModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw BookingsException(
          message: response.data['message'] as String? ?? 'فشل تسجيل الحضور',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 400) {
          throw BookingsException(
            message:
                data['message'] as String? ?? 'لا يمكن تسجيل الحضور لهذا الحجز',
            code: statusCode,
          );
        } else if (statusCode == 404) {
          throw BookingsException(message: 'الحجز غير موجود', code: statusCode);
        } else if (statusCode == 401) {
          throw BookingsException(
            message: 'يجب تسجيل الدخول أولاً',
            code: statusCode,
          );
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw BookingsException(
          message: 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw BookingsException(message: 'لا يوجد اتصال بالإنترنت');
      }

      throw BookingsException(message: e.message ?? 'حدث خطأ في الشبكة');
    } catch (e) {
      if (e is BookingsException) rethrow;
      throw BookingsException(message: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }
}
