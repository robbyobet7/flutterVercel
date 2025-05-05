import 'dart:convert';

class CustomerModel {
  final int? customerId;
  final String? customerIdNumber;
  final String customerName;
  final String? emailSocial;
  final String? phone;
  final int? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int point;
  final String? address;
  final String? city;
  final String? postCode;
  final String? affiliate;
  final int? key;

  CustomerModel({
    this.customerId,
    this.customerIdNumber,
    required this.customerName,
    this.emailSocial,
    this.phone,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.point = 0,
    this.address,
    this.city,
    this.postCode,
    this.affiliate,
    this.key,
  });

  // Create a copy of the current customer with changes
  CustomerModel copyWith({
    int? customerId,
    String? customerIdNumber,
    String? customerName,
    String? emailSocial,
    String? phone,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? point,
    String? address,
    String? city,
    String? postCode,
    String? affiliate,
    int? key,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      customerIdNumber: customerIdNumber ?? this.customerIdNumber,
      customerName: customerName ?? this.customerName,
      emailSocial: emailSocial ?? this.emailSocial,
      phone: phone ?? this.phone,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      point: point ?? this.point,
      address: address ?? this.address,
      city: city ?? this.city,
      postCode: postCode ?? this.postCode,
      affiliate: affiliate ?? this.affiliate,
      key: key ?? this.key,
    );
  }

  // Convert JSON Map to Customer object
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['customer_id'],
      customerIdNumber: json['customer_id_number'],
      customerName: json['customer_name'] ?? '',
      emailSocial: json['email_social'],
      phone: json['phone'],
      ownerId: json['owner_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      point: json['point'] ?? 0,
      address: json['address'],
      city: json['city'],
      postCode: json['post_code'],
      affiliate: json['affiliate'],
      key: json['key'],
    );
  }

  // Convert Customer object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_id_number': customerIdNumber,
      'customer_name': customerName,
      'email_social': emailSocial,
      'phone': phone,
      'owner_id': ownerId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'point': point,
      'address': address,
      'city': city,
      'post_code': postCode,
      'affiliate': affiliate,
      'key': key,
    };
  }

  // Parse a list of customers from JSON string
  static List<CustomerModel> parseCustomers(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => CustomerModel.fromJson(json)).toList();
  }

  // Get customer full name with fallback
  String get fullName =>
      customerName.isNotEmpty ? customerName : 'Unknown Customer';

  // Check if customer has any contact information
  bool get hasContactInfo => emailSocial != null || phone != null;

  // Format the creation date
  String get formattedCreatedAt =>
      createdAt != null
          ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}'
          : 'N/A';

  // Get formatted address
  String get formattedAddress {
    final parts = [
      if (address != null && address!.isNotEmpty) address,
      if (city != null && city!.isNotEmpty) city,
      if (postCode != null && postCode!.isNotEmpty) postCode,
    ];
    return parts.isNotEmpty ? parts.join(', ') : 'No address provided';
  }

  @override
  String toString() {
    return 'Customer(id: $customerId, name: $customerName, email: $emailSocial, phone: $phone, points: $point)';
  }
}
