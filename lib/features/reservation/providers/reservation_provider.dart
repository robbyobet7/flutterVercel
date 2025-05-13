import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/reservation_repository.dart';
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
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository();
});

// Reservation state notifier
class ReservationNotifier extends StateNotifier<ReservationState> {
  final ReservationRepository _repository;

  ReservationNotifier(this._repository) : super(const ReservationState());

  Future<void> fetchReservations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reservations = await _repository.getReservations();
      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// Provider for the reservation state
final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
      final repository = ref.watch(reservationRepositoryProvider);
      return ReservationNotifier(repository);
    });
