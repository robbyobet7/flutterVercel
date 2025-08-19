class SimpleBillModel {
  final int billId;
  final num total;
  final num finalTotal;
  final String state;
  final String? cashier;

  SimpleBillModel({
    required this.billId,
    required this.total,
    required this.finalTotal,
    required this.state,
    this.cashier,
  });

  factory SimpleBillModel.fromJson(Map<String, dynamic> json) {
    return SimpleBillModel(
      billId: json['bill_id'],
      total: json['total'] ?? 0,
      finalTotal: json['final_total'] ?? 0,
      state: json['state'] ?? 'unknown',
      cashier: json['cashier'],
    );
  }
}
