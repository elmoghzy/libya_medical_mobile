import 'dart:convert';

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
    this.institutions = const [],
  });

  /// Parse standard wrapped response: { "data": { "token": ..., "user": { "role": ... } } }
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final userData = payload['user'] as Map<String, dynamic>?;
    final user = userData != null ? UserModel.fromJson(userData) : null;

    return AuthResponse(
      token: payload['token'] as String? ?? '',
      role: UserRole.fromString(
        userData?['role'] as String? ?? payload['role'] as String?,
      ),
      user: user,
      institutions: InstitutionModel.fromDynamic(
        payload['institutions'] ?? user?.institutions,
      ),
    );
  }

  /// Parse verify-phone flat response: { "token": ..., "role": ..., "user": {...} }
  factory AuthResponse.fromVerifyPhoneJson(Map<String, dynamic> json) {
    final user = json['user'] != null
        ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
        : null;

    return AuthResponse(
      token: json['token'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      user: user,
      institutions: InstitutionModel.fromDynamic(
        json['institutions'] ?? user?.institutions,
      ),
    );
  }

  final String token;
  final UserRole role;
  final UserModel? user;
  final List<InstitutionModel> institutions;

  @override
  List<Object?> get props => [token, role, user, institutions];
}

class InstitutionModel extends Equatable {
  const InstitutionModel({required this.id, required this.name});

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
    );
  }

  static List<InstitutionModel> fromDynamic(dynamic value) {
    if (value is List<InstitutionModel>) {
      return value;
    }

    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => InstitutionModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  static List<InstitutionModel> fromStoredJson(String? source) {
    if (source == null || source.isEmpty) {
      return const [];
    }

    try {
      return fromDynamic(jsonDecode(source));
    } catch (_) {
      return const [];
    }
  }

  final int id;
  final String name;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  List<Object?> get props => [id, name];
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
    this.institutions = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
      institutions: InstitutionModel.fromDynamic(json['institutions']),
    );
  }

  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final bool isProfileComplete;
  final List<InstitutionModel> institutions;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'is_profile_complete': isProfileComplete,
      'institutions': institutions
          .map((institution) => institution.toJson())
          .toList(),
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
    institutions,
  ];
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}
