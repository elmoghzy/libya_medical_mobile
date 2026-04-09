import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/bookings_remote_data_source.dart';
import '../data/models/booking_model.dart';
import 'bookings_state.dart';

/// Cubit for managing bookings state and operations
class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit({required IBookingsRemoteDataSource bookingsDataSource})
    : _bookingsDataSource = bookingsDataSource,
      super(const BookingsInitial());

  final IBookingsRemoteDataSource _bookingsDataSource;

  /// Create a doctor booking
  Future<void> createDoctorBooking({
    required int doctorId,
    required String date,
    required String time,
  }) async {
    emit(const BookingsLoading());

    try {
      final bookingData = {
        'bookable_type': 'doctor',
        'bookable_id': doctorId,
        'booking_date': date,
        'booking_time': time,
      };

      final booking = await _bookingsDataSource.createBooking(bookingData);

      emit(BookingCreated(booking: booking));
    } on BookingsException catch (e) {
      emit(BookingsError(message: e.message, code: e.code));
    } catch (e) {
      emit(BookingsError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  /// Create a room booking
  Future<void> createRoomBooking({
    required int roomId,
    required String startDate,
    required String endDate,
    required String time,
  }) async {
    emit(const BookingsLoading());

    try {
      final bookingData = {
        'bookable_type': 'room',
        'bookable_id': roomId,
        'booking_date': startDate,
        'end_date': endDate,
        'booking_time': time,
      };

      final booking = await _bookingsDataSource.createBooking(bookingData);

      emit(BookingCreated(booking: booking));
    } on BookingsException catch (e) {
      emit(BookingsError(message: e.message, code: e.code));
    } catch (e) {
      emit(BookingsError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  /// Fetch all bookings for the current user
  Future<void> fetchMyBookings() async {
    emit(const BookingsLoading());

    try {
      final bookings = await _bookingsDataSource.getMyBookings();

      emit(BookingsLoaded(bookings: bookings));
    } on BookingsException catch (e) {
      emit(BookingsError(message: e.message, code: e.code));
    } catch (e) {
      emit(BookingsError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  /// Refresh bookings list (keep current data visible while refreshing)
  Future<void> refreshBookings() async {
    final currentState = state;

    // If currently showing bookings, mark as refreshing
    if (currentState is BookingsLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      final bookings = await _bookingsDataSource.getMyBookings();

      emit(BookingsLoaded(bookings: bookings, isRefreshing: false));
    } on BookingsException catch (e) {
      // On refresh error, keep current data if available
      if (currentState is BookingsLoaded) {
        emit(currentState.copyWith(isRefreshing: false));
      } else {
        emit(BookingsError(message: e.message, code: e.code));
      }
    } catch (e) {
      if (currentState is BookingsLoaded) {
        emit(currentState.copyWith(isRefreshing: false));
      } else {
        emit(BookingsError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
      }
    }
  }

  /// Cancel a booking
  Future<void> cancelBooking(int bookingId) async {
    // Don't show loading if we're in BookingsLoaded state
    // This preserves the list while cancelling
    final currentState = state;
    if (currentState is! BookingsLoaded) {
      emit(const BookingsLoading());
    }

    try {
      final cancelledBooking = await _bookingsDataSource.cancelBooking(
        bookingId,
      );

      emit(BookingCancelled(booking: cancelledBooking));

      // Auto-refresh bookings list after cancellation
      await fetchMyBookings();
    } on BookingsException catch (e) {
      emit(BookingsError(message: e.message, code: e.code));
    } catch (e) {
      emit(BookingsError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  /// Check in to a booking
  Future<void> checkInBooking(int bookingId) async {
    final currentState = state;
    if (currentState is! BookingsLoaded) {
      emit(const BookingsLoading());
    }

    try {
      final checkedInBooking = await _bookingsDataSource.checkInBooking(
        bookingId,
      );

      emit(BookingCheckedIn(booking: checkedInBooking));

      // Auto-refresh bookings list after check-in
      await fetchMyBookings();
    } on BookingsException catch (e) {
      emit(BookingsError(message: e.message, code: e.code));
    } catch (e) {
      emit(BookingsError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const BookingsInitial());
  }

  /// Filter bookings by status
  void filterByStatus(String status) {
    final currentState = state;
    if (currentState is BookingsLoaded) {
      final filteredBookings = currentState.bookings
          .where((booking) => booking.status == status)
          .toList();

      emit(BookingsLoaded(bookings: filteredBookings));
    }
  }

  /// Get upcoming bookings (confirmed or checked_in)
  List<BookingModel> getUpcomingBookings() {
    final currentState = state;
    if (currentState is BookingsLoaded) {
      return currentState.bookings
          .where(
            (booking) =>
                booking.status == 'confirmed' ||
                booking.status == 'checked_in' ||
                booking.status == 'in_progress',
          )
          .toList();
    }
    return [];
  }

  /// Get past bookings (completed or cancelled)
  List<BookingModel> getPastBookings() {
    final currentState = state;
    if (currentState is BookingsLoaded) {
      return currentState.bookings
          .where(
            (booking) =>
                booking.status == 'completed' || booking.status == 'cancelled',
          )
          .toList();
    }
    return [];
  }
}
