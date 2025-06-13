import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/reservation/models/reservation.dart';

class ReservationRepository {
  Future<List<List<Reservation>>> getReservations() async {
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

      return result;
    } catch (e) {
      return [];
    }
  }
}
