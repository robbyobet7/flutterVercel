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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productStockTaking = ref.watch(productStockTakingProvider);
    final ingredientStockTaking = ref.watch(ingredientStockTakingProvider);
    final prepStockTaking = ref.watch(prepStockTakingProvider);

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
                TypeFilterContainer(type: 'Products'),
                TypeFilterContainer(type: 'Ingredients'),
                TypeFilterContainer(type: 'Preps'),
                Expanded(child: AppSearchBar(hintText: 'Search Item...')),
              ],
            ),
          ),
          SizedBox(height: 16),

          ListHeader(
            headers: headers,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                children: [
                  ExpandedList(
                    stockTaking: productStockTaking,
                    title: 'Products',
                  ),
                  ExpandedList(
                    stockTaking: ingredientStockTaking,
                    title: 'Ingredients',
                  ),
                  ExpandedList(stockTaking: prepStockTaking, title: 'Preps'),
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
}

class ExpandedList extends ConsumerStatefulWidget {
  const ExpandedList({
    super.key,
    required this.stockTaking,
    required this.title,
  });

  final List<StockTaking> stockTaking;
  final String title;

  @override
  ConsumerState<ExpandedList> createState() => _ExpandedListState();
}

class _ExpandedListState extends ConsumerState<ExpandedList> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(height: 16),
        GestureDetector(
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
                bottomRight: !isExpanded ? Radius.circular(12) : Radius.zero,
              ),
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
        ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isExpanded ? 1.0 : 0.0,
              child: ListView.builder(
                cacheExtent: 200,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.stockTaking.length,
                itemBuilder:
                    (context, index) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.surfaceContainer,
                          ),
                          left: BorderSide(
                            color: theme.colorScheme.surfaceContainer,
                          ),
                          right: BorderSide(
                            color: theme.colorScheme.surfaceContainer,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          CellColumn(
                            flex: 3,
                            text: widget.stockTaking[index].productName,
                          ),
                          CellColumn(
                            flex: 2,
                            text:
                                widget.stockTaking[index].productStock
                                    .toString(),
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
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  side: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                  onChanged: (value) {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
