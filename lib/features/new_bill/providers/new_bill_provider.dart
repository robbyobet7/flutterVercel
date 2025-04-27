import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewBillNotifier extends StateNotifier<String> {
  NewBillNotifier() : super("");

  void setNewBill(String bill) {
    state = bill;
  }
}

final newBillProvider = StateNotifierProvider<NewBillNotifier, String>((ref) {
  return NewBillNotifier();
});
