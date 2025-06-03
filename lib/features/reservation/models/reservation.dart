class Reservation {
  final int id;
  final String name;
  final String dateTime;
  final int duration;
  final int headcount;
  final int outletId;
  final int customerId;
  final int tableId;
  final String remarks;
  final String createdAt;
  final String updatedAt;
  final String time;
  final String tableName;
  final String? stamp;

  Reservation({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.duration,
    required this.headcount,
    required this.outletId,
    required this.customerId,
    required this.tableId,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.time,
    required this.tableName,
    this.stamp,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      name: json['name'],
      dateTime: json['date_time'],
      duration: json['duration'],
      headcount: json['headcount'],
      outletId: json['outlet_id'],
      customerId: json['customer_id'],
      tableId: json['table_id'],
      remarks: json['remarks'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      time: json['time'],
      tableName: json['table_name'],
      stamp: json['stamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_time': dateTime,
      'duration': duration,
      'headcount': headcount,
      'outlet_id': outletId,
      'customer_id': customerId,
      'table_id': tableId,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'time': time,
      'table_name': tableName,
      'stamp': stamp,
    };
  }
}
