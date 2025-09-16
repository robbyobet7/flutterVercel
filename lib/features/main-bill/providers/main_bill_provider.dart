import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/customers.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/providers/discounts_provider.dart';
import 'package:rebill_flutter/core/providers/checkout_discount_provider.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/core/middleware/customer_middleware.dart';

class MainBillNotifier extends StateNotifier<MainBillComponent> {
  MainBillNotifier() : super(MainBillComponent.defaultComponent);

  void setMainBill(MainBillComponent component) {
    state = component;
  }
}

void resetMainBill(WidgetRef ref) {
  // Clear the shopping cart
  ref.read(cartProvider.notifier).clearCart();

  // Clear the currently selected bill
  ref.read(billProvider.notifier).clearSelectedBill();

  // Clear all applied discounts
  ref.invalidate(selectedDiscountsProvider);

  // Clear checkout discount
  ref.read(checkoutDiscountProvider.notifier).clearDiscounts();

  // Clear the currently selected customer
  ref.read(knownIndividualProvider.notifier).setKnownIndividual(null);

  // Reset customer type to 'Guest'
  ref.read(customerTypeProvider.notifier).setCustomerType(CustomerType.guest);

  // Return the view to the default component
  ref
      .read(mainBillProvider.notifier)
      .setMainBill(MainBillComponent.defaultComponent);
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

final customerExpandableProvider = StateProvider<bool>((ref) => false);

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
      final customer = _middleware.getCustomerById(customerId);
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
