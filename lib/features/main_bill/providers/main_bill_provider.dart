import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/customers.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/core/middleware/customer_middleware.dart';

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

class KnownIndividualNotifier extends StateNotifier<CustomerModel?> {
  final CustomerMiddleware _middleware = CustomerMiddleware();

  KnownIndividualNotifier() : super(null);

  void setKnownIndividual(CustomerModel? individual) {
    state = individual;
  }

  Future<CustomerModel?> getCustomerById(int customerId) async {
    // First check if current state matches the requested customer
    if (state != null && state!.customerId == customerId) {
      return state;
    }

    // If not in state, fetch from the middleware
    try {
      final customer = await _middleware.getCustomer(customerId);
      if (customer != null) {
        // Update the state with the found customer
        state = customer;
        return customer;
      }
    } catch (e) {
      rethrow;
    }

    return null;
  }
}

final knownIndividualProvider =
    StateNotifierProvider<KnownIndividualNotifier, CustomerModel?>((ref) {
      return KnownIndividualNotifier();
    });
