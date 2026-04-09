import 'package:equatable/equatable.dart';

import '../data/models/booking_model.dart';

/// Base state for all booking-related states
sealed class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no operations have been performed
final class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

/// Loading state when creating or fetching bookings
final class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

/// State when a booking has been successfully created
final class BookingCreated extends BookingsState {
  const BookingCreated({required this.booking});

  final BookingModel booking;

  @override
  List<Object?> get props => [booking];
}

/// State when bookings list has been successfully loaded
final class BookingsLoaded extends BookingsState {
  const BookingsLoaded({required this.bookings, this.isRefreshing = false});

  final List<BookingModel> bookings;
  final bool isRefreshing;

  BookingsLoaded copyWith({List<BookingModel>? bookings, bool? isRefreshing}) {
    return BookingsLoaded(
      bookings: bookings ?? this.bookings,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [bookings, isRefreshing];
}

/// State when a booking has been successfully cancelled
final class BookingCancelled extends BookingsState {
  const BookingCancelled({required this.booking});

  final BookingModel booking;

  @override
  List<Object?> get props => [booking];
}

/// State when check-in has been successful
final class BookingCheckedIn extends BookingsState {
  const BookingCheckedIn({required this.booking});

  final BookingModel booking;

  @override
  List<Object?> get props => [booking];
}

/// Error state when an operation fails
final class BookingsError extends BookingsState {
  const BookingsError({required this.message, this.code});

  final String message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}
