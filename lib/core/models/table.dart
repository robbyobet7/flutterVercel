import 'dart:convert';

class BillInTable {
  final int billId;
  final int total;
  final String state;
  final String? cashier;

  BillInTable({
    required this.billId,
    required this.total,
    required this.state,
    this.cashier,
  });

  factory BillInTable.fromJson(Map<String, dynamic> json) {
    return BillInTable(
      billId: json['bill_id'],
      total: json['total'] ?? 0,
      state: json['state'] ?? 'unknown',
      cashier: json['cashier'],
    );
  }
}

class TableModel {
  final int id;
  final String tableName;
  final String status;
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
  final List<BillInTable> bills;

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
    required this.bills,
  });

  // Create a copy of the current table with changes
  TableModel copyWith({
    int? id,
    String? tableName,
    String? status,
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
    List<BillInTable>? bills,
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
      bills: bills ?? this.bills,
    );
  }

  // Convert JSON Map to TableModel object
  factory TableModel.fromJson(Map<String, dynamic> json) {
    var billListFromJson = json['bills'] as List? ?? [];
    List<BillInTable> billList =
        billListFromJson.map((b) => BillInTable.fromJson(b)).toList();
    int calculatedTotalBillOpen = 0;
    for (var bill in billList) {
      if (bill.state == 'open') {
        calculatedTotalBillOpen += bill.total;
      }
    }
    return TableModel(
      id: json['id'],
      tableName: json['table_name'],
      status: json['status'] ?? 'available',
      countBillOpen: json['open_bill_count'] ?? 0,
      outletId: json['outlet_id'] ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      minimumCharge: json['minimum_charge'] ?? 0,
      key: json['key'],
      reservations: json['reservations'] ?? [],
      reservationCount: json['reservation_count'] ?? 0,
      reservationStatus: json['reservation_status'] ?? '',
      bills: billList,
      totalBillOpen: calculatedTotalBillOpen,
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
  String get statusText => status == 'bill_open' ? 'Active' : 'Available';

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
