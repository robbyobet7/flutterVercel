import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/decrement_button.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
import 'package:rebill_flutter/core/widgets/increment_button.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';
import 'package:rebill_flutter/features/stock-taking/models/stock_taking.dart';
import 'package:rebill_flutter/features/stock-taking/presentations/widgets/type_filter_container.dart';
import 'package:rebill_flutter/features/stock-taking/providers/stock_taking_provider.dart';

class StockTakingDialog extends ConsumerStatefulWidget {
  const StockTakingDialog({super.key});

  @override
  ConsumerState<StockTakingDialog> createState() => _StockTakingDialogState();
}

class _StockTakingDialogState extends ConsumerState<StockTakingDialog> {
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use select instead of watch to only rebuild on relevant changes
    final stockTakingState = ref.watch(stockTakingProvider);
    final isLoading = stockTakingState.isLoading;

    // Apply filtering here
    List<StockTaking> filteredProductStockTaking = _filterStockTakings(
      stockTakingState.productStockTakings,
      _searchQuery,
    );

    List<StockTaking> filteredIngredientStockTaking = _filterStockTakings(
      stockTakingState.ingredientStockTakings,
      _searchQuery,
    );

    List<StockTaking> filteredPrepStockTaking = _filterStockTakings(
      stockTakingState.prepStockTakings,
      _searchQuery,
    );

    final headers = [
      Header(flex: 3, text: 'Item'),
      Header(flex: 2, text: 'Current Stock', textAlign: TextAlign.center),
      Header(flex: 2, text: 'Actual Stock', textAlign: TextAlign.center),
      Header(flex: 1, text: 'Checklist', textAlign: TextAlign.end),
    ];

    return Expanded(
      child: Column(
        children: [
          AppDivider(),
          SizedBox(height: 16),
          Container(
            height: 40,
            width: double.infinity,
            child: Row(
              spacing: 12,
              children: [
                TypeFilterContainer(
                  type: 'Products',
                  isSelected: _selectedType == 'Products',
                  onTap: () => _updateFilter('Products'),
                ),
                TypeFilterContainer(
                  type: 'Ingredients',
                  isSelected: _selectedType == 'Ingredients',
                  onTap: () => _updateFilter('Ingredients'),
                ),
                TypeFilterContainer(
                  type: 'Preps',
                  isSelected: _selectedType == 'Preps',
                  onTap: () => _updateFilter('Preps'),
                ),
                Expanded(
                  child: AppSearchBar(
                    hintText: 'Search Item...',
                    onSearch: _updateSearchQuery,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          ListHeader(
            headers: headers,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),

          if (isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  children: [
                    // Only show sections based on filter
                    if (_selectedType == 'All' || _selectedType == 'Products')
                      ExpandedList(
                        stockTaking: filteredProductStockTaking,
                        title: 'Products',
                      ),
                    if (_selectedType == 'All' ||
                        _selectedType == 'Ingredients')
                      ExpandedList(
                        stockTaking: filteredIngredientStockTaking,
                        title: 'Ingredients',
                      ),
                    if (_selectedType == 'All' || _selectedType == 'Preps')
                      ExpandedList(
                        stockTaking: filteredPrepStockTaking,
                        title: 'Preps',
                      ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: TextEditingController(),
                      maxLines: 3,
                      showLabel: false,
                      hintText: 'Notes',
                    ),
                  ],
                ),
              ),
            ),
          AppDivider(),
          SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(onPressed: () {}, text: 'Notes'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 12,
                  children: [
                    AppButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: 'Cancel',
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    AppButton(
                      onPressed: () {},
                      text: 'Submit',
                      backgroundColor: theme.colorScheme.primary,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to filter stock takings based on search query
  List<StockTaking> _filterStockTakings(
    List<StockTaking> stockTakings,
    String query,
  ) {
    if (query.isEmpty) return stockTakings;

    return stockTakings
        .where(
          (item) =>
              item.productName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Update search query and trigger rebuild
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Update filter type and trigger rebuild
  void _updateFilter(String type) {
    setState(() {
      _selectedType = _selectedType == type ? 'All' : type;
    });
  }
}

class ExpandedList extends StatefulWidget {
  const ExpandedList({
    super.key,
    required this.stockTaking,
    required this.title,
  });

  final List<StockTaking> stockTaking;
  final String title;

  @override
  State<ExpandedList> createState() => _ExpandedListState();
}

class _ExpandedListState extends State<ExpandedList> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Don't render if list is empty
    if (widget.stockTaking.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: !isExpanded ? Radius.circular(12) : Radius.zero,
            bottomRight: !isExpanded ? Radius.circular(12) : Radius.zero,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => isExpanded = !isExpanded);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: !isExpanded ? Radius.circular(12) : Radius.zero,
                    bottomRight:
                        !isExpanded ? Radius.circular(12) : Radius.zero,
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Checkbox(
                          value: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(color: theme.colorScheme.primary),
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isExpanded)
          ListView.builder(
            cacheExtent: 200,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.stockTaking.length,
            itemBuilder:
                (context, index) =>
                    StockTakingItem(stockTaking: widget.stockTaking[index]),
          ),
      ],
    );
  }
}

// Extract item to separate widget to prevent rebuilds of parent
class StockTakingItem extends StatelessWidget {
  final StockTaking stockTaking;

  const StockTakingItem({super.key, required this.stockTaking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.surfaceContainer),
          left: BorderSide(color: theme.colorScheme.surfaceContainer),
          right: BorderSide(color: theme.colorScheme.surfaceContainer),
        ),
      ),
      child: Row(
        children: [
          CellColumn(flex: 3, text: stockTaking.productName),
          CellColumn(
            flex: 2,
            text: stockTaking.productStock.toString(),
            textAlign: TextAlign.center,
          ),
          CellColumn(
            flex: 2,
            text: '',
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecrementButton(),
                Expanded(
                  child: AppTextField(
                    showLabel: false,
                    controller: TextEditingController(),
                  ),
                ),
                IncrementButton(),
              ],
            ),
          ),
          CellColumn(
            flex: 1,
            text: '',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Checkbox(
                  value: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
