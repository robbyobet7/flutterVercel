import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainBillNotifier extends StateNotifier<String> {
  MainBillNotifier() : super("");

  void setMainBill(String component) {
    state = component;
  }
}

final mainBillProvider = StateNotifierProvider<MainBillNotifier, String>((ref) {
  return MainBillNotifier();
});
