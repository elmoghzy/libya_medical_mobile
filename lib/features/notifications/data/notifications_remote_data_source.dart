import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class NotificationsRemoteDataSourceException implements Exception {
  const NotificationsRemoteDataSourceException(this.message);

  final String message;

  @override
  String toString() => 'NotificationsRemoteDataSourceException: $message';
}

abstract class INotificationsRemoteDataSource {
  Future<void> saveDeviceToken(String token);
}

class NotificationsRemoteDataSource implements INotificationsRemoteDataSource {
  NotificationsRemoteDataSource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  final DioClient _dioClient;
  static const String _deviceTokenEndpoint = '/notifications/device-token';

  @override
  Future<void> saveDeviceToken(String token) async {
    try {
      await _dioClient.client.post<void>(
        _deviceTokenEndpoint,
        data: <String, dynamic>{'device_token': token},
      );
    } on DioException catch (e) {
      throw NotificationsRemoteDataSourceException(
        e.response?.data is Map<String, dynamic>
            ? (e.response!.data['message'] as String? ??
                  'Failed to save device token.')
            : 'Failed to save device token.',
      );
    } catch (e) {
      if (e is NotificationsRemoteDataSourceException) {
        rethrow;
      }
      throw NotificationsRemoteDataSourceException(
        'Failed to save device token.',
      );
    }
  }
}
