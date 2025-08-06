import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../features/reservation/models/reservation.dart';

class ReservationMiddleware {
  List<List<Reservation>> _reservations = [];
  bool _isInitialized = false;

  // Stream controllers for reservation events
  final _reservationStreamController =
      StreamController<List<List<Reservation>>>.broadcast();
  final _reservationErrorController = StreamController<String>.broadcast();

  // Streams that components can listen to
  Stream<List<List<Reservation>>> get reservationsStream =>
      _reservationStreamController.stream;
  Stream<String> get errorStream => _reservationErrorController.stream;

  // Singleton instance
  static final ReservationMiddleware _instance =
      ReservationMiddleware._internal();

  // Factory constructor
  factory ReservationMiddleware() {
    return _instance;
  }

  // Private constructor
  ReservationMiddleware._internal();

  // Initialize the middleware
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        await _loadReservationsFromJson();
      }
      refreshReservations();
    } catch (e) {
      _reservationErrorController.add(
        'Failed to initialize reservation data: $e',
      );
    }
  }

  // Initialize reservation middleware
  Future<void> initializeReservationMiddleware() async {
    final reservationMiddleware = ReservationMiddleware();
    await reservationMiddleware.initialize();
  }

  // Load reservations from JSON
  Future<void> _loadReservationsFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/reservations.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      List<List<Reservation>> result = [];
      for (var group in jsonData) {
        List<Reservation> groupReservations = [];
        for (var item in group) {
          groupReservations.add(Reservation.fromJson(item));
        }
        result.add(groupReservations);
      }

      setReservations(result);
    } catch (e) {
      _reservationErrorController.add(
        'Failed to load reservations from JSON: $e',
      );
    }
  }

  // Set reservations data
  void setReservations(List<List<Reservation>> reservations) {
    _reservations = reservations;
    _isInitialized = true;
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;

  // Get all reservations
  List<List<Reservation>> getAllReservations() {
    if (!_isInitialized) {
      throw Exception('Reservation middleware not initialized');
    }
    return _reservations;
  }

  // Refresh reservations and notify listeners
  void refreshReservations() {
    if (_isInitialized) {
      _reservationStreamController.add(_reservations);
    }
  }

  // Add a new reservation group
  void addReservationGroup(List<Reservation> group) {
    if (!_isInitialized) {
      throw Exception('Reservation middleware not initialized');
    }
    _reservations.add(group);
    refreshReservations();
  }

  // Add a reservation to a specific group
  void addReservationToGroup(int groupIndex, Reservation reservation) {
    if (!_isInitialized) {
      throw Exception('Reservation middleware not initialized');
    }
    if (groupIndex < 0 || groupIndex >= _reservations.length) {
      throw Exception('Invalid group index: $groupIndex');
    }
    _reservations[groupIndex].add(reservation);
    refreshReservations();
  }

  // Update a reservation
  void updateReservation(
    int groupIndex,
    int reservationIndex,
    Reservation updatedReservation,
  ) {
    if (!_isInitialized) {
      throw Exception('Reservation middleware not initialized');
    }
    if (groupIndex < 0 || groupIndex >= _reservations.length) {
      throw Exception('Invalid group index: $groupIndex');
    }
    if (reservationIndex < 0 ||
        reservationIndex >= _reservations[groupIndex].length) {
      throw Exception('Invalid reservation index: $reservationIndex');
    }
    _reservations[groupIndex][reservationIndex] = updatedReservation;
    refreshReservations();
  }

  // Delete a reservation
  void deleteReservation(int groupIndex, int reservationIndex) {
    if (!_isInitialized) {
      throw Exception('Reservation middleware not initialized');
    }
    if (groupIndex < 0 || groupIndex >= _reservations.length) {
      throw Exception('Invalid group index: $groupIndex');
    }
    if (reservationIndex < 0 ||
        reservationIndex >= _reservations[groupIndex].length) {
      throw Exception('Invalid reservation index: $reservationIndex');
    }
    _reservations[groupIndex].removeAt(reservationIndex);

    // Remove group if empty
    if (_reservations[groupIndex].isEmpty) {
      _reservations.removeAt(groupIndex);
    }

    refreshReservations();
  }

  // Close streams when no longer needed
  void dispose() {
    _reservationStreamController.close();
    _reservationErrorController.close();
  }
}
