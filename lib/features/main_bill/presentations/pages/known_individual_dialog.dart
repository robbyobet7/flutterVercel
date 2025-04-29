import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main_bill/models/customer.dart';
import 'package:rebill_flutter/features/main_bill/presentations/widgets/add_customer_dialog.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';

// Provider for temporarily selected customer
final tempSelectedCustomerProvider = StateProvider<Customer?>((ref) => null);

class KnownIndividualDialog extends ConsumerWidget {
  const KnownIndividualDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tempSelectedCustomer = ref.watch(tempSelectedCustomerProvider);
    final isLightBackground =
        theme.colorScheme.surface.computeLuminance() > 0.5;
    return Expanded(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchBar(hintText: 'Search Customer...'),
          Expanded(
            child: Column(
              children: [
                // Table header
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Email/Social',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Phone',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Affiliate',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table body
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    cacheExtent: 100,
                    itemCount: 20, // Number of dummy items
                    itemBuilder: (context, index) {
                      // Get customer data
                      final customer =
                          Customer.getDummyCustomers()[index %
                              Customer.getDummyCustomers().length];

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(tempSelectedCustomerProvider.notifier)
                                  .state = customer;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color:
                                    tempSelectedCustomer?.id == customer.id
                                        ? theme.colorScheme.primary
                                        : index % 2 == 0
                                        ? theme.colorScheme.surfaceContainer
                                        : theme.colorScheme.surface,
                                border: Border.all(
                                  color:
                                      index % 2 == 0
                                          ? Colors.transparent
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      customer.name,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                tempSelectedCustomer?.id ==
                                                        customer.id
                                                    ? Colors.white
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      customer.email,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                tempSelectedCustomer?.id ==
                                                        customer.id
                                                    ? Colors.white
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      customer.phone,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                tempSelectedCustomer?.id ==
                                                        customer.id
                                                    ? Colors.white
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      customer.affiliate,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                tempSelectedCustomer?.id ==
                                                        customer.id
                                                    ? Colors.white
                                                    : theme
                                                        .colorScheme
                                                        .onSurface,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    AppButton(
                      onPressed: () {
                        Navigator.pop(context);
                        AppDialog.showCustom(
                          context,
                          content: AddCustomerDialog(),
                          title: 'Add New Customer',
                          width: MediaQuery.of(context).size.width * 0.5,
                        );
                      },
                      text: 'Add New Customer',
                      backgroundColor: theme.colorScheme.surface,
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    AppButton(
                      onPressed: () {},
                      text: 'Edit',
                      disabled: tempSelectedCustomer == null,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color:
                            tempSelectedCustomer == null
                                ? isLightBackground
                                    ? Colors.white
                                    : Colors.black
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 12,
                  children: [
                    AppButton(
                      onPressed: () {
                        ref.read(tempSelectedCustomerProvider.notifier).state =
                            null;
                        ref
                            .read(knownIndividualProvider.notifier)
                            .setKnownIndividual(null);
                        Navigator.pop(context);
                      },
                      text: 'Cancel',
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    AppButton(
                      onPressed:
                          tempSelectedCustomer == null
                              ? null
                              : () {
                                ref
                                    .read(customerTypeProvider.notifier)
                                    .setCustomerType(
                                      CustomerType.knownIndividual,
                                    );
                                ref
                                    .read(knownIndividualProvider.notifier)
                                    .setKnownIndividual(tempSelectedCustomer);
                                Navigator.pop(context);
                              },
                      text: 'Select',
                      backgroundColor: theme.colorScheme.primary,
                      disabled: tempSelectedCustomer == null,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
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
