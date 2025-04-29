import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';

class CartSummary extends ConsumerWidget {
  const CartSummary({super.key, this.onCheckout});

  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Get cart state
    final cartState = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final serviceFee = ref.watch(cartServiceFeeProvider);
    final tax = ref.watch(cartTaxProvider);
    final discount = ref.watch(cartDiscountProvider);
    final total = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Price breakdown section
          _buildPriceSummaryItem(
            theme,
            'Subtotal',
            currencyFormatter.format(subtotal),
          ),

          // Always display service fee
          _buildPriceSummaryItem(
            theme,
            'Service Fee (${cartState.serviceFeePercentage}%)',
            currencyFormatter.format(serviceFee),
          ),

          // Always display tax
          _buildPriceSummaryItem(
            theme,
            'Tax (${cartState.taxPercentage}%)',
            currencyFormatter.format(tax),
          ),

          if (discount > 0)
            _buildPriceSummaryItem(
              theme,
              'Discount',
              '- ${currencyFormatter.format(discount)}',
              valueColor: theme.colorScheme.error,
            ),

          const Divider(height: 24),

          // Total section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currencyFormatter.format(total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Checkout button
          AppButton(
            text: 'Checkout ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
            backgroundColor: theme.colorScheme.primary,
            textStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            onPressed: itemCount > 0 ? onCheckout : null,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_checkout,
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Checkout ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryItem(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
