import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/customer_type_card.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';

class CustomerExpandable extends ConsumerStatefulWidget {
  const CustomerExpandable({
    super.key,
    required this.customerTypes,
    required this.theme,
  });

  final List<Map<String, Object>> customerTypes;
  final ThemeData theme;

  @override
  ConsumerState<CustomerExpandable> createState() => _CustomerExpandableState();
}

class _CustomerExpandableState extends ConsumerState<CustomerExpandable> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedCustomerType = ref.watch(customerTypeProvider);
    final selectedCustomer = ref.watch(knownIndividualProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // Header with expand/collapse functionality
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: widget.theme.colorScheme.surfaceContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        color: widget.theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedCustomerType == CustomerType.guest
                            ? 'Guest'
                            : selectedCustomer != null
                            ? selectedCustomer.name
                            : 'Known Individual',
                        style: widget.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
          // Simple animation for expanding/collapsing
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? 112 : 0,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  spacing: 12,
                  children:
                      widget.customerTypes
                          .map(
                            (customerType) => CustomerTypeCard(
                              theme: widget.theme,
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
