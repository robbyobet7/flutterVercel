import 'package:flutter/material.dart';

class CheckoutDiscount {
  final String name;
  final VoidCallback onTap;

  CheckoutDiscount({required this.name, required this.onTap});
}

class DiscountModel {
  final int id;
  final String name;
  final String type;
  final double amount;
  final int? todayRemaining;
  final double minimum;
  final double cappedTo;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.todayRemaining,
    required this.minimum,
    required this.cappedTo,
    required this.isActive,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    String discountType =
        json['discount_type'] == 'bill' ? 'percentage' : 'fixed';

    return DiscountModel(
      id: json['id'] as int,
      name: json['discount_name'] as String,
      type: discountType,
      amount: (json['amount'] as num).toDouble(),
      // Ambil nilai dari discount_daily_limit, kalau null pakai count
      todayRemaining: (json['discount_daily_limit'] ?? json['count']) as int?,
      minimum: (json['discount_rules'] as num).toDouble(),
      cappedTo: (json['discount_capped'] as num).toDouble(),
      isActive: json['status'] == 1,
    );
  }
}
