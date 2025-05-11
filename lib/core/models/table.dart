import 'dart:convert';

class TableModel {
  final int id;
  final String tableName;
  final int status;
  final int outletId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int minimumCharge;
  final int key;
  final int countBillOpen;
  final List<dynamic> reservations;
  final int reservationCount;
  final String reservationStatus;
  final int totalBillOpen;

  TableModel({
    required this.id,
    required this.tableName,
    required this.status,
    required this.outletId,
    required this.createdAt,
    required this.updatedAt,
    required this.minimumCharge,
    required this.key,
    required this.countBillOpen,
    required this.reservations,
    required this.reservationCount,
    required this.reservationStatus,
    required this.totalBillOpen,
  });

  // Create a copy of the current table with changes
  TableModel copyWith({
    int? id,
    String? tableName,
    int? status,
    int? outletId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? minimumCharge,
    int? key,
    int? countBillOpen,
    List<dynamic>? reservations,
    int? reservationCount,
    String? reservationStatus,
    int? totalBillOpen,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      status: status ?? this.status,
      outletId: outletId ?? this.outletId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      minimumCharge: minimumCharge ?? this.minimumCharge,
      key: key ?? this.key,
      countBillOpen: countBillOpen ?? this.countBillOpen,
      reservations: reservations ?? this.reservations,
      reservationCount: reservationCount ?? this.reservationCount,
      reservationStatus: reservationStatus ?? this.reservationStatus,
      totalBillOpen: totalBillOpen ?? this.totalBillOpen,
    );
  }

  // Convert JSON Map to TableModel object
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      tableName: json['table_name'],
      status: json['status'],
      outletId: json['outlet_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      minimumCharge: json['minimum_charge'],
      key: json['key'],
      countBillOpen: json['countBillOpen'],
      reservations: json['reservations'] ?? [],
      reservationCount: json['reservation_count'],
      reservationStatus: json['reservation_status'],
      totalBillOpen: json['totalBillOpen'],
    );
  }

  // Convert TableModel object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_name': tableName,
      'status': status,
      'outlet_id': outletId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'minimum_charge': minimumCharge,
      'key': key,
      'countBillOpen': countBillOpen,
      'reservations': reservations,
      'reservation_count': reservationCount,
      'reservation_status': reservationStatus,
      'totalBillOpen': totalBillOpen,
    };
  }

  // Parse a list of tables from JSON string
  static List<TableModel> parseTables(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => TableModel.fromJson(json)).toList();
  }

  // Get table status as string
  String get statusText => status == 1 ? 'Active' : 'Inactive';

  // Get formatted minimum charge
  String get formattedMinimumCharge =>
      minimumCharge > 0
          ? 'Rp ${minimumCharge.toString()}'
          : 'No minimum charge';

  // Check if table has open bills
  bool get hasOpenBills => countBillOpen > 0;

  // Format the creation date
  String get formattedCreatedAt =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  @override
  String toString() {
    return 'Table(id: $id, name: $tableName, status: $status, billsOpen: $countBillOpen)';
  }
}
