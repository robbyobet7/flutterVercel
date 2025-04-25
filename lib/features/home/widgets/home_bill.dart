import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';

class BillDay {
  final String date;
  final List<Bill> bills;

  BillDay({required this.date, required this.bills});
}

class Bill {
  final String name;
  final String total;
  final String status;

  Bill({required this.name, required this.total, required this.status});
}

class HomeBill extends StatelessWidget {
  const HomeBill({super.key});

  // Dummy data for the bills table
  static final List<BillDay> _dummyBillData = [
    BillDay(
      date: 'Today - July 15, 2023',
      bills: [
        Bill(name: 'Customer 1', total: '1112050', status: 'Closed'),
        Bill(name: 'Customer 2', total: '118575', status: 'Open'),
        Bill(name: 'Customer 3', total: '11210.00', status: 'Open'),
      ],
    ),
    BillDay(
      date: 'Yesterday - July 14, 2023',
      bills: [
        Bill(name: 'Customer 4', total: '115425', status: 'Closed'),
        Bill(name: 'Customer 5', total: '1118230', status: 'Closed'),
      ],
    ),
    BillDay(
      date: 'July 12, 2023',
      bills: [
        Bill(name: 'Customer 6', total: '119500', status: 'Open'),
        Bill(name: 'Customer 7', total: '116550', status: 'Open'),
        Bill(name: 'Customer 8', total: '1114575', status: 'Closed'),
      ],
    ),
  ];

  // Helper method to get status color
  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'closed':
        return theme.colorScheme.error;
      case 'open':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.surfaceContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bills',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppButton(onPressed: () {}, text: 'Merge Bills'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.surfaceContainer,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('My Bills'),
                        Icon(Icons.expand_more, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.surfaceContainer,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Search Bill...'),
                        Icon(Icons.search, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                // Fixed table header that's only rendered once
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: theme.colorScheme.surfaceContainer,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Name',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Total',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Status',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 1,
                ), // Slight gap between header and content
                // Scrollable content
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _dummyBillData.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final dayData = _dummyBillData[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: 8,
                            ),
                            child: Text(
                              dayData.date,
                              textAlign: TextAlign.start,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.surfaceContainer,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Table rows only (header is now fixed above)
                                ...dayData.bills.map(
                                  (bill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top:
                                            dayData.bills.indexOf(bill) == 0
                                                ? BorderSide.none
                                                : BorderSide(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .surfaceContainer,
                                                ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(bill.name),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            NumberFormat.currency(
                                              locale: 'id_ID',
                                              symbol: '',
                                              decimalDigits: 0,
                                            ).format(
                                              int.tryParse(bill.total) ?? 0,
                                            ),
                                            style:
                                                theme.textTheme.labelLarge
                                                    ?.copyWith(),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                bill.status,
                                                theme,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              bill.status,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color:
                                                    _getStatusColor(
                                                              bill.status,
                                                              theme,
                                                            ).computeLuminance() >
                                                            0.5
                                                        ? Colors.black
                                                        : Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
