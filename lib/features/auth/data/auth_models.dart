import 'package:equatable/equatable.dart';

/// Enum representing user roles in the system
enum UserRole {
  patient,
  doctor,
  admin,
  unknown;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'patient':
        return UserRole.patient;
      case 'doctor':
        return UserRole.doctor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }

  String toJson() => name;
}

/// Response model from Laravel backend after phone verification
class AuthResponse extends Equatable {
  const AuthResponse({
    required this.token,
    required this.role,
    required this.user,
  });

  /// Parse standard wrapped response: { "data": { "token": ..., "user": { "role": ... } } }
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>?;
    return AuthResponse(
      token: json['token'] as String? ?? '',
      role: UserRole.fromString(userData?['role'] as String? ?? json['role'] as String?),
      user: userData != null ? UserModel.fromJson(userData) : null,
    );
  }

  /// Parse verify-phone flat response: { "token": ..., "role": ..., "user": {...} }
  factory AuthResponse.fromVerifyPhoneJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String token;
  final UserRole role;
  final UserModel? user;

  @override
  List<Object?> get props => [token, role, user];
}

/// User model
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
    );
  }

  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final bool isProfileComplete;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'is_profile_complete': isProfileComplete,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    avatarUrl,
    isProfileComplete,
  ];
}
