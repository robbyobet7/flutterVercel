import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';

class SubmittedOrder extends ConsumerWidget {
  const SubmittedOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: AppTheme.kBoxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
      child: Column(
        spacing: 12,
        children: [
          SizedBox(
            height: 40,
            width: double.infinity,
            child: Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Orders',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: AppSearchBar(
                    onSearch: (value) {},
                    hintText: 'Search Orders...',
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: 10,
              cacheExtent: 10,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    KitchenOrderContainer(),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class KitchenOrderContainer extends StatefulWidget {
  const KitchenOrderContainer({super.key});

  @override
  State<KitchenOrderContainer> createState() => _KitchenOrderContainerState();
}

class _KitchenOrderContainerState extends State<KitchenOrderContainer> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headers = [
      Header(flex: 1, text: 'Item', textAlign: TextAlign.left),
      Header(flex: 1, text: 'Qty', textAlign: TextAlign.center),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppMaterial(
            borderRadius: BorderRadius.zero,
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('22 hrs Ago'),
                  Text(
                    'Guest | Table 1',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //detail
          AnimatedSize(
            duration: const Duration(milliseconds: 100),
            alignment: Alignment.topCenter,
            child:
                isExpanded
                    ? Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        spacing: 12,
                        children: [
                          AppDivider(),
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(child: Text('Order No')),
                                    Text(': '),
                                    Expanded(child: Text('510')),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(child: Text('Bill No')),
                                    Text(': '),
                                    Expanded(child: Text('irish-202')),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          ListHeader(headers: headers),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: 5,
                            cacheExtent: 10,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 12,
                                ),
                                child: Column(
                                  spacing: 4,
                                  children: [
                                    Row(
                                      children: [
                                        CellColumn(flex: 1, text: 'text'),
                                        CellColumn(
                                          flex: 1,
                                          text: index.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    index != 4
                                        ? AppDivider()
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              );
                            },
                          ),
                          AppDivider(),
                        ],
                      ),
                    )
                    : SizedBox.shrink(),
          ),

          Container(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 12),
            width: double.infinity,
            child: AppButton(
              onPressed: () {},
              text: 'Process',
              backgroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
