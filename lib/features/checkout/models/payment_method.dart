enum PaymentMethodType { transfer, cash, other }

class PaymentMethod {
  final int id;
  final int outletId;
  final String paymentName;
  final PaymentMethodType methodType;
  final int status;

  PaymentMethod({
    required this.id,
    required this.outletId,
    required this.paymentName,
    required this.status,
    required this.methodType,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    PaymentMethodType mapStringToEnum(String? method) {
      switch (method) {
        case 'transfer':
          return PaymentMethodType.transfer;
        case 'cash':
          return PaymentMethodType.cash;
        default:
          return PaymentMethodType.other;
      }
    }

    return PaymentMethod(
      id: json['id'],
      paymentName: json['payment_name'],
      methodType: mapStringToEnum(json['payment_method']),
      status: json['status'],
      outletId: json['outlet_id'],
    );
  }
}
