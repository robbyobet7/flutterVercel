import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/models/kitchen_order.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';

class KitchenOrderContainer extends StatefulWidget {
  final KitchenOrder order;
  const KitchenOrderContainer({super.key, required this.order});

  @override
  State<KitchenOrderContainer> createState() => _KitchenOrderContainerState();
}

class _KitchenOrderContainerState extends State<KitchenOrderContainer> {
  bool isExpanded = false;

  String _getTimeAgo(DateTime orderTime) {
    final now = DateTime.now();
    final difference = now.difference(orderTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hrs ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} mins ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;

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
                  Text(_getTimeAgo(order.createdAt)),
                  Text(
                    '${order.customer} | ${order.table}',
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
                                    Expanded(
                                      child: Text(order.ordersId.toString()),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(child: Text('Bill No')),
                                    Text(': '),
                                    Expanded(child: Text(order.cBillId)),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          ListHeader(headers: headers),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: order.listorders.length,
                            cacheExtent: 10,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = order.listorders[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                child: Column(
                                  spacing: 8,
                                  children: [
                                    Row(
                                      children: [
                                        CellColumn(flex: 1, text: item.name),
                                        CellColumn(
                                          flex: 1,
                                          text: item.quantity.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    AppDivider(),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (order.notes != null && order.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Notes:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(order.notes!),
                                  ],
                                ),
                              ),
                            ),
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
