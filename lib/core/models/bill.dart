import 'dart:convert';
import 'package:rebill_flutter/core/models/cart_item.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:flutter/services.dart';

class RefundItem {
  final int id;
  final int refundId;
  final int productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  RefundItem({
    required this.id,
    required this.refundId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
      id: json['id'],
      refundId: json['refund_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refund_id': refundId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Refund {
  final int id;
  final String billId;
  final String reason;
  final int isReturnStock;
  final String totalValue;
  final double totalGratuity;
  final double totalFee;
  final double totalTax;
  final double fullTotalValue;
  final int ownerId;
  final int outletId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RefundItem> refundItems;

  Refund({
    required this.id,
    required this.billId,
    required this.reason,
    required this.isReturnStock,
    required this.totalValue,
    required this.totalGratuity,
    required this.totalFee,
    required this.totalTax,
    required this.fullTotalValue,
    required this.ownerId,
    required this.outletId,
    required this.createdAt,
    required this.updatedAt,
    required this.refundItems,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    var refundItemsList = <RefundItem>[];
    if (json['refund_items'] != null) {
      refundItemsList = List<RefundItem>.from(
        json['refund_items'].map((x) => RefundItem.fromJson(x)),
      );
    }

    return Refund(
      id: json['id'],
      billId: json['bill_id'],
      reason: json['reason'] ?? '',
      isReturnStock: json['is_return_stock'],
      totalValue: json['total_value'],
      totalGratuity: double.parse(json['total_gratuity'].toString()),
      totalFee: double.parse(json['total_fee'].toString()),
      totalTax: double.parse(json['total_tax'].toString()),
      fullTotalValue: double.parse(json['full_total_value'].toString()),
      ownerId: json['owner_id'],
      outletId: json['outlet_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      refundItems: refundItemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_id': billId,
      'reason': reason,
      'is_return_stock': isReturnStock,
      'total_value': totalValue,
      'total_gratuity': totalGratuity,
      'total_fee': totalFee,
      'total_tax': totalTax,
      'full_total_value': fullTotalValue,
      'owner_id': ownerId,
      'outlet_id': outletId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'refund_items': refundItems.map((x) => x.toJson()).toList(),
    };
  }
}

class BillModel {
  final int billId;
  final String customerName;
  final String orderCollection;
  final double total;
  final double finalTotal;
  final double downPayment;
  final int usersId;
  final String states;
  final String? paymentMethod;
  final dynamic splitPayment;
  final String delivery;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int outletId;
  final String servicefee;
  final String gratuity;
  final String vat;
  final int? customerId;
  final String billDiscount;
  final dynamic tableId;
  final int totalDiscount;
  final String hashBill;
  final String rewardPoints;
  final int totalReward;
  final String rewardBill;
  final String cBillId;
  final int rounding;
  final int isQR;
  final String? notes;
  final double amountPaid;
  final String? ccNumber;
  final String? ccType;
  final int productDiscount;
  final dynamic merchantOrderId;
  final dynamic discountList;
  final int key;
  final dynamic affiliate;
  final String? customerPhone;
  final int totaldiscount;
  final double totalafterdiscount;
  final String cashier;
  final String lastcashier;
  final String firstcashier;
  final double totalgratuity;
  final double totalservicefee;
  final double totalbeforetax;
  final double totalvat;
  final double totalaftertax;
  final int roundingSetting;
  final double totalafterrounding;
  final int div;
  final String billDate;
  final String posBillDate;
  final String posPaidBillDate;
  final String rewardoption;
  final double return_;
  final dynamic proof;
  final dynamic proofStaffId;
  final dynamic tableName;
  final bool fromProcessBill;
  final Refund? refund;
  final List<CartItem>? items;

  BillModel({
    required this.billId,
    required this.customerName,
    required this.orderCollection,
    required this.total,
    required this.finalTotal,
    required this.downPayment,
    required this.usersId,
    required this.states,
    this.paymentMethod,
    this.splitPayment,
    required this.delivery,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.outletId,
    required this.servicefee,
    required this.gratuity,
    required this.vat,
    this.customerId,
    required this.billDiscount,
    this.tableId,
    required this.totalDiscount,
    required this.hashBill,
    required this.rewardPoints,
    required this.totalReward,
    required this.rewardBill,
    required this.cBillId,
    required this.rounding,
    required this.isQR,
    this.notes,
    required this.amountPaid,
    this.ccNumber,
    this.ccType,
    required this.productDiscount,
    this.merchantOrderId,
    this.discountList,
    required this.key,
    this.affiliate,
    this.customerPhone,
    required this.totaldiscount,
    required this.totalafterdiscount,
    required this.cashier,
    required this.lastcashier,
    required this.firstcashier,
    required this.totalgratuity,
    required this.totalservicefee,
    required this.totalbeforetax,
    required this.totalvat,
    required this.totalaftertax,
    required this.roundingSetting,
    required this.totalafterrounding,
    required this.div,
    required this.billDate,
    required this.posBillDate,
    required this.posPaidBillDate,
    required this.rewardoption,
    required this.return_,
    this.proof,
    this.proofStaffId,
    this.tableName,
    required this.fromProcessBill,
    this.refund,
    this.items,
  });

  BillModel copyWith({
    int? billId,
    String? customerName,
    String? orderCollection,
    double? total,
    double? finalTotal,
    double? downPayment,
    int? usersId,
    String? states,
    String? paymentMethod,
    dynamic splitPayment,
    String? delivery,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? outletId,
    String? servicefee,
    String? gratuity,
    String? vat,
    int? customerId,
    String? billDiscount,
    dynamic tableId,
    int? totalDiscount,
    String? hashBill,
    String? rewardPoints,
    int? totalReward,
    String? rewardBill,
    String? cBillId,
    int? rounding,
    int? isQR,
    String? notes,
    double? amountPaid,
    String? ccNumber,
    String? ccType,
    int? productDiscount,
    dynamic merchantOrderId,
    dynamic discountList,
    int? key,
    dynamic affiliate,
    String? customerPhone,
    int? totaldiscount,
    double? totalafterdiscount,
    String? cashier,
    String? lastcashier,
    String? firstcashier,
    double? totalgratuity,
    double? totalservicefee,
    double? totalbeforetax,
    double? totalvat,
    double? totalaftertax,
    int? roundingSetting,
    double? totalafterrounding,
    int? div,
    String? billDate,
    String? posBillDate,
    String? posPaidBillDate,
    String? rewardoption,
    double? return_,
    dynamic proof,
    dynamic proofStaffId,
    dynamic tableName,
    bool? fromProcessBill,
    Refund? refund,
    List<CartItem>? items,
  }) {
    return BillModel(
      billId: billId ?? this.billId,
      customerName: customerName ?? this.customerName,
      orderCollection: orderCollection ?? this.orderCollection,
      total: total ?? this.total,
      finalTotal: finalTotal ?? this.finalTotal,
      downPayment: downPayment ?? this.downPayment,
      usersId: usersId ?? this.usersId,
      states: states ?? this.states,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      splitPayment: splitPayment ?? this.splitPayment,
      delivery: delivery ?? this.delivery,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      outletId: outletId ?? this.outletId,
      servicefee: servicefee ?? this.servicefee,
      gratuity: gratuity ?? this.gratuity,
      vat: vat ?? this.vat,
      customerId: customerId ?? this.customerId,
      billDiscount: billDiscount ?? this.billDiscount,
      tableId: tableId ?? this.tableId,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      hashBill: hashBill ?? this.hashBill,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      totalReward: totalReward ?? this.totalReward,
      rewardBill: rewardBill ?? this.rewardBill,
      cBillId: cBillId ?? this.cBillId,
      rounding: rounding ?? this.rounding,
      isQR: isQR ?? this.isQR,
      notes: notes ?? this.notes,
      amountPaid: amountPaid ?? this.amountPaid,
      ccNumber: ccNumber ?? this.ccNumber,
      ccType: ccType ?? this.ccType,
      productDiscount: productDiscount ?? this.productDiscount,
      merchantOrderId: merchantOrderId ?? this.merchantOrderId,
      discountList: discountList ?? this.discountList,
      key: key ?? this.key,
      affiliate: affiliate ?? this.affiliate,
      customerPhone: customerPhone ?? this.customerPhone,
      totaldiscount: totaldiscount ?? this.totaldiscount,
      totalafterdiscount: totalafterdiscount ?? this.totalafterdiscount,
      cashier: cashier ?? this.cashier,
      lastcashier: lastcashier ?? this.lastcashier,
      firstcashier: firstcashier ?? this.firstcashier,
      totalgratuity: totalgratuity ?? this.totalgratuity,
      totalservicefee: totalservicefee ?? this.totalservicefee,
      totalbeforetax: totalbeforetax ?? this.totalbeforetax,
      totalvat: totalvat ?? this.totalvat,
      totalaftertax: totalaftertax ?? this.totalaftertax,
      roundingSetting: roundingSetting ?? this.roundingSetting,
      totalafterrounding: totalafterrounding ?? this.totalafterrounding,
      div: div ?? this.div,
      billDate: billDate ?? this.billDate,
      posBillDate: posBillDate ?? this.posBillDate,
      posPaidBillDate: posPaidBillDate ?? this.posPaidBillDate,
      rewardoption: rewardoption ?? this.rewardoption,
      return_: return_ ?? this.return_,
      proof: proof ?? this.proof,
      proofStaffId: proofStaffId ?? this.proofStaffId,
      tableName: tableName ?? this.tableName,
      fromProcessBill: fromProcessBill ?? this.fromProcessBill,
      refund: refund ?? this.refund,
      items: items ?? this.items,
    );
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    List<CartItem>? orderItems;
    if (json['order_collection'] != null) {
      try {
        final List<dynamic> parsedItems = jsonDecode(json['order_collection']);
        orderItems =
            parsedItems.map((item) => CartItem.fromJson(item)).toList();
      } catch (e) {
        rethrow;
      }
    }

    return BillModel(
      billId: json['bill_id'] ?? 0,
      customerName: json['customer_name'] ?? 'Unknown',
      orderCollection: json['order_collection'] ?? '[]',
      total:
          json['total'] is int
              ? (json['total'] as int).toDouble()
              : (json['total'] ?? 0).toDouble(),
      finalTotal:
          json['final_total'] is int
              ? (json['final_total'] as int).toDouble()
              : (json['final_total'] ?? 0).toDouble(),
      downPayment:
          json['down_payment'] is int
              ? (json['down_payment'] as int).toDouble()
              : (json['down_payment'] ?? 0).toDouble(),
      usersId: json['users_id'] ?? 0,
      states: json['states'] ?? 'open',
      paymentMethod: json['payment_method'],
      splitPayment: json['split_payment'],
      delivery: json['delivery'] ?? 'direct',
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
      outletId: json['outlet_id'] ?? 0,
      servicefee: json['servicefee'] ?? '0.00',
      gratuity: json['gratuity'] ?? '0.00',
      vat: json['vat'] ?? '0.00',
      customerId: json['customer_id'],
      billDiscount: json['bill_discount'] ?? '0.00',
      tableId: json['table_id'],
      totalDiscount: json['total_discount'] ?? 0,
      hashBill: json['hash_bill'] ?? '',
      rewardPoints:
          json['reward_points'] ?? '{"initial":0,"redeem":0,"earn":0}',
      totalReward: json['total_reward'] ?? 0,
      rewardBill: json['reward_bill'] ?? '0.00',
      cBillId: json['c_bill_id']?.toString() ?? '0',
      rounding: json['rounding'] ?? 0,
      isQR: json['isQR'] ?? 0,
      notes: json['notes'],
      amountPaid:
          json['amount_paid'] is int
              ? (json['amount_paid'] as int).toDouble()
              : (json['amount_paid'] ?? 0).toDouble(),
      ccNumber: json['cc_number'],
      ccType: json['cc_type'],
      productDiscount: json['product_discount'] ?? 0,
      merchantOrderId: json['merchant_order_id'],
      discountList: json['discount_list'],
      key: json['key'] ?? 0,
      affiliate: json['affiliate'],
      customerPhone: json['customer_phone'],
      totaldiscount: json['totaldiscount'] ?? 0,
      totalafterdiscount:
          json['totalafterdiscount'] is int
              ? (json['totalafterdiscount'] as int).toDouble()
              : (json['totalafterdiscount'] ?? 0).toDouble(),
      cashier: json['cashier'] ?? 'Unknown',
      lastcashier: json['lastcashier'] ?? 'Unknown',
      firstcashier: json['firstcashier'] ?? 'Unknown',
      totalgratuity:
          json['totalgratuity'] is int
              ? (json['totalgratuity'] as int).toDouble()
              : (json['totalgratuity'] ?? 0).toDouble(),
      totalservicefee:
          json['totalservicefee'] is int
              ? (json['totalservicefee'] as int).toDouble()
              : (json['totalservicefee'] ?? 0).toDouble(),
      totalbeforetax:
          json['totalbeforetax'] is int
              ? (json['totalbeforetax'] as int).toDouble()
              : (json['totalbeforetax'] ?? 0).toDouble(),
      totalvat:
          json['totalvat'] is int
              ? (json['totalvat'] as int).toDouble()
              : (json['totalvat'] ?? 0).toDouble(),
      totalaftertax:
          json['totalaftertax'] is int
              ? (json['totalaftertax'] as int).toDouble()
              : (json['totalaftertax'] ?? 0).toDouble(),
      roundingSetting: json['rounding_setting'] ?? 0,
      totalafterrounding:
          json['totalafterrounding'] is int
              ? (json['totalafterrounding'] as int).toDouble()
              : (json['totalafterrounding'] ?? 0).toDouble(),
      div: json['div'] ?? 0,
      billDate: json['bill_date'] ?? '',
      posBillDate: json['pos_bill_date'] ?? '',
      posPaidBillDate: json['pos_paid_bill_date'] ?? '',
      rewardoption: json['rewardoption'] ?? '',
      return_:
          json['return'] is int
              ? (json['return'] as int).toDouble()
              : (json['return'] ?? 0).toDouble(),
      proof: json['proof'],
      proofStaffId: json['proof_staff_id'],
      tableName: json['table_name'],
      fromProcessBill: json['fromProcessBill'] ?? false,
      refund: json['refund'] != null ? Refund.fromJson(json['refund']) : null,
      items: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bill_id': billId,
      'customer_name': customerName,
      'order_collection': orderCollection,
      'total': total,
      'final_total': finalTotal,
      'down_payment': downPayment,
      'users_id': usersId,
      'states': states,
      'payment_method': paymentMethod,
      'split_payment': splitPayment,
      'delivery': delivery,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'outlet_id': outletId,
      'servicefee': servicefee,
      'gratuity': gratuity,
      'vat': vat,
      'customer_id': customerId,
      'bill_discount': billDiscount,
      'table_id': tableId,
      'total_discount': totalDiscount,
      'hash_bill': hashBill,
      'reward_points': rewardPoints,
      'total_reward': totalReward,
      'reward_bill': rewardBill,
      'c_bill_id': cBillId,
      'rounding': rounding,
      'isQR': isQR,
      'notes': notes,
      'amount_paid': amountPaid,
      'cc_number': ccNumber,
      'cc_type': ccType,
      'product_discount': productDiscount,
      'merchant_order_id': merchantOrderId,
      'discount_list': discountList,
      'key': key,
      'affiliate': affiliate,
      'customer_phone': customerPhone,
      'totaldiscount': totaldiscount,
      'totalafterdiscount': totalafterdiscount,
      'cashier': cashier,
      'lastcashier': lastcashier,
      'firstcashier': firstcashier,
      'totalgratuity': totalgratuity,
      'totalservicefee': totalservicefee,
      'totalbeforetax': totalbeforetax,
      'totalvat': totalvat,
      'totalaftertax': totalaftertax,
      'rounding_setting': roundingSetting,
      'totalafterrounding': totalafterrounding,
      'div': div,
      'bill_date': billDate,
      'pos_bill_date': posBillDate,
      'pos_paid_bill_date': posPaidBillDate,
      'rewardoption': rewardoption,
      'return': return_,
      'proof': proof,
      'proof_staff_id': proofStaffId,
      'table_name': tableName,
      'fromProcessBill': fromProcessBill,
      'refund': refund?.toJson(),
    };
  }

  // Static method to parse bills from JSON string
  static List<BillModel> parseBills(String jsonString) {
    try {
      final List<dynamic> parsed = jsonDecode(jsonString);

      final List<BillModel> bills = [];
      for (var json in parsed) {
        try {
          bills.add(BillModel.fromJson(json));
        } catch (e) {
          // Continue with next bill instead of rethrowing
        }
      }
      return bills;
    } catch (e) {
      return [];
    }
  }

  // Helper methods
  bool get isPaid => states == 'closed';
  bool get isRefunded => refund != null;
  String get formattedTotal => finalTotal.toStringAsFixed(2);
  String get formattedDate => billDate;

  // Get formatted payment status
  String get paymentStatus {
    if (isRefunded) return 'Refunded';
    if (isPaid) return 'Paid';
    return 'Open';
  }

  // Add bill items to a cart
  void addItemsToCart(CartNotifier cartNotifier) {
    if (items != null && items!.isNotEmpty) {
      for (var item in items!) {
        cartNotifier.addItem(item);
      }
    } else if (orderCollection.isNotEmpty) {
      cartNotifier.addItemsFromBill(orderCollection);
    }

    // Set tax, service fee, and gratuity percentages
    double serviceFeePercent = double.tryParse(servicefee) ?? 5.0;
    double taxPercent = double.tryParse(vat) ?? 10.0;
    double gratuityPercent = double.tryParse(gratuity) ?? 0.0;

    cartNotifier.updateServiceFeePercentage(serviceFeePercent);
    cartNotifier.updateTaxPercentage(taxPercent);
    cartNotifier.updateGratuityPercentage(gratuityPercent);
  }

  // Helper method to load a bill into cart
  void loadIntoCart(CartNotifier cartNotifier) {
    cartNotifier.loadBill(this);
  }

  // Static method to load bills from an asset file
  static Future<List<BillModel>> loadBillsFromAsset(String assetPath) async {
    try {
      // Use AssetBundle to load the asset file content
      final jsonString = await rootBundle.loadString(assetPath);
      return parseBills(jsonString);
    } catch (e) {
      return [];
    }
  }
}
