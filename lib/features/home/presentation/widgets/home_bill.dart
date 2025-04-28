import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import '../../providers/bill_search_provider.dart';
import '../../providers/filtered_bills_provider.dart';
import 'user_bills_dropdown.dart';

class HomeBill extends ConsumerStatefulWidget {
  const HomeBill({super.key});

  @override
  ConsumerState<HomeBill> createState() => _HomeBillState();
}

class _HomeBillState extends ConsumerState<HomeBill> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Add a color cache to avoid recalculating colors

  @override
  void initState() {
    super.initState();
    // Set initial value
    _searchController.text = ref.read(billSearchProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Helper method to get status color
  Color _getStatusColor(String status, ThemeData theme) {
    // Don't use caching at all - calculate color every time
    // This ensures theme changes are reflected immediately
    return _calculateStatusColor(status);
  }

  // Original color calculation logic
  Color _calculateStatusColor(String status) {
    // Get theme inside the method each time it's called
    final theme = Theme.of(context);

    switch (status.toLowerCase()) {
      case 'closed':
        return theme.colorScheme.surfaceContainer;
      case 'open':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.surfaceContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchQuery = ref.watch(billSearchProvider);

    // Get filtered bills directly from provider - fully reactive!
    final filteredBills = ref.watch(filteredBillsProvider);

    // Keep controller in sync with provider state
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
      // Position cursor at the end
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return GestureDetector(
      // Dismiss keyboard when tapping outside
      onTap: () => FocusScope.of(context).unfocus(),
      // Avoid registering as a tap when the user is interacting with children
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: AppTheme.kBoxShadow,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 40,
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
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: UserBillsDropdown()),
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
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              // Set autofocus to false to prevent automatic focus
                              autofocus: false,
                              decoration: const InputDecoration(
                                hintText: 'Search Bill...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: theme.textTheme.bodyMedium,
                              onChanged: (value) {
                                ref
                                    .read(billSearchProvider.notifier)
                                    .updateSearchQuery(value);
                              },
                              // Handle tap on the text field explicitly
                              onTap: () {
                                // Only handle focus if explicitly tapped
                                _searchFocusNode.requestFocus();
                              },
                            ),
                          ),
                          if (searchQuery.isNotEmpty)
                            GestureDetector(
                              // Stop the parent gesture detector from receiving this tap
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                ref
                                    .read(billSearchProvider.notifier)
                                    .clearSearch();
                                // Also unfocus to hide keyboard
                                _searchFocusNode.unfocus();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.clear, size: 16),
                              ),
                            ),
                          GestureDetector(
                            // Stop the parent gesture detector from receiving this tap
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              // Toggle focus - if focused, unfocus, otherwise focus
                              if (_searchFocusNode.hasFocus) {
                                _searchFocusNode.unfocus();
                              } else {
                                _searchFocusNode.requestFocus();
                              }
                            },
                            child: const Icon(Icons.search, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  // Fixed table header that's only rendered once
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer.withOpacity(
                        0.5,
                      ),
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
                          flex: 2,
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
                    child: RepaintBoundary(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredBills.length,
                        // Add these performance optimization parameters
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        clipBehavior: Clip.hardEdge,
                        // Use cacheExtent to pre-render items outside the visible area
                        cacheExtent: 300,
                        itemBuilder: (context, index) {
                          final dayData = filteredBills[index];
                          // Use KeyedSubtree to maintain state when items move
                          return KeyedSubtree(
                            key: ValueKey('day-${dayData.date}'),
                            child: _buildDaySection(context, dayData, theme),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    dynamic dayData,
    ThemeData theme,
  ) {
    // Add spacing after each day section except the last one
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with date
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
            child: Text(
              dayData.date,
              textAlign: TextAlign.start,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          // Bills container
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.surfaceContainer),
            ),
            child: Column(children: _buildBillItems(dayData.bills, theme)),
          ),
        ],
      ),
    );
  }

  // Extract bill items building to a separate method
  List<Widget> _buildBillItems(List<dynamic> bills, ThemeData theme) {
    // Using List.generate is more efficient than .map() with spread operator
    return List.generate(bills.length, (index) {
      final bill = bills[index];
      // Cache the status color to avoid recalculating it
      final statusColor = _getStatusColor(bill.status, theme);
      final isFirstItem = index == 0;
      final billTotal = int.tryParse(bill.total) ?? 0;

      // Format currency once and cache it
      final formattedTotal = NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: 0,
      ).format(billTotal);

      // Determine text color based on background luminance
      final isLightBackground = statusColor.computeLuminance() > 0.5;
      final textColor = isLightBackground ? Colors.black : Colors.white;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top:
                isFirstItem
                    ? BorderSide.none
                    : BorderSide(color: theme.colorScheme.surfaceContainer),
          ),
        ),
        child: Row(
          children: [
            // Bill name
            Expanded(flex: 4, child: Text(bill.name)),
            // Bill amount
            Expanded(
              flex: 3,
              child: Text(formattedTotal, style: theme.textTheme.labelLarge),
            ),
            // Status indicator
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bill.status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
