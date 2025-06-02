import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';
import 'package:rebill_flutter/features/stock-taking/presentations/widgets/expandable_list.dart';
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

    final headers = [
      Header(flex: 2, text: 'Item'),
      Header(flex: 1, text: 'Current Stock', textAlign: TextAlign.center),
      Header(flex: 1, text: 'Actual Stock', textAlign: TextAlign.center),
      Header(flex: 1, text: 'Checklist', textAlign: TextAlign.end),
    ];

    return Expanded(
      child: Column(
        spacing: 16,
        children: [
          AppDivider(),

          //filtering row
          SizedBox(
            height: 45,
            width: double.infinity,
            child: Row(
              spacing: 12,
              children: [
                TypeFilterContainer(type: 'Products'),
                TypeFilterContainer(type: 'Ingredients'),
                TypeFilterContainer(type: 'Preps'),
                Expanded(child: AppSearchBar()),
              ],
            ),
          ),

          //list header
          ListHeader(headers: headers),

          //Expandable list
          Expanded(
            child: FutureBuilder<void>(
              future: initializeStockTakings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final ingredients = ref.watch(ingredientsProvider);
                final products = ref.watch(productStockProvider);
                final preps = ref.watch(prepsProvider);

                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    spacing: 12,
                    children: [
                      ExpandableList(title: 'Products', stockTakings: products),
                      ExpandableList(
                        title: 'Ingredients',
                        stockTakings: ingredients,
                      ),
                      ExpandableList(title: 'Preps', stockTakings: preps),
                      AppDivider(),
                    ],
                  ),
                );
              },
            ),
          ),

          //bottom row
          SizedBox(
            height: 45,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(text: 'Add Notes', onPressed: () {}),
                Row(
                  spacing: 12,
                  children: [
                    AppButton(
                      text: 'Cancel',
                      onPressed: () {},
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    AppButton(
                      text: 'Submit',
                      onPressed: () {},
                      backgroundColor: theme.colorScheme.primary,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
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
