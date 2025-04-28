import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CustomerType { guest, knownIndividual }

class NewBillNotifier extends StateNotifier<String> {
  NewBillNotifier() : super("");

  void setNewBill(String bill) {
    state = bill;
  }
}

final newBillProvider = StateNotifierProvider<NewBillNotifier, String>((ref) {
  return NewBillNotifier();
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
