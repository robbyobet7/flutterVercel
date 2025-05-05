import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/bill.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/features/home/presentation/widgets/user_bills_dropdown.dart';

/// Example screen demonstrating bill filtering capabilities
class BillFilterExample extends ConsumerStatefulWidget {
  const BillFilterExample({Key? key}) : super(key: key);

  @override
  ConsumerState<BillFilterExample> createState() => _BillFilterExampleState();
}

class _BillFilterExampleState extends ConsumerState<BillFilterExample> {
  @override
  void initState() {
    super.initState();
    // Load bills when the screen initializes
    Future.microtask(() => ref.read(billProvider.notifier).loadBills());
  }

  @override
  Widget build(BuildContext context) {
    // Watch bill state
    final billState = ref.watch(billProvider);
    final isLoading = billState.isLoading;
    final error = billState.error;
    final bills = billState.bills;

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Management')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter Bills',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Filter by bill status (All, Open, Closed)
                            const Expanded(child: BillFilterDropdown()),
                            const SizedBox(width: 16),
                            // Filter by customer
                            const Expanded(child: CustomerBillsDropdown()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        bills.isEmpty
                            ? const Center(child: Text('No bills found'))
                            : ListView.builder(
                              itemCount: bills.length,
                              itemBuilder: (context, index) {
                                final bill = bills[index];
                                return BillListItem(bill: bill);
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}

/// A simple list item to display bill information
class BillListItem extends ConsumerWidget {
  final BillModel bill;

  const BillListItem({Key? key, required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Choose color based on bill status
    Color statusColor;
    if (bill.isRefunded) {
      statusColor = Colors.red;
    } else if (bill.states == 'closed') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(bill.customerName, style: theme.textTheme.titleMedium),
        subtitle: Text(
          'Bill #${bill.cBillId} - ${bill.formattedDate}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                bill.paymentStatus,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${bill.finalTotal.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        onTap: () {
          // Select the bill when tapped
          ref.read(billProvider.notifier).selectBill(bill);
          // Show a snackbar to confirm selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected bill: ${bill.cBillId}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
