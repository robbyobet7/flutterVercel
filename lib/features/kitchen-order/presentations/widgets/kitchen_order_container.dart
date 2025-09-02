import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/kitchen_order.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';
import 'package:rebill_flutter/features/kitchen-order/providers/kitchen_order_provider.dart';

enum KitchenOrderType { submitted, processing, finished }

class KitchenOrderContainer extends ConsumerStatefulWidget {
  final KitchenOrder order;
  final KitchenOrderType type;
  const KitchenOrderContainer({
    super.key,
    required this.order,
    required this.type,
  });

  @override
  ConsumerState<KitchenOrderContainer> createState() =>
      _KitchenOrderContainerState();
}

class _KitchenOrderContainerState extends ConsumerState<KitchenOrderContainer> {
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
    final type = widget.type;
    final backgroundColor =
        type == KitchenOrderType.submitted
            ? theme.colorScheme.errorContainer
            : type == KitchenOrderType.processing
            ? AppTheme.warningContainer
            : AppTheme.successContainer;

    final borderColor =
        type == KitchenOrderType.submitted
            ? theme.colorScheme.error
            : type == KitchenOrderType.processing
            ? AppTheme.warning
            : AppTheme.success;

    final headers = [
      Header(flex: 1, text: 'Item', textAlign: TextAlign.left),
      Header(flex: 1, text: 'Qty', textAlign: TextAlign.center),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppMaterial(
            borderRadius:
                type == KitchenOrderType.finished
                    ? isExpanded
                        ? BorderRadius.only(
                          topLeft: Radius.circular(11),
                          topRight: Radius.circular(11),
                        )
                        : BorderRadius.circular(11)
                    : BorderRadius.only(
                      topLeft: Radius.circular(11),
                      topRight: Radius.circular(11),
                    ),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: backgroundColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTimeAgo(order.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${order.customer} | ${order.table}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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

                                    //options
                                    if (item.options != null &&
                                        item.options!.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            item.options!.map((option) {
                                              return Row(
                                                children: [
                                                  Text(
                                                    '• ${option.optionName}: ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    option.name,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),

                                    //notes
                                    if (item.productNotes != null &&
                                        item.productNotes!.isNotEmpty)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '• Notes: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            item.productNotes!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
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

          if (type == KitchenOrderType.submitted ||
              type == KitchenOrderType.processing)
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 10,
                top: 12,
              ),
              width: double.infinity,
              child: Row(
                children: [
                  if (type == KitchenOrderType.processing)
                    Expanded(
                      child: AppButton(
                        onPressed: () {
                          ref
                              .read(kitchenOrderNotifierProvider.notifier)
                              .updateKitchenOrderStatus(
                                order.ordersId,
                                'submitted',
                              );
                        },
                        text: 'Cancel',
                        backgroundColor: theme.colorScheme.errorContainer,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  if (type == KitchenOrderType.processing)
                    const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      onPressed: () {
                        final nextStatus =
                            type == KitchenOrderType.submitted
                                ? 'processing'
                                : 'finished';

                        ref
                            .read(kitchenOrderNotifierProvider.notifier)
                            .updateKitchenOrderStatus(
                              order.ordersId,
                              nextStatus,
                            );
                      },
                      text:
                          type == KitchenOrderType.submitted
                              ? 'Process'
                              : 'Finish',
                      backgroundColor: theme.colorScheme.primary,
                      textStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (type == KitchenOrderType.finished)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              width: double.infinity,
              child: AppButton(
                onPressed: () {
                  ref
                      .read(kitchenOrderNotifierProvider.notifier)
                      .updateKitchenOrderStatus(order.ordersId, 'processing');
                },
                text: 'Re-Process',
                backgroundColor: theme.colorScheme.primary,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
