import 'dart:convert';

class OrderItem {
  final int id;
  final String name;
  final double price;
  final double quantity;
  final String type;
  final double purchprice;
  final double includedtax;
  final dynamic options;
  final String category;
  final dynamic categoryBillPrinter;
  final String? productNotes;
  final double originalPrice;
  final double originalPurchprice;
  final String? discountType;
  final dynamic discountValue;
  final double discount;
  final String? discountName;
  final dynamic discountProducts;
  final dynamic discountRules;
  final String? discountType2;
  final dynamic discountId;
  final String? productDiscountType;
  final bool? isCashProductDiscount;
  final double? totalDiscountRules;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.type,
    required this.purchprice,
    required this.includedtax,
    this.options,
    required this.category,
    this.categoryBillPrinter,
    this.productNotes,
    required this.originalPrice,
    required this.originalPurchprice,
    this.discountType,
    this.discountValue,
    this.discount = 0,
    this.discountName,
    this.discountProducts,
    this.discountRules,
    this.discountType2,
    this.discountId,
    this.productDiscountType,
    this.isCashProductDiscount,
    this.totalDiscountRules,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price'],
      quantity:
          (json['quantity'] is int)
              ? (json['quantity'] as int).toDouble()
              : json['quantity'],
      type: json['type'],
      purchprice:
          (json['purchprice'] is int)
              ? (json['purchprice'] as int).toDouble()
              : json['purchprice'],
      includedtax:
          (json['includedtax'] is int)
              ? (json['includedtax'] as int).toDouble()
              : json['includedtax'] ?? 0,
      options: json['options'],
      category: json['category'],
      categoryBillPrinter: json['category_bill_printer'],
      productNotes: json['productNotes'],
      originalPrice:
          (json['original_price'] is int)
              ? (json['original_price'] as int).toDouble()
              : json['original_price'],
      originalPurchprice:
          (json['original_purchprice'] is int)
              ? (json['original_purchprice'] as int).toDouble()
              : json['original_purchprice'],
      discountType: json['discount_type'],
      discountValue: json['discount_value'],
      discount:
          (json['discount'] is int)
              ? (json['discount'] as int).toDouble()
              : (json['discount'] ?? 0).toDouble(),
      discountName: json['discount_name'],
      discountProducts: json['discount_products'],
      discountRules: json['discount_rules'],
      discountType2: json['discount_type2'],
      discountId: json['discount_id'],
      productDiscountType: json['productDiscountType'],
      isCashProductDiscount: json['isCashProductDiscount'],
      totalDiscountRules:
          json['totaldiscountrules'] != null
              ? (json['totaldiscountrules'] is int)
                  ? (json['totaldiscountrules'] as int).toDouble()
                  : json['totaldiscountrules']
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'type': type,
      'purchprice': purchprice,
      'includedtax': includedtax,
      'options': options,
      'category': category,
      'category_bill_printer': categoryBillPrinter,
      'productNotes': productNotes,
      'original_price': originalPrice,
      'original_purchprice': originalPurchprice,
      'discount_type': discountType,
      'discount_value': discountValue,
      'discount': discount,
      'discount_name': discountName,
      'discount_products': discountProducts,
      'discount_rules': discountRules,
      'discount_type2': discountType2,
      'discount_id': discountId,
      'productDiscountType': productDiscountType,
      'isCashProductDiscount': isCashProductDiscount,
      'totaldiscountrules': totalDiscountRules,
    };
  }
}

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
  final List<OrderItem>? items;

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

  factory BillModel.fromJson(Map<String, dynamic> json) {
    List<OrderItem>? orderItems;
    if (json['order_collection'] != null) {
      try {
        final List<dynamic> parsedItems = jsonDecode(json['order_collection']);
        orderItems =
            parsedItems.map((item) => OrderItem.fromJson(item)).toList();
      } catch (e) {
        print('Error parsing order collection: $e');
      }
    }

    return BillModel(
      billId: json['bill_id'],
      customerName: json['customer_name'],
      orderCollection: json['order_collection'],
      total:
          json['total'] is int
              ? (json['total'] as int).toDouble()
              : json['total'],
      finalTotal:
          json['final_total'] is int
              ? (json['final_total'] as int).toDouble()
              : json['final_total'],
      downPayment:
          json['down_payment'] is int
              ? (json['down_payment'] as int).toDouble()
              : json['down_payment'],
      usersId: json['users_id'],
      states: json['states'],
      paymentMethod: json['payment_method'],
      splitPayment: json['split_payment'],
      delivery: json['delivery'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
      outletId: json['outlet_id'],
      servicefee: json['servicefee'],
      gratuity: json['gratuity'],
      vat: json['vat'],
      customerId: json['customer_id'],
      billDiscount: json['bill_discount'],
      tableId: json['table_id'],
      totalDiscount: json['total_discount'],
      hashBill: json['hash_bill'],
      rewardPoints: json['reward_points'],
      totalReward: json['total_reward'],
      rewardBill: json['reward_bill'],
      cBillId: json['c_bill_id'],
      rounding: json['rounding'],
      isQR: json['isQR'],
      notes: json['notes'],
      amountPaid:
          json['amount_paid'] is int
              ? (json['amount_paid'] as int).toDouble()
              : json['amount_paid'],
      ccNumber: json['cc_number'],
      ccType: json['cc_type'],
      productDiscount: json['product_discount'],
      merchantOrderId: json['merchant_order_id'],
      discountList: json['discount_list'],
      key: json['key'],
      affiliate: json['affiliate'],
      customerPhone: json['customer_phone'],
      totaldiscount: json['totaldiscount'],
      totalafterdiscount:
          json['totalafterdiscount'] is int
              ? (json['totalafterdiscount'] as int).toDouble()
              : json['totalafterdiscount'],
      cashier: json['cashier'],
      lastcashier: json['lastcashier'],
      firstcashier: json['firstcashier'],
      totalgratuity:
          json['totalgratuity'] is int
              ? (json['totalgratuity'] as int).toDouble()
              : json['totalgratuity'],
      totalservicefee:
          json['totalservicefee'] is int
              ? (json['totalservicefee'] as int).toDouble()
              : json['totalservicefee'],
      totalbeforetax:
          json['totalbeforetax'] is int
              ? (json['totalbeforetax'] as int).toDouble()
              : json['totalbeforetax'],
      totalvat:
          json['totalvat'] is int
              ? (json['totalvat'] as int).toDouble()
              : json['totalvat'],
      totalaftertax:
          json['totalaftertax'] is int
              ? (json['totalaftertax'] as int).toDouble()
              : json['totalaftertax'],
      roundingSetting: json['rounding_setting'],
      totalafterrounding:
          json['totalafterrounding'] is int
              ? (json['totalafterrounding'] as int).toDouble()
              : json['totalafterrounding'],
      div: json['div'],
      billDate: json['bill_date'],
      posBillDate: json['pos_bill_date'],
      posPaidBillDate: json['pos_paid_bill_date'],
      rewardoption: json['rewardoption'],
      return_:
          json['return'] is int
              ? (json['return'] as int).toDouble()
              : json['return'],
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

  // Parse a list of bills from JSON string
  static List<BillModel> parseBills(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => BillModel.fromJson(json)).toList();
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
}
