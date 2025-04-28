import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';

class CustomerTypeCard extends ConsumerWidget {
  const CustomerTypeCard({
    super.key,
    required this.theme,
    required this.icon,
    required this.label,
    required this.type,
    required this.onTap,
  });

  final ThemeData theme;
  final IconData icon;
  final String label;
  final CustomerType type;
  final Function() onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCustomerType = ref.watch(customerTypeProvider);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(
            color:
                selectedCustomerType == type
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    selectedCustomerType == type
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      selectedCustomerType == type
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
