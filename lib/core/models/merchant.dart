import 'dart:convert';

class Merchant {
  final int id;
  final int ownerId;
  final String channelName;
  final int tax;
  final DateTime createdAt;
  final DateTime updatedAt;

  Merchant({
    required this.id,
    required this.ownerId,
    required this.channelName,
    required this.tax,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'],
      ownerId: json['owner_id'],
      channelName: json['channel_name'],
      tax: json['tax'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static List<Merchant> parseMerchants(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Merchant>((json) => Merchant.fromJson(json)).toList();
  }
}
