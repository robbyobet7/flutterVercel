import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' show min;
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockTakingProvider.notifier).fetchStockTakings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productStockTaking = ref.watch(productStockTakingProvider);
    final prepStockTaking = ref.watch(prepStockTakingProvider);
    final ingredientStockTaking = ref.watch(ingredientStockTakingProvider);

    final headers = [
      Header(flex: 3, text: 'Item'),
      Header(flex: 2, text: 'Current Stock', textAlign: TextAlign.center),
      Header(flex: 2, text: 'Actual Stock', textAlign: TextAlign.center),
      Header(flex: 1, text: 'Checklist', textAlign: TextAlign.end),
    ];

    return Expanded(
      child: Column(
        spacing: 16,
        children: [
          AppDivider(),
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
                  CustomExpansionWidget(
                    title: 'Products',
                    items: productStockTaking,
                  ),
                  CustomExpansionWidget(
                    title: 'Ingredients',
                    items: ingredientStockTaking,
                  ),
                  CustomExpansionWidget(title: 'Preps', items: prepStockTaking),
                ],
              ),
            ),
          ),
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

class CustomExpansionWidget extends StatefulWidget {
  final String title;
  final List<StockTaking> items;

  const CustomExpansionWidget({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  State<CustomExpansionWidget> createState() => _CustomExpansionWidgetState();
}

class _CustomExpansionWidgetState extends State<CustomExpansionWidget> {
  bool _isExpanded = true;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: theme.colorScheme.surfaceContainer),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpanded,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: theme.textTheme.displaySmall),
                  Row(
                    children: [
                      AnimatedRotation(
                        turns: _isExpanded ? 0 : -0.25,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            width: 1,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        side: BorderSide(
                          width: 2,
                          color: theme.colorScheme.primary,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        value: false,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Direct ListView.builder for content
          if (_isExpanded)
            Container(
              color: theme.colorScheme.surface,
              constraints: BoxConstraints(
                maxHeight:
                    double
                        .infinity, // Allow content to expand with parent scrolling
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                cacheExtent: 100,
                shrinkWrap: true, // Let the list expand to its full height
                physics:
                    ClampingScrollPhysics(), // Match parent scrolling behavior
                itemCount: widget.items.length,
                itemBuilder:
                    (context, index) =>
                        ExpansionContainer(item: widget.items[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class ExpansionContainer extends StatelessWidget {
  const ExpansionContainer({super.key, required this.item});

  final StockTaking item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          color: theme.colorScheme.surface,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Row(
            children: [
              CellColumn(flex: 3, text: item.productName),
              CellColumn(
                flex: 2,
                text: item.productStock.toString(),
                textAlign: TextAlign.center,
              ),
              CellColumn(
                flex: 2,
                text: '',
                child: Row(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Icon(Icons.remove),
                    ),
                    Flexible(
                      child: SizedBox(
                        height: 40,
                        width: 100,
                        child: AppTextField(
                          showLabel: false,
                          textAlign: TextAlign.center,
                          textStyle: theme.textTheme.bodyMedium,
                          controller: TextEditingController(),
                          onChanged: (_) {},
                          keyboardType: TextInputType.number,
                          hintText: 'Qty',
                          labelText: 'Qty',
                          constraints: BoxConstraints(
                            maxHeight: 40,
                            maxWidth: 100,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              CellColumn(
                flex: 1,
                text: '',
                textAlign: TextAlign.end,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          width: 1,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      side: BorderSide(
                        width: 2,
                        color: theme.colorScheme.primary,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      value: false,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppDivider(),
      ],
    );
  }
}
