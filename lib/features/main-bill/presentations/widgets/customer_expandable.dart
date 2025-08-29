import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/customer_type_card.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

class CustomerExpandable extends ConsumerWidget {
  const CustomerExpandable({
    super.key,
    required this.customerTypes,
    required this.disabled,
  });

  final List<Map<String, Object>> customerTypes;
  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCustomerType = ref.watch(customerTypeProvider);
    final selectedCustomer = ref.watch(knownIndividualProvider);

    final isExpanded = ref.watch(customerExpandableProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (!disabled) {
                final currentState = ref.read(customerExpandableProvider);
                ref.read(customerExpandableProvider.notifier).state =
                    !currentState;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.surfaceContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedCustomerType == CustomerType.guest
                            ? 'Guest'
                            : selectedCustomer != null
                            ? selectedCustomer.customerName
                            : 'Known Individual',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isExpanded ? 112 : 0,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      customerTypes
                          .map(
                            (customerType) => CustomerTypeCard(
                              disabled: disabled,
                              theme: theme,
                              icon: customerType['icon'] as IconData,
                              label: customerType['label'] as String,
                              type:
                                  customerType['label'] == 'Guest'
                                      ? CustomerType.guest
                                      : CustomerType.knownIndividual,
                              onTap: customerType['onTap'] as Function(),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
