import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/doctors_remote_data_source.dart';
import '../data/models/doctor_model.dart';
import 'doctors_state.dart';

/// Cubit for managing single doctor details and available slots
class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  DoctorDetailsCubit({required IDoctorsRemoteDataSource doctorsDataSource})
    : _doctorsDataSource = doctorsDataSource,
      super(const DoctorDetailsInitial());

  final IDoctorsRemoteDataSource _doctorsDataSource;

  // Cache doctor data to avoid refetching when only changing date
  DoctorModel? _cachedDoctor;
  int? _currentDoctorId;

  /// Fetch doctor details and available slots for a specific date
  ///
  /// This method fetches both doctor information and available time slots
  /// in parallel for better performance.
  Future<void> fetchDoctorDetailsAndSlots(int doctorId, String date) async {
    // If we're fetching for the same doctor and have cached data,
    // only fetch new slots
    if (_currentDoctorId == doctorId && _cachedDoctor != null) {
      await _fetchSlotsOnly(doctorId, date);
      return;
    }

    emit(const DoctorDetailsLoading());
    _currentDoctorId = doctorId;

    try {
      // Fetch both in parallel
      final results = await Future.wait([
        _doctorsDataSource.getDoctorDetails(doctorId),
        _doctorsDataSource.getAvailableSlots(doctorId, date),
      ]);

      final doctor = results[0] as DoctorModel;
      final slots = results[1] as AvailableSlotsModel;

      _cachedDoctor = doctor;

      emit(
        DoctorDetailsLoaded(
          doctor: doctor,
          availableSlots: slots,
          selectedDate: date,
        ),
      );
    } on DoctorsException catch (e) {
      emit(DoctorDetailsError(message: e.message));
    } catch (e) {
      emit(
        DoctorDetailsError(
          message: 'Failed to load doctor details: ${e.toString()}',
        ),
      );
    }
  }

  /// Fetch only doctor details (without slots)
  Future<void> fetchDoctorDetails(int doctorId) async {
    emit(const DoctorDetailsLoading());
    _currentDoctorId = doctorId;

    try {
      final doctor = await _doctorsDataSource.getDoctorDetails(doctorId);
      _cachedDoctor = doctor;

      emit(DoctorDetailsLoaded(doctor: doctor));
    } on DoctorsException catch (e) {
      emit(DoctorDetailsError(message: e.message));
    } catch (e) {
      emit(
        DoctorDetailsError(
          message: 'Failed to load doctor details: ${e.toString()}',
        ),
      );
    }
  }

  /// Fetch available slots for a new date (when doctor is already loaded)
  Future<void> fetchSlotsForDate(int doctorId, String date) async {
    final currentState = state;

    if (currentState is DoctorDetailsLoaded) {
      emit(SlotsLoading(doctor: currentState.doctor, selectedDate: date));
    } else if (_cachedDoctor != null) {
      emit(SlotsLoading(doctor: _cachedDoctor!, selectedDate: date));
    }

    await _fetchSlotsOnly(doctorId, date);
  }

  /// Internal method to fetch only slots
  Future<void> _fetchSlotsOnly(int doctorId, String date) async {
    final doctor = _cachedDoctor;
    if (doctor == null) {
      // No cached doctor, do full fetch
      await fetchDoctorDetailsAndSlots(doctorId, date);
      return;
    }

    // Show loading state while keeping doctor data visible
    emit(SlotsLoading(doctor: doctor, selectedDate: date));

    try {
      final slots = await _doctorsDataSource.getAvailableSlots(doctorId, date);

      emit(
        DoctorDetailsLoaded(
          doctor: doctor,
          availableSlots: slots,
          selectedDate: date,
        ),
      );
    } on DoctorsException {
      // On error, keep doctor data but show empty slots
      emit(
        DoctorDetailsLoaded(
          doctor: doctor,
          availableSlots: const AvailableSlotsModel(schedules: [], slots: []),
          selectedDate: date,
        ),
      );
      // Optionally, you could emit an error state here
    } catch (_) {
      emit(
        DoctorDetailsLoaded(
          doctor: doctor,
          availableSlots: const AvailableSlotsModel(schedules: [], slots: []),
          selectedDate: date,
        ),
      );
    }
  }

  /// Select a time slot
  void selectSlot(String slot) {
    final currentState = state;
    if (currentState is DoctorDetailsLoaded) {
      emit(currentState.copyWith(selectedSlot: slot));
    }
  }

  /// Clear selected slot
  void clearSelectedSlot() {
    final currentState = state;
    if (currentState is DoctorDetailsLoaded) {
      emit(
        DoctorDetailsLoaded(
          doctor: currentState.doctor,
          availableSlots: currentState.availableSlots,
          selectedDate: currentState.selectedDate,
          selectedSlot: null,
        ),
      );
    }
  }

  /// Reset state and clear cache
  void reset() {
    _cachedDoctor = null;
    _currentDoctorId = null;
    emit(const DoctorDetailsInitial());
  }

  /// Get current doctor if loaded
  DoctorModel? get currentDoctor {
    final currentState = state;
    if (currentState is DoctorDetailsLoaded) {
      return currentState.doctor;
    } else if (currentState is SlotsLoading) {
      return currentState.doctor;
    }
    return _cachedDoctor;
  }
}
