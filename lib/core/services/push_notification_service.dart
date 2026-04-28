import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/data/notifications_remote_data_source.dart';

class PushNotificationService {
  static const String _foregroundChannelId = 'high_importance_notifications';
  static const String _foregroundChannelName = 'High Importance Notifications';
  static const String _foregroundChannelDescription =
      'Used to display heads-up notifications while the app is open.';
  static const AndroidNotificationChannel _foregroundChannel =
      AndroidNotificationChannel(
        _foregroundChannelId,
        _foregroundChannelName,
        description: _foregroundChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
  static const NotificationDetails _foregroundNotificationDetails =
      NotificationDetails(
        android: AndroidNotificationDetails(
          _foregroundChannelId,
          _foregroundChannelName,
          channelDescription: _foregroundChannelDescription,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  PushNotificationService({
    required INotificationsRemoteDataSource notificationsRemoteDataSource,
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin,
  }) : _notificationsRemoteDataSource = notificationsRemoteDataSource,
       _firebaseMessaging = firebaseMessaging,
       _flutterLocalNotificationsPlugin =
           flutterLocalNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  final INotificationsRemoteDataSource _notificationsRemoteDataSource;
  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  bool _isInitialized = false;
  bool _localNotificationsInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (!_isFirebaseMessagingSupported()) {
      debugPrint('Push notifications are not supported on this platform.');
      return;
    }

    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase is not initialized. Skipping push notifications.');
      return;
    }

    final firebaseMessaging = _firebaseMessaging ??= FirebaseMessaging.instance;
    await _initializeLocalNotifications();

    final permissionSettings = await firebaseMessaging.requestPermission();
    debugPrint(
      'FCM permission status: ${permissionSettings.authorizationStatus.name}',
    );
    await _requestLocalNotificationPermissions();

    final token = await firebaseMessaging.getToken();
    await _registerDeviceToken(token);

    _tokenRefreshSubscription ??= firebaseMessaging.onTokenRefresh.listen(
      (token) async {
        debugPrint('FCM token refreshed.');
        await _registerDeviceToken(token);
      },
      onError: (Object error) {
        debugPrint('FCM token refresh listener error: $error');
      },
    );

    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((
      message,
    ) async {
      debugPrint('FCM foreground message ID: ${message.messageId}');
      debugPrint('FCM foreground data: ${message.data}');
      debugPrint('FCM foreground title: ${message.notification?.title}');
      debugPrint('FCM foreground body: ${message.notification?.body}');
      await _showForegroundNotification(message);
    });

    _isInitialized = true;
  }

  Future<void> syncCurrentDeviceToken() async {
    if (!_isFirebaseMessagingSupported() || Firebase.apps.isEmpty) {
      return;
    }

    final firebaseMessaging = _firebaseMessaging ??= FirebaseMessaging.instance;
    final token = await firebaseMessaging.getToken();
    await _registerDeviceToken(token);
  }

  Future<void> _registerDeviceToken(String? token) async {
    if (token == null || token.isEmpty) {
      debugPrint('FCM token is unavailable.');
      return;
    }

    try {
      await _notificationsRemoteDataSource.saveDeviceToken(token);
      debugPrint('FCM device token registered successfully.');
    } catch (e) {
      debugPrint('Failed to register FCM device token: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) {
      return;
    }

    if (kIsWeb) {
      debugPrint('Local notifications are not supported on web.');
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );
    } catch (e) {
      debugPrint('Failed to initialize local notifications: $e');
      return;
    }

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(_foregroundChannel);

    _localNotificationsInitialized = true;
  }

  Future<void> _requestLocalNotificationPermissions() async {
    if (!_localNotificationsInitialized) {
      return;
    }

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidPermissionGranted = await androidImplementation
        ?.requestNotificationsPermission();
    if (androidPermissionGranted != null) {
      debugPrint(
        'Local Android notification permission granted: '
        '$androidPermissionGranted',
      );
    }

    final iosImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosPermissionGranted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosPermissionGranted != null) {
      debugPrint(
        'Local iOS notification permission granted: $iosPermissionGranted',
      );
    }

    final macOsImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final macOsPermissionGranted = await macOsImplementation
        ?.requestPermissions(alert: true, badge: true, sound: true);
    if (macOsPermissionGranted != null) {
      debugPrint(
        'Local macOS notification permission granted: '
        '$macOsPermissionGranted',
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!_localNotificationsInitialized) {
      return;
    }

    final notification = message.notification;
    final title = _normalizeNotificationText(notification?.title);
    final body = _normalizeNotificationText(notification?.body);
    if (title == null && body == null) {
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        id: message.messageId?.hashCode ?? message.hashCode,
        title: title,
        body: body,
        notificationDetails: _foregroundNotificationDetails,
      );
    } catch (e) {
      debugPrint('Failed to display foreground notification: $e');
    }
  }

  String? _normalizeNotificationText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  bool _isFirebaseMessagingSupported() {
    if (kIsWeb) {
      return true;
    }

    try {
      return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }
}
