import 'package:equatable/equatable.dart';

/// Schedule model for doctor availability
class ScheduleModel extends Equatable {
  const ScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.avgConsultationTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int? ?? 0,
      dayOfWeek: json['day_of_week'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      avgConsultationTime: json['avg_consultation_time'] as int? ?? 20,
    );
  }

  final int id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int avgConsultationTime;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'avg_consultation_time': avgConsultationTime,
    };
  }

  @override
  List<Object?> get props => [
    id,
    dayOfWeek,
    startTime,
    endTime,
    avgConsultationTime,
  ];
}

/// Doctor model matching the API response
class DoctorModel extends Equatable {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.consultationFee,
    required this.isActive,
    this.schedules = const [],
    this.imageUrl,
    this.rating,
    this.reviewCount,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      consultationFee: _parseDouble(json['consultation_fee']),
      isActive: json['is_active'] as bool? ?? true,
      schedules:
          (json['schedules'] as List<dynamic>?)
              ?.map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      imageUrl: json['image_url'] as String?,
      rating: _parseDouble(json['rating']),
      reviewCount: json['review_count'] as int?,
    );
  }

  final int id;
  final String name;
  final String specialty;
  final double consultationFee;
  final bool isActive;
  final List<ScheduleModel> schedules;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;

  /// Parse consultation fee from various formats
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Formatted consultation fee with currency
  String get formattedFee => '${consultationFee.toStringAsFixed(0)} LYD';

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'consultation_fee': consultationFee.toString(),
      'is_active': isActive,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    specialty,
    consultationFee,
    isActive,
    schedules,
    imageUrl,
    rating,
    reviewCount,
  ];
}

/// Available slots response model
class AvailableSlotsModel extends Equatable {
  const AvailableSlotsModel({required this.schedules, required this.slots});

  factory AvailableSlotsModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsModel(
      schedules:
          (json['schedules'] as List<dynamic>?)
              ?.map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }

  final List<ScheduleModel> schedules;
  final List<String> slots;

  @override
  List<Object?> get props => [schedules, slots];
}
