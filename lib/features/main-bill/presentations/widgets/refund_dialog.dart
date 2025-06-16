import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/models/cart_item.dart';
import 'package:rebill_flutter/core/utils/extensions.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/header_column.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';
import 'package:rebill_flutter/core/widgets/outline_app_button.dart';

class RefundDialog extends StatefulWidget {
  const RefundDialog({
    super.key,
    required this.items,
    required this.totalPrice,
  });

  final List<CartItem> items;
  final double totalPrice;

  @override
  State<RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<RefundDialog> {
  bool isReturnToStock = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.totalPrice;
    final items = widget.items;

    List<Header> headers = [
      Header(flex: 2, text: 'Item'),
      Header(flex: 1, text: 'Amount', textAlign: TextAlign.center),
      Header(flex: 2, text: 'Amount to Return', textAlign: TextAlign.end),
    ];

    return Expanded(
      child: Column(
        children: [
          AppDivider(),
          SizedBox(height: 16),
          ListHeader(headers: headers),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder:
                    (context, index) => Column(
                      children: [
                        SizedBox(height: 4),
                        Row(
                          children: [
                            CellColumn(flex: 2, text: items[index].name),
                            CellColumn(
                              flex: 1,
                              text: items[index].quantity.toInt().toString(),
                              textAlign: TextAlign.center,
                            ),
                            CellColumn(
                              flex: 2,
                              text: '',
                              textAlign: TextAlign.end,
                              child: Row(
                                spacing: 8,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('1'),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        if (index != items.length - 1) AppDivider(),
                      ],
                    ),
              ),
            ),
          ),
          AppDivider(),

          SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                children: [
                  AppTextField(
                    controller: TextEditingController(),
                    maxLines: 2,
                    showLabel: false,
                    hintText: 'Add Notes',
                  ),
                  SizedBox(height: 16),
                  AppDivider(color: theme.colorScheme.onSurface),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total Value',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          total.toCurrency(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      LabelText(text: 'Return to Stock'),
                      SizedBox(
                        height: 45,
                        child: Row(
                          spacing: 8,
                          children: [
                            OutlineAppButton(
                              text: 'Yes',
                              isSelected: isReturnToStock,
                              onTap: () {
                                setState(() {
                                  isReturnToStock = true;
                                });
                              },
                            ),
                            OutlineAppButton(
                              text: 'No',
                              isSelected: !isReturnToStock,
                              onTap: () {
                                setState(() {
                                  isReturnToStock = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppDivider(),
          SizedBox(height: 16),
          SizedBox(
            height: 45,
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  text: 'Cancel',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  backgroundColor: theme.colorScheme.errorContainer,
                ),
                AppButton(
                  text: 'Refund',
                  onPressed: () {},
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
