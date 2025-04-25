import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_bill.dart';

// Provider to track the selected user for bills
final selectedUserBillProvider =
    StateNotifierProvider<SelectedUserBillNotifier, UserBill>((ref) {
      return SelectedUserBillNotifier();
    });

class SelectedUserBillNotifier extends StateNotifier<UserBill> {
  SelectedUserBillNotifier()
    // Initialize with the first user (My Bills) as default
    : super(UserBill.dummyUsers.first);

  void selectUser(UserBill user) {
    state = user;
  }
}
