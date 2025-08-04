import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/middleware/reservation_middleware.dart';
import '../models/reservation.dart';

// State class for the reservation
class ReservationState {
  final List<List<Reservation>> reservations;
  final bool isLoading;
  final String? error;

  const ReservationState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
  });

  ReservationState copyWith({
    List<List<Reservation>>? reservations,
    bool? isLoading,
    String? error,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Repository provider
final ReservationMiddlewareProvider = Provider<ReservationMiddleware>((ref) {
  return ReservationMiddleware();
});

// Reservation state notifier
class ReservationNotifier extends StateNotifier<ReservationState> {
  final ReservationMiddleware reservationMiddleware;

  ReservationNotifier(this.reservationMiddleware)
    : super(const ReservationState());

  Future<void> fetchReservations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reservations = await reservationMiddleware.getAllReservations();
      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// Provider for the reservation state
final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
      final repository = ref.watch(ReservationMiddlewareProvider);
      return ReservationNotifier(repository);
    });
