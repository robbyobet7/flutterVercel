import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                spacing: 16,

                children: [
                  ExpansionStockTaking(
                    title: 'Products',
                    items: productStockTaking,
                  ),
                  ExpansionStockTaking(
                    title: 'Ingredients',
                    items: ingredientStockTaking,
                  ),
                  ExpansionStockTaking(title: 'Preps', items: prepStockTaking),
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

class ExpansionStockTaking extends StatelessWidget {
  const ExpansionStockTaking({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<StockTaking> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      showTrailingIcon: false,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: theme.colorScheme.surfaceContainer),
        borderRadius: BorderRadius.circular(12),
      ),
      collapsedShape: RoundedRectangleBorder(
        side: BorderSide(width: 1, color: theme.colorScheme.surfaceContainer),
        borderRadius: BorderRadius.circular(12),
      ),
      expandedAlignment: Alignment.centerLeft,
      tilePadding: EdgeInsets.symmetric(horizontal: 24),
      childrenPadding: EdgeInsets.zero,
      backgroundColor: theme.colorScheme.primaryContainer,
      collapsedBackgroundColor: theme.colorScheme.primaryContainer,
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.displaySmall),
            Row(
              children: [
                Icon(Icons.expand_more, color: theme.colorScheme.primary),
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      width: 1,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  side: BorderSide(width: 2, color: theme.colorScheme.primary),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
          ],
        ),
      ),
      initiallyExpanded: true,
      children: items.map((e) => ExpansionContainer(item: e)).toList(),
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
