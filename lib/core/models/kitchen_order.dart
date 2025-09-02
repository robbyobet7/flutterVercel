import 'dart:convert';

import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/models/cart_item.dart';

class ListOrder {
  final String name;
  final int quantity;
  final String tableName;
  final List<CartItemOption>? options;
  final String? productNotes;
  final dynamic billPrinter;

  ListOrder({
    required this.name,
    required this.quantity,
    required this.tableName,
    this.options,
    this.productNotes,
    required this.billPrinter,
  });

  factory ListOrder.fromJson(Map<String, dynamic> json) {
    List<CartItemOption>? optionsList;
    if (json['options'] != null) {
      optionsList =
          (json['options'] as List)
              .map((option) => CartItemOption.fromJson(option))
              .toList();
    }

    // Handle both int and List types for bill_printer
    dynamic billPrinter = json['bill_printer'];

    return ListOrder(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      tableName: json['table_name'] ?? '-',
      options: optionsList,
      productNotes: json['productNotes'],
      billPrinter: billPrinter ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'table_name': tableName,
      'options': options?.map((option) => option.toJson()).toList(),
      'productNotes': productNotes,
      'bill_printer': billPrinter,
    };
  }
}

class KitchenOrder {
  final int ordersId;
  final int billId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<ListOrder> listorders;
  final String states;
  final int outletId;
  final String? notes;
  final String staff;
  final String date;
  final String update;
  final DateTime reldate;
  final DateTime upreldate;
  final String customer;
  final String table;
  final String cBillId;
  final BillModel? bill;

  KitchenOrder({
    required this.ordersId,
    required this.billId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.listorders,
    required this.states,
    required this.outletId,
    this.notes,
    required this.staff,
    required this.date,
    required this.update,
    required this.reldate,
    required this.upreldate,
    required this.customer,
    required this.table,
    required this.cBillId,
    this.bill,
  });

  KitchenOrder copyWith({
    int? ordersId,
    int? billId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<ListOrder>? listorders,
    String? states,
    int? outletId,
    String? notes,
    String? staff,
    String? date,
    String? update,
    DateTime? reldate,
    DateTime? upreldate,
    String? customer,
    String? table,
    String? cBillId,
    BillModel? bill,
  }) {
    return KitchenOrder(
      ordersId: ordersId ?? this.ordersId,
      billId: billId ?? this.billId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      listorders: listorders ?? this.listorders,
      states: states ?? this.states,
      outletId: outletId ?? this.outletId,
      notes: notes ?? this.notes,
      staff: staff ?? this.staff,
      date: date ?? this.date,
      update: update ?? this.update,
      reldate: reldate ?? this.reldate,
      upreldate: upreldate ?? this.upreldate,
      customer: customer ?? this.customer,
      table: table ?? this.table,
      cBillId: cBillId ?? this.cBillId,
      bill: bill ?? this.bill,
    );
  }

  factory KitchenOrder.fromJson(Map<String, dynamic> json) {
    // Parse list orders
    List<ListOrder> parsedListOrders = [];
    if (json['listorders'] != null) {
      parsedListOrders =
          (json['listorders'] as List)
              .map((item) => ListOrder.fromJson(item))
              .toList();
    }

    // Parse bill if available
    BillModel? billModel;
    if (json['bill'] != null) {
      billModel = BillModel.fromJson(json['bill']);
    }

    return KitchenOrder(
      ordersId: json['orders_id'] ?? 0,
      billId: json['bill_id'] ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
      listorders: parsedListOrders,
      states: json['states'] ?? 'pending',
      outletId: json['outlet_id'] ?? 0,
      notes: json['notes'],
      staff: json['staff'] ?? 'Unknown',
      date: json['date'] ?? '',
      update: json['update'] ?? '',
      reldate:
          json['reldate'] != null
              ? DateTime.parse(json['reldate'])
              : DateTime.now(),
      upreldate:
          json['upreldate'] != null
              ? DateTime.parse(json['upreldate'])
              : DateTime.now(),
      customer: json['customer'] ?? 'Guest',
      table: json['table'] ?? 'No Table',
      cBillId: json['c_bill_id'] ?? '',
      bill: billModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders_id': ordersId,
      'bill_id': billId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'listorders': listorders.map((order) => order.toJson()).toList(),
      'states': states,
      'outlet_id': outletId,
      'notes': notes,
      'staff': staff,
      'date': date,
      'update': update,
      'reldate': reldate.toIso8601String(),
      'upreldate': upreldate.toIso8601String(),
      'customer': customer,
      'table': table,
      'c_bill_id': cBillId,
      'bill': bill?.toJson(),
    };
  }

  // Static method to parse kitchen orders from JSON string
  static List<KitchenOrder> parseKitchenOrders(String jsonString) {
    try {
      final dynamic parsed = jsonDecode(jsonString);

      // Handle the case where the JSON is wrapped in an extra array
      final List<dynamic> ordersData;
      if (parsed is List && parsed.isNotEmpty && parsed[0] is List) {
        // The data is in format [[{order1}, {order2}]] - take the first inner array
        ordersData = parsed[0];
      } else {
        // The data is in format [{order1}, {order2}]
        ordersData = parsed;
      }

      final List<KitchenOrder> orders = [];
      for (var json in ordersData) {
        try {
          orders.add(KitchenOrder.fromJson(json));
        } catch (e) {
          // Continue with next order instead of rethrowing
        }
      }
      return orders;
    } catch (e) {
      return [];
    }
  }

  // Helper methods
  bool get isSubmitted => states == 'submitted';
  bool get isCompleted => states == 'completed';
  bool get isCancelled => states == 'cancelled';

  // Get formatted status
  String get formattedStatus {
    switch (states) {
      case 'submitted':
        return 'Submitted';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
