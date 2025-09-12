import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/customer_provider.dart';
import 'package:rebill_flutter/core/providers/merchant_provider.dart';
import 'package:rebill_flutter/core/providers/product_provider.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';
import 'package:rebill_flutter/core/providers/table_bill_provider.dart';
import 'package:rebill_flutter/core/providers/table_provider.dart';
import 'package:rebill_flutter/features/reservation/providers/reservation_provider.dart';

final initialDataPreloaderProvider = FutureProvider<void>((ref) async {
  await Future.delayed(Duration.zero);

  // It's now safe to call notifiers and modify other providers' state
  final dataFutures = [
    ref.read(paginatedProductsProvider.notifier).refresh(),
    ref.read(customerProvider.notifier).refreshCustomers(),
    ref.read(billProvider.notifier).loadBills(),
    ref.read(tableBillProvider.notifier).loadBills(),
    ref.read(tableProvider.notifier).refreshTables(),
    ref.read(reservationProvider.notifier).fetchReservations(),
    ref.read(merchantProvider.notifier).refresh(),
  ];

  // Run all futures in parallel and wait until all complete
  await Future.wait(dataFutures);

  // Invalidate providers that don't have explicit refresh methods if needed
  ref.invalidate(availableCategoriesProvider);
});
