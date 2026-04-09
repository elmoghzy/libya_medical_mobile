import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/doctors_remote_data_source.dart';
import '../data/models/doctor_model.dart';
import 'doctors_state.dart';

/// Cubit for managing doctors list state
class DoctorsCubit extends Cubit<DoctorsState> {
  DoctorsCubit({required IDoctorsRemoteDataSource doctorsDataSource})
    : _doctorsDataSource = doctorsDataSource,
      super(const DoctorsInitial());

  final IDoctorsRemoteDataSource _doctorsDataSource;

  /// Fetch all doctors from API
  Future<void> fetchDoctors() async {
    emit(const DoctorsLoading());

    try {
      final doctors = await _doctorsDataSource.getDoctors();
      emit(DoctorsLoaded(doctors: doctors));
    } on DoctorsException catch (e) {
      emit(DoctorsError(message: e.message, code: e.code));
    } catch (e) {
      emit(DoctorsError(message: 'Failed to load doctors: ${e.toString()}'));
    }
  }

  /// Refresh doctors list
  Future<void> refreshDoctors() async {
    // Keep current data while refreshing
    final currentState = state;

    try {
      final doctors = await _doctorsDataSource.getDoctors();

      if (currentState is DoctorsLoaded) {
        // Preserve filters if any
        emit(
          DoctorsLoaded(
            doctors: doctors,
            searchQuery: currentState.searchQuery,
            selectedSpecialty: currentState.selectedSpecialty,
          ),
        );
        // Re-apply filters
        if (currentState.searchQuery.isNotEmpty ||
            currentState.selectedSpecialty != null) {
          _applyFilters(
            doctors,
            currentState.searchQuery,
            currentState.selectedSpecialty,
          );
        }
      } else {
        emit(DoctorsLoaded(doctors: doctors));
      }
    } on DoctorsException catch (e) {
      // On refresh error, keep current data if available
      if (currentState is! DoctorsLoaded) {
        emit(DoctorsError(message: e.message, code: e.code));
      }
    } catch (e) {
      if (currentState is! DoctorsLoaded) {
        emit(
          DoctorsError(message: 'Failed to refresh doctors: ${e.toString()}'),
        );
      }
    }
  }

  /// Search doctors by name or specialty
  void searchDoctors(String query) {
    final currentState = state;
    if (currentState is DoctorsLoaded) {
      _applyFilters(
        currentState.doctors,
        query,
        currentState.selectedSpecialty,
      );
    }
  }

  /// Filter doctors by specialty
  void filterBySpecialty(String? specialty) {
    final currentState = state;
    if (currentState is DoctorsLoaded) {
      _applyFilters(currentState.doctors, currentState.searchQuery, specialty);
    }
  }

  /// Clear all filters
  void clearFilters() {
    final currentState = state;
    if (currentState is DoctorsLoaded) {
      emit(currentState.copyWith(clearFilters: true));
    }
  }

  /// Apply search and specialty filters
  void _applyFilters(
    List<DoctorModel> doctors,
    String searchQuery,
    String? specialty,
  ) {
    List<DoctorModel> filtered = doctors;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((doctor) {
        return doctor.name.toLowerCase().contains(query) ||
            doctor.specialty.toLowerCase().contains(query);
      }).toList();
    }

    // Apply specialty filter
    if (specialty != null && specialty.isNotEmpty) {
      filtered = filtered.where((doctor) {
        return doctor.specialty == specialty;
      }).toList();
    }

    emit(
      DoctorsLoaded(
        doctors: doctors,
        filteredDoctors: filtered,
        searchQuery: searchQuery,
        selectedSpecialty: specialty,
      ),
    );
  }
}
