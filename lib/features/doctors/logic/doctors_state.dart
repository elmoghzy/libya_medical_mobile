import 'package:equatable/equatable.dart';

import '../data/models/doctor_model.dart';

/// Base class for all doctors states
sealed class DoctorsState extends Equatable {
  const DoctorsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

/// Loading state while fetching doctors
final class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();
}

/// State when doctors are loaded successfully
final class DoctorsLoaded extends DoctorsState {
  const DoctorsLoaded({
    required this.doctors,
    this.filteredDoctors,
    this.searchQuery = '',
    this.selectedSpecialty,
  });

  final List<DoctorModel> doctors;
  final List<DoctorModel>? filteredDoctors;
  final String searchQuery;
  final String? selectedSpecialty;

  /// Get the list to display (filtered or all)
  List<DoctorModel> get displayDoctors => filteredDoctors ?? doctors;

  /// Get unique specialties from loaded doctors
  List<String> get specialties {
    final specs = doctors.map((d) => d.specialty).toSet().toList();
    specs.sort();
    return specs;
  }

  DoctorsLoaded copyWith({
    List<DoctorModel>? doctors,
    List<DoctorModel>? filteredDoctors,
    String? searchQuery,
    String? selectedSpecialty,
    bool clearFilters = false,
  }) {
    return DoctorsLoaded(
      doctors: doctors ?? this.doctors,
      filteredDoctors: clearFilters
          ? null
          : (filteredDoctors ?? this.filteredDoctors),
      searchQuery: clearFilters ? '' : (searchQuery ?? this.searchQuery),
      selectedSpecialty: clearFilters
          ? null
          : (selectedSpecialty ?? this.selectedSpecialty),
    );
  }

  @override
  List<Object?> get props => [
    doctors,
    filteredDoctors,
    searchQuery,
    selectedSpecialty,
  ];
}

/// Error state
final class DoctorsError extends DoctorsState {
  const DoctorsError({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

// ============ Doctor Details States ============

/// Base class for doctor details states
sealed class DoctorDetailsState extends Equatable {
  const DoctorDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state for doctor details
final class DoctorDetailsInitial extends DoctorDetailsState {
  const DoctorDetailsInitial();
}

/// Loading doctor details
final class DoctorDetailsLoading extends DoctorDetailsState {
  const DoctorDetailsLoading();
}

/// Doctor details loaded successfully
final class DoctorDetailsLoaded extends DoctorDetailsState {
  const DoctorDetailsLoaded({
    required this.doctor,
    this.availableSlots,
    this.selectedDate,
    this.selectedSlot,
  });

  final DoctorModel doctor;
  final AvailableSlotsModel? availableSlots;
  final String? selectedDate;
  final String? selectedSlot;

  DoctorDetailsLoaded copyWith({
    DoctorModel? doctor,
    AvailableSlotsModel? availableSlots,
    String? selectedDate,
    String? selectedSlot,
    bool clearSlots = false,
  }) {
    return DoctorDetailsLoaded(
      doctor: doctor ?? this.doctor,
      availableSlots: clearSlots
          ? null
          : (availableSlots ?? this.availableSlots),
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlot: clearSlots ? null : (selectedSlot ?? this.selectedSlot),
    );
  }

  @override
  List<Object?> get props => [
    doctor,
    availableSlots,
    selectedDate,
    selectedSlot,
  ];
}

/// Error loading doctor details
final class DoctorDetailsError extends DoctorDetailsState {
  const DoctorDetailsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// ============ Slots Loading State (for partial updates) ============

/// Loading available slots (while doctor details are already loaded)
final class SlotsLoading extends DoctorDetailsState {
  const SlotsLoading({required this.doctor, this.selectedDate});

  final DoctorModel doctor;
  final String? selectedDate;

  @override
  List<Object?> get props => [doctor, selectedDate];
}
