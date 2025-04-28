import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';

class MainBillNotifier extends StateNotifier<MainBillComponent> {
  MainBillNotifier() : super(MainBillComponent.defaultComponent);

  void setMainBill(MainBillComponent component) {
    state = component;
  }
}

final mainBillProvider =
    StateNotifierProvider<MainBillNotifier, MainBillComponent>((ref) {
      return MainBillNotifier();
    });

class CustomerTypeNotifier extends StateNotifier<CustomerType?> {
  CustomerTypeNotifier() : super(CustomerType.guest);

  void setCustomerType(CustomerType type) {
    state = type;
  }
}

final customerTypeProvider =
    StateNotifierProvider<CustomerTypeNotifier, CustomerType?>((ref) {
      return CustomerTypeNotifier();
    });

class BillTypeNotifier extends StateNotifier<BillType?> {
  BillTypeNotifier() : super(BillType.newBill);

  void setBillType(BillType type) {
    state = type;
  }
}

final billTypeProvider = StateNotifierProvider<BillTypeNotifier, BillType?>((
  ref,
) {
  return BillTypeNotifier();
});
