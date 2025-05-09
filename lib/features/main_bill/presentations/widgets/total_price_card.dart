import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';

class TotalPriceCard extends ConsumerWidget {
  const TotalPriceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int roundUpToThousand(double value) {
      return ((value / 1000).ceil()) * 1000;
    }

    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final isClosed = ref.watch(billProvider.notifier).billStatus == 'closed';
    final total = cart.total;
    final totalRounded = roundUpToThousand(total);
    final numberFormat = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );
    return SizedBox(
      height: 50,
      child: AppButton(
        onPressed: () {},
        borderRadius: BorderRadius.circular(12),
        backgroundColor:
            isClosed ? theme.colorScheme.surface : theme.colorScheme.primary,
        disabled: isClosed,
        text: '',
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color:
                      isClosed
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total ',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isClosed
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'IDR ',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color:
                          isClosed
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: numberFormat.format(totalRounded),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isClosed
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
