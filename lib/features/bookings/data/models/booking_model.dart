import 'package:equatable/equatable.dart';

import '../../../doctors/data/models/doctor_model.dart';

/// Booking Model representing a booking entity
class BookingModel extends Equatable {
  const BookingModel({
    required this.id,
    required this.userId,
    required this.bookableTypeKey,
    required this.bookableId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.queueNumber,
    this.endDate,
    this.checkedInAt,
    this.startedAt,
    this.completedAt,
    this.bookable,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String bookableTypeKey; // "doctor" or "room"
  final int bookableId;
  final String bookingDate; // YYYY-MM-DD
  final String bookingTime; // HH:MM
  final String
  status; // "confirmed", "checked_in", "in_progress", "completed", "cancelled"
  final int? queueNumber;
  final String? endDate; // For room bookings
  final String? checkedInAt;
  final String? startedAt;
  final String? completedAt;
  final BookableInfo? bookable; // Doctor or Room info
  final String? createdAt;
  final String? updatedAt;

  /// Create from JSON (from API response data object)
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bookableTypeKey: json['bookable_type_key'] as String,
      bookableId: json['bookable_id'] as int,
      bookingDate: json['booking_date'] as String,
      bookingTime: json['booking_time'] as String,
      status: json['status'] as String,
      queueNumber: json['queue_number'] as int?,
      endDate: json['end_date'] as String?,
      checkedInAt: json['checked_in_at'] as String?,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
      bookable: json['bookable'] != null
          ? BookableInfo.fromJson(json['bookable'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Create from wrapped API response: {"success": true, "data": {...}}
  factory BookingModel.fromApiResponse(Map<String, dynamic> response) {
    if (response['success'] == true && response['data'] != null) {
      return BookingModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception('Invalid API response format');
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bookable_type_key': bookableTypeKey,
      'bookable_id': bookableId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'status': status,
      'queue_number': queueNumber,
      'end_date': endDate,
      'checked_in_at': checkedInAt,
      'started_at': startedAt,
      'completed_at': completedAt,
      'bookable': bookable?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    bookableTypeKey,
    bookableId,
    bookingDate,
    bookingTime,
    status,
    queueNumber,
    endDate,
    checkedInAt,
    startedAt,
    completedAt,
    bookable,
    createdAt,
    updatedAt,
  ];

  /// Copy with method for immutability
  BookingModel copyWith({
    int? id,
    int? userId,
    String? bookableTypeKey,
    int? bookableId,
    String? bookingDate,
    String? bookingTime,
    String? status,
    int? queueNumber,
    String? endDate,
    String? checkedInAt,
    String? startedAt,
    String? completedAt,
    BookableInfo? bookable,
    String? createdAt,
    String? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookableTypeKey: bookableTypeKey ?? this.bookableTypeKey,
      bookableId: bookableId ?? this.bookableId,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      status: status ?? this.status,
      queueNumber: queueNumber ?? this.queueNumber,
      endDate: endDate ?? this.endDate,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      bookable: bookable ?? this.bookable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if booking is for a doctor
  bool get isDoctor => bookableTypeKey == 'doctor';

  /// Check if booking is for a room
  bool get isRoom => bookableTypeKey == 'room';

  /// Get status display text in Arabic
  String get statusDisplayText {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'checked_in':
        return 'تم تسجيل الحضور';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

/// Bookable Info (Doctor or Room details nested in booking)
class BookableInfo extends Equatable {
  const BookableInfo({
    required this.model,
    required this.id,
    required this.name,
    this.specialty,
    this.consultationFee,
    this.isActive,
    this.roomNumber,
    this.type,
    this.dailyRate,
  });

  final String model; // "doctor" or "room"
  final int id;
  final String name;

  // Doctor-specific fields
  final String? specialty;
  final String? consultationFee;
  final bool? isActive;

  // Room-specific fields
  final String? roomNumber;
  final String? type; // "normal", "private"
  final String? dailyRate;

  factory BookableInfo.fromJson(Map<String, dynamic> json) {
    return BookableInfo(
      model: json['model'] as String,
      id: json['id'] as int,
      name: json['name'] as String,
      specialty: json['specialty'] as String?,
      consultationFee: json['consultation_fee'] as String?,
      isActive: json['is_active'] as bool?,
      roomNumber: json['room_number'] as String?,
      type: json['type'] as String?,
      dailyRate: json['daily_rate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'id': id,
      'name': name,
      if (specialty != null) 'specialty': specialty,
      if (consultationFee != null) 'consultation_fee': consultationFee,
      if (isActive != null) 'is_active': isActive,
      if (roomNumber != null) 'room_number': roomNumber,
      if (type != null) 'type': type,
      if (dailyRate != null) 'daily_rate': dailyRate,
    };
  }

  @override
  List<Object?> get props => [
    model,
    id,
    name,
    specialty,
    consultationFee,
    isActive,
    roomNumber,
    type,
    dailyRate,
  ];

  /// Convert to DoctorModel if applicable
  DoctorModel? toDoctor() {
    if (model != 'doctor') return null;

    // Parse consultation fee to double
    double parsedFee = 0.0;
    if (consultationFee != null) {
      parsedFee = double.tryParse(consultationFee!) ?? 0.0;
    }

    return DoctorModel(
      id: id,
      name: name,
      specialty: specialty ?? '',
      consultationFee: parsedFee,
      isActive: isActive ?? true,
    );
  }
}

/// Custom exception for bookings operations
class BookingsException implements Exception {
  BookingsException({required this.message, this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'BookingsException: $message (code: $code)';
}
