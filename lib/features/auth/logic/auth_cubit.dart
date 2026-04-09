import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_constants.dart';
import '../data/auth_remote_data_source.dart';
import '../data/auth_models.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state
/// Handles OTP flow and backend authentication
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required IAuthRemoteDataSource authDataSource,
    required SharedPreferences sharedPreferences,
  }) : _authDataSource = authDataSource,
       _sharedPreferences = sharedPreferences,
       super(const AuthInitial());

  final IAuthRemoteDataSource _authDataSource;
  final SharedPreferences _sharedPreferences;

  // Keys for SharedPreferences
  static const String _tokenKey = ApiConstants.accessTokenKey;
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';

  /// Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    final token = _sharedPreferences.getString(_tokenKey);
    final roleString = _sharedPreferences.getString(_roleKey);

    if (token != null && token.isNotEmpty) {
      final role = UserRole.fromString(roleString);
      emit(AuthAuthenticated(role: role));
    } else {
      emit(const AuthInitial());
    }
  }

  /// Send OTP to the given phone number
  Future<void> sendOtp(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      emit(
        const AuthError(
          message: 'Please enter your phone number',
          code: 'empty-phone',
        ),
      );
      return;
    }

    // Basic phone validation
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanedPhone.length < 9) {
      emit(
        const AuthError(
          message: 'Please enter a valid phone number',
          code: 'invalid-phone',
        ),
      );
      return;
    }

    emit(const AuthLoading(message: 'Sending verification code...'));

    try {
      final verificationId = await _authDataSource.sendOtp(phoneNumber);

      emit(OtpSent(verificationId: verificationId, phoneNumber: phoneNumber));
    } on AuthException catch (e) {
      emit(
        AuthError(
          message: e.message,
          code: e.code,
          canRetry: e.code != 'too-many-requests',
        ),
      );
    } catch (e) {
      emit(AuthError(message: 'Failed to send OTP: ${e.toString()}'));
    }
  }

  /// Resend OTP (same as sendOtp but with different loading message)
  Future<void> resendOtp(String phoneNumber) async {
    emit(const AuthLoading(message: 'Resending verification code...'));

    try {
      final verificationId = await _authDataSource.sendOtp(phoneNumber);

      emit(OtpSent(verificationId: verificationId, phoneNumber: phoneNumber));
    } on AuthException catch (e) {
      emit(
        AuthError(
          message: e.message,
          code: e.code,
          canRetry: e.code != 'too-many-requests',
        ),
      );
    } catch (e) {
      emit(AuthError(message: 'Failed to resend OTP: ${e.toString()}'));
    }
  }

  /// Verify OTP and authenticate with backend
  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    if (smsCode.isEmpty || smsCode.length < 6) {
      emit(
        const AuthError(
          message: 'Please enter the 6-digit verification code',
          code: 'invalid-otp',
        ),
      );
      return;
    }

    emit(const OtpVerifying());

    try {
      // Step 1: Verify OTP with Firebase
      final firebaseUid = await _authDataSource.verifyOtp(
        verificationId,
        smsCode,
      );

      emit(const AuthLoading(message: 'Completing authentication...'));

      // Step 2: Authenticate with Laravel backend
      final authResponse = await _authDataSource.authenticateWithBackend(
        phoneNumber,
        firebaseUid,
      );

      // Step 3: Save credentials locally
      await _saveAuthData(authResponse);

      // Step 4: Emit success with user role
      emit(
        AuthSuccess(
          role: authResponse.role,
          user: authResponse.user,
          isNewUser: authResponse.user?.isProfileComplete == false,
        ),
      );
    } on AuthException catch (e) {
      emit(
        AuthError(
          message: e.message,
          code: e.code,
          canRetry:
              e.code == 'invalid-verification-code' ||
              e.code == 'session-expired',
        ),
      );
    } catch (e) {
      emit(AuthError(message: 'Verification failed: ${e.toString()}'));
    }
  }

  /// Sign out and clear all auth data
  Future<void> signOut() async {
    emit(const AuthLoading(message: 'Signing out...'));

    try {
      await _authDataSource.signOut();
      await _clearAuthData();
      emit(const AuthLoggedOut());
    } catch (e) {
      // Even if Firebase sign out fails, clear local data
      await _clearAuthData();
      emit(const AuthLoggedOut());
    }
  }

  /// Go back to initial state (e.g., when user wants to change phone number)
  void reset() {
    emit(const AuthInitial());
  }

  /// Go back to OTP sent state (for retry scenarios)
  void goBackToOtpInput(String verificationId, String phoneNumber) {
    emit(OtpSent(verificationId: verificationId, phoneNumber: phoneNumber));
  }

  // ============ Private Helper Methods ============

  Future<void> _saveAuthData(AuthResponse response) async {
    await _sharedPreferences.setString(_tokenKey, response.token);
    await _sharedPreferences.setString(_roleKey, response.role.name);

    if (response.user != null) {
      await _sharedPreferences.setInt(_userIdKey, response.user!.id);
    }
  }

  Future<void> _clearAuthData() async {
    await _sharedPreferences.remove(_tokenKey);
    await _sharedPreferences.remove(_roleKey);
    await _sharedPreferences.remove(_userIdKey);
  }

  // ============ Getters for current auth data ============

  String? get currentToken => _sharedPreferences.getString(_tokenKey);

  UserRole get currentRole =>
      UserRole.fromString(_sharedPreferences.getString(_roleKey));

  bool get isAuthenticated => currentToken != null && currentToken!.isNotEmpty;
}
