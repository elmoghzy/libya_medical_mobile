import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/doctor_model.dart';

/// Exception thrown when doctor operations fail
class DoctorsException implements Exception {
  const DoctorsException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'DoctorsException: $message';
}

/// Abstract interface for doctors data source
abstract class IDoctorsRemoteDataSource {
  /// Get paginated list of doctors
  Future<List<DoctorModel>> getDoctors({int page = 1});

  /// Get doctor details by ID
  Future<DoctorModel> getDoctorDetails(int id);

  /// Get available slots for a doctor on a specific date
  Future<AvailableSlotsModel> getAvailableSlots(int doctorId, String date);
}

/// Implementation of Doctors Remote Data Source
class DoctorsRemoteDataSource implements IDoctorsRemoteDataSource {
  DoctorsRemoteDataSource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;

  /// Get list of all active doctors
  ///
  /// API Response:
  /// {
  ///   "success": true,
  ///   "message": "Doctors retrieved successfully",
  ///   "data": [ { "id": 1, "name": "Dr. Sami", ... } ],
  ///   "meta": { "pagination": { ... } }
  /// }
  @override
  Future<List<DoctorModel>> getDoctors({int page = 1}) async {
    try {
      final response = await _dioClient.client.get<Map<String, dynamic>>(
        '/doctors',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) {
          throw const DoctorsException('Invalid response from server');
        }

        final success = data['success'] as bool? ?? false;
        if (!success) {
          throw DoctorsException(
            data['message'] as String? ?? 'Failed to fetch doctors',
          );
        }

        final doctorsList = data['data'] as List<dynamic>?;
        if (doctorsList == null) {
          return [];
        }

        return doctorsList
            .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw DoctorsException(
        'Server returned status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is DoctorsException) rethrow;
      throw DoctorsException('Failed to fetch doctors: ${e.toString()}');
    }
  }

  /// Get detailed information about a specific doctor
  ///
  /// API Response:
  /// {
  ///   "success": true,
  ///   "message": "Doctor retrieved successfully",
  ///   "data": { "id": 1, "name": "Dr. Sami", "schedules": [...] }
  /// }
  @override
  Future<DoctorModel> getDoctorDetails(int id) async {
    try {
      final response = await _dioClient.client.get<Map<String, dynamic>>(
        '/doctors/$id',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) {
          throw const DoctorsException('Invalid response from server');
        }

        final success = data['success'] as bool? ?? false;
        if (!success) {
          throw DoctorsException(
            data['message'] as String? ?? 'Failed to fetch doctor details',
          );
        }

        final doctorData = data['data'] as Map<String, dynamic>?;
        if (doctorData == null) {
          throw const DoctorsException('Doctor data not found');
        }

        return DoctorModel.fromJson(doctorData);
      }

      throw DoctorsException(
        'Server returned status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is DoctorsException) rethrow;
      throw DoctorsException('Failed to fetch doctor details: ${e.toString()}');
    }
  }

  /// Get available time slots for a doctor on a specific date
  ///
  /// API Response:
  /// {
  ///   "success": true,
  ///   "message": "Available slots retrieved successfully",
  ///   "data": {
  ///     "schedules": [...],
  ///     "slots": ["09:00", "09:20", "09:40"]
  ///   }
  /// }
  @override
  Future<AvailableSlotsModel> getAvailableSlots(
    int doctorId,
    String date,
  ) async {
    try {
      final response = await _dioClient.client.get<Map<String, dynamic>>(
        '/doctors/$doctorId/slots',
        queryParameters: {'date': date},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data == null) {
          throw const DoctorsException('Invalid response from server');
        }

        final success = data['success'] as bool? ?? false;
        if (!success) {
          throw DoctorsException(
            data['message'] as String? ?? 'Failed to fetch available slots',
          );
        }

        final slotsData = data['data'] as Map<String, dynamic>?;
        if (slotsData == null) {
          return const AvailableSlotsModel(schedules: [], slots: []);
        }

        return AvailableSlotsModel.fromJson(slotsData);
      }

      throw DoctorsException(
        'Server returned status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is DoctorsException) rethrow;
      throw DoctorsException(
        'Failed to fetch available slots: ${e.toString()}',
      );
    }
  }

  /// Maps Dio exceptions to DoctorsException
  DoctorsException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const DoctorsException(
          'Connection timed out. Please try again.',
          code: 'timeout',
        );
      case DioExceptionType.connectionError:
        return const DoctorsException(
          'Unable to connect to server. Please check your internet.',
          code: 'connection-error',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Server error occurred.';

        if (data is Map<String, dynamic>) {
          message = data['message'] as String? ?? message;
        }

        if (statusCode == 404) {
          return const DoctorsException('Doctor not found.', code: 'not-found');
        } else if (statusCode == 422) {
          return DoctorsException(message, code: 'validation-error');
        }
        return DoctorsException(message, code: 'server-error');
      default:
        return DoctorsException(
          'An unexpected error occurred: ${e.message}',
          code: 'unknown',
        );
    }
  }
}
