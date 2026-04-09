import 'package:equatable/equatable.dart';

import '../data/auth_models.dart';

/// Base class for all authentication states
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the auth feature is first loaded
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State while waiting for async operations
final class AuthLoading extends AuthState {
  const AuthLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// State when OTP has been sent successfully
final class OtpSent extends AuthState {
  const OtpSent({required this.verificationId, required this.phoneNumber});

  final String verificationId;
  final String phoneNumber;

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

/// State when OTP is being verified
final class OtpVerifying extends AuthState {
  const OtpVerifying();
}

/// State when authentication is successful
final class AuthSuccess extends AuthState {
  const AuthSuccess({required this.role, this.user, this.isNewUser = false});

  final UserRole role;
  final UserModel? user;
  final bool isNewUser;

  @override
  List<Object?> get props => [role, user, isNewUser];
}

/// State when user is already authenticated (from saved token)
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.role});

  final UserRole role;

  @override
  List<Object?> get props => [role];
}

/// State when user has logged out
final class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

/// State when an error occurs
final class AuthError extends AuthState {
  const AuthError({required this.message, this.code, this.canRetry = true});

  final String message;
  final String? code;
  final bool canRetry;

  @override
  List<Object?> get props => [message, code, canRetry];
}
