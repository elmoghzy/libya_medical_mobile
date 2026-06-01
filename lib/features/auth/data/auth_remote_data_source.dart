import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

/// Exception thrown when authentication fails
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Abstract interface for auth data source
abstract class IAuthRemoteDataSource {
  /// Sends OTP to the given phone number
  Future<String> sendOtp(String phoneNumber);

  /// Verifies the OTP code and returns Firebase ID token
  Future<String> verifyOtp(String verificationId, String smsCode);

  /// Authenticates with Laravel backend using Firebase ID token
  Future<AuthResponse> authenticateWithBackend(String idToken, String name);

  /// Persists the active workspace on the backend
  Future<void> setActiveWorkspace(int institutionId);

  /// Signs out the user
  Future<void> signOut();
}

/// Implementation of Auth Remote Data Source
/// Handles Firebase Phone Authentication and Laravel backend integration
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  AuthRemoteDataSource({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  static const String _doctorNotWhitelistedMessage =
      'عذراً، رقمك غير مسجل في النظام. يرجى مراجعة إدارة العيادة.';
  static const String _doctorNotWhitelistedCode = 'doctor-not-whitelisted';

  final DioClient _dioClient;

  // Lazy-initialized FirebaseAuth (only when Firebase is available)
  FirebaseAuth? _firebaseAuth;
  FirebaseAuth get firebaseAuth {
    if (_firebaseAuth == null) {
      if (!_isFirebaseAvailable()) {
        throw const AuthException(
          'Firebase is not available on this platform',
          code: 'firebase-not-available',
        );
      }
      _firebaseAuth = FirebaseAuth.instance;
    }
    return _firebaseAuth!;
  }

  // Completer to handle async Firebase callbacks
  Completer<String>? _verificationCompleter;

  /// Sends OTP to the phone number via Firebase
  /// Returns the verificationId needed for OTP verification
  @override
  Future<String> sendOtp(String phoneNumber) async {
    await _ensureDoctorPhoneIsWhitelisted(phoneNumber);

    // Check if Firebase is available (not on Linux/Windows desktop)
    if (!_isFirebaseAvailable()) {
      throw const AuthException(
        'Phone authentication is not available on this platform. Please use Dev Mode buttons on Login screen.',
        code: 'platform-not-supported',
      );
    }

    _verificationCompleter = Completer<String>();

    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: _formatPhoneNumberForFirebase(phoneNumber),
        timeout: const Duration(seconds: 60),
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onAutoRetrievalTimeout,
      );

      // Wait for codeSent callback to complete
      final verificationId = await _verificationCompleter!.future.timeout(
        const Duration(seconds: 65),
        onTimeout: () => throw const AuthException(
          'OTP request timed out. Please try again.',
          code: 'timeout',
        ),
      );

      return verificationId;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to send OTP: ${e.toString()}');
    }
  }

  Future<void> _ensureDoctorPhoneIsWhitelisted(String phoneNumber) async {
    try {
      final response = await _dioClient.client.post<Map<String, dynamic>>(
        ApiConstants.checkDoctorPhone,
        data: {'phone': _formatPhoneNumberForApi(phoneNumber)},
      );

      final data = response.data;
      if (data == null) {
        throw const AuthException(
          'Invalid response from server',
          code: 'invalid-response',
        );
      }

      if (data['success'] != true) {
        throw const AuthException(
          _doctorNotWhitelistedMessage,
          code: _doctorNotWhitelistedCode,
        );
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final statusCode = e.response?.statusCode;
      final success = responseData is Map<String, dynamic>
          ? responseData['success'] == true
          : null;

      if (statusCode == 403 || success == false) {
        throw const AuthException(
          _doctorNotWhitelistedMessage,
          code: _doctorNotWhitelistedCode,
        );
      }

      throw _mapDioException(e);
    }
  }

  /// Check if Firebase is available on current platform
  bool _isFirebaseAvailable() {
    try {
      // Firebase is only available on: Android, iOS, Web, macOS
      if (kIsWeb) return true;
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        // Also check if Firebase is actually initialized
        return Firebase.apps.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verifies the OTP code with Firebase
  /// Returns the Firebase user's ID token
  @override
  Future<String> verifyOtp(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(
          'Failed to verify OTP. Please try again.',
          code: 'null-user',
        );
      }

      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw const AuthException(
          'Failed to get ID token.',
          code: 'null-token',
        );
      }
      return idToken;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }

  /// Authenticates with Laravel backend
  /// Sends Firebase ID token and user name to get Sanctum token
  ///
  /// API Response format (flat JSON):
  /// {
  ///   "token": "1|example_plain_text_token",
  ///   "role": "patient",
  ///   "user": { "id": 1, "name": "...", "phone": "..." }
  /// }
  @override
  Future<AuthResponse> authenticateWithBackend(String idToken, String name)
    async {
    try {
      final response = await _dioClient.client.post<Map<String, dynamic>>(
        ApiConstants.verifyPhone,
        data: {'id_token': idToken, 'name': name},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data == null) {
          throw const AuthException(
            'Invalid response from server',
            code: 'invalid-response',
          );
        }

        // API returns flat JSON (no success/data wrapper)
        // Check if there's an error response
        if (data.containsKey('success') && data['success'] == false) {
          throw AuthException(
            data['message'] as String? ?? 'Authentication failed',
            code: 'server-error',
          );
        }

        return AuthResponse.fromVerifyPhoneJson(data);
      }

      throw AuthException(
        'Server returned status code: ${response.statusCode}',
        code: 'server-error',
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Backend authentication failed: ${e.toString()}');
    }
  }

  @override
  Future<void> setActiveWorkspace(int institutionId) async {
    try {
      await _dioClient.client.post<void>(
        ApiConstants.setActiveWorkspace,
        data: {'institution_id': institutionId},
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to set active workspace: ${e.toString()}');
    }
  }

  /// Signs out from both Firebase and clears local session
  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  // ============ Firebase Callback Handlers ============

  void _onVerificationCompleted(PhoneAuthCredential credential) {
    // Auto-verification completed (Android only)
    // The credential can be used to sign in automatically
    // For now, we don't auto-sign in; let user enter OTP manually
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    _verificationCompleter?.completeError(_mapFirebaseException(e));
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    _verificationCompleter?.complete(verificationId);
  }

  void _onAutoRetrievalTimeout(String verificationId) {
    // Auto-retrieval timed out, user needs to enter OTP manually
    if (!(_verificationCompleter?.isCompleted ?? true)) {
      _verificationCompleter?.complete(verificationId);
    }
  }

  // ============ Helper Methods ============

  /// Formats phone number to E.164 format for Firebase (+218...)
  String _formatPhoneNumberForFirebase(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.startsWith('+')) {
      return cleaned;
    }

    // Remove leading zeros
    cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');

    // Add Libya country code (+218) if not present
    if (!cleaned.startsWith('218')) {
      cleaned = '218$cleaned';
    }

    return '+$cleaned';
  }

  /// Formats phone number for API (+218...)
  String _formatPhoneNumberForApi(String phone) {
    return _formatPhoneNumberForFirebase(phone);
  }

  /// Maps Firebase exceptions to AuthException
  AuthException _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return const AuthException(
          'The phone number is invalid. Please check and try again.',
          code: 'invalid-phone-number',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'invalid-verification-code':
        return const AuthException(
          'The OTP code is incorrect. Please try again.',
          code: 'invalid-verification-code',
        );
      case 'session-expired':
        return const AuthException(
          'The OTP has expired. Please request a new code.',
          code: 'session-expired',
        );
      case 'quota-exceeded':
        return const AuthException(
          'SMS quota exceeded. Please try again later.',
          code: 'quota-exceeded',
        );
      case 'network-request-failed':
        return const AuthException(
          'Network error. Please check your connection.',
          code: 'network-error',
        );
      default:
        return AuthException(
          e.message ?? 'Authentication failed. Please try again.',
          code: e.code,
        );
    }
  }

  /// Maps Dio exceptions to AuthException
  AuthException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AuthException(
          'Connection timed out. Please try again.',
          code: 'timeout',
        );
      case DioExceptionType.connectionError:
        return const AuthException(
          'Unable to connect to server. Please check your internet.',
          code: 'connection-error',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = 'Server error occurred.';

        if (data is Map<String, dynamic>) {
          message = data['message'] as String? ?? message;

          // Handle validation errors (422)
          if (statusCode == 422 && data['errors'] != null) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          }
        }

        if (statusCode == 401) {
          return AuthException(message, code: 'unauthorized');
        } else if (statusCode == 422) {
          return AuthException(message, code: 'validation-error');
        } else if (statusCode == 400) {
          return AuthException(message, code: 'bad-request');
        } else if (statusCode == 404) {
          return const AuthException(
            'User not found. Please register first.',
            code: 'not-found',
          );
        }
        return AuthException(message, code: 'server-error');
      default:
        return AuthException(
          'An unexpected error occurred: ${e.message}',
          code: 'unknown',
        );
    }
  }
}
