import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/customers.dart';
import 'package:rebill_flutter/core/providers/customer_provider.dart';
import 'package:rebill_flutter/core/providers/bill_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/features/home/providers/search_provider.dart';
import 'package:rebill_flutter/features/main-bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main-bill/presentations/widgets/add_customer_dialog.dart';
import 'package:rebill_flutter/features/main-bill/providers/main_bill_provider.dart';

// Provider for temporarily selected customer
final tempSelectedCustomerProvider = StateProvider.autoDispose<CustomerModel?>(
  (ref) => null,
);

class KnownIndividualDialog extends ConsumerStatefulWidget {
  const KnownIndividualDialog({super.key});

  @override
  ConsumerState<KnownIndividualDialog> createState() =>
      _KnownIndividualDialogState();
}

class _KnownIndividualDialogState extends ConsumerState<KnownIndividualDialog> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tempSelectedCustomer = ref.watch(tempSelectedCustomerProvider);
    final selectedCustomer = ref.watch(knownIndividualProvider);
    final isLightBackground =
        theme.colorScheme.surface.computeLuminance() > 0.5;
    final customers = ref.watch(customerProvider);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppSearchBar(
                  hintText: 'Search Customer...',
                  searchProvider: customerSearchQueryProvider,
                  onSearch: (value) {
                    ref.read(customerProvider.notifier).searchCustomers(value);
                    ref
                        .read(customerSearchQueryProvider.notifier)
                        .updateSearchQuery(value);
                  },
                  onClear: () {
                    ref.read(customerProvider.notifier).clearSearch();
                    ref
                        .read(customerSearchQueryProvider.notifier)
                        .clearSearch();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed:
                    _isRefreshing
                        ? null // Disable button while refreshing
                        : () async {
                          setState(() {
                            _isRefreshing = true;
                          });

                          ref
                              .read(tempSelectedCustomerProvider.notifier)
                              .state = null;
                          ref.read(customerProvider.notifier).clearSearch();
                          ref
                              .read(customerSearchQueryProvider.notifier)
                              .clearSearch();

                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          if (mounted) {
                            setState(() {
                              _isRefreshing = false;
                            });
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Refresh',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.refresh,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Email/Social',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Phone',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Affiliate',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      _isRefreshing
                          ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          )
                          : ListView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            cacheExtent: 100,
                            itemCount: customers.customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers.customers[index];
                              final isCurrentlySaved =
                                  selectedCustomer?.customerId ==
                                  customer.customerId;
                              final isNewlySelected =
                                  tempSelectedCustomer?.customerId ==
                                  customer.customerId;
                              final Color backgroundColor;
                              final Color textColor;
                              final Color borderColor;

                              if (isNewlySelected) {
                                backgroundColor =
                                    theme.colorScheme.primaryContainer;
                                textColor = theme.colorScheme.primary;
                                borderColor = theme.colorScheme.primary;
                              } else if (isCurrentlySaved) {
                                backgroundColor = theme.colorScheme.primary;
                                textColor = theme.colorScheme.onPrimary;
                                borderColor = Colors.transparent;
                              } else {
                                // State: Default
                                backgroundColor =
                                    index % 2 == 0
                                        ? theme.colorScheme.surfaceContainer
                                        : theme.colorScheme.surface;
                                textColor = theme.colorScheme.onSurface;
                                borderColor =
                                    index % 2 == 0
                                        ? Colors.transparent
                                        : theme.colorScheme.onSurface.withAlpha(
                                          20,
                                        );
                              }

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (isNewlySelected) {
                                        ref
                                            .read(
                                              tempSelectedCustomerProvider
                                                  .notifier,
                                            )
                                            .state = null;
                                      } else {
                                        ref
                                            .read(
                                              tempSelectedCustomerProvider
                                                  .notifier,
                                            )
                                            .state = customer;
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      height: 60,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: backgroundColor,
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              customer.customerName,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              customer.emailSocial ?? '',
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color: textColor,
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              customer.phone ?? '',
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color: textColor,
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              customer.affiliate ?? '',
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w400,
                                                    color: textColor,
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
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);

                        final newCustomer = await AppDialog.showCustom(
                          context,
                          content: const AddCustomerDialog(),
                          title: 'Add New Customer',
                          dialogType: DialogType.medium,
                        );

                        if (newCustomer != null &&
                            newCustomer is CustomerModel) {
                          ref
                              .read(knownIndividualProvider.notifier)
                              .setKnownIndividual(newCustomer);
                          ref
                              .read(customerTypeProvider.notifier)
                              .setCustomerType(CustomerType.knownIndividual);
                          // Update selected bill immediately so HomeBill shows the new name
                          ref
                              .read(billProvider.notifier)
                              .updateSelectedBillCustomer(
                                newCustomer.customerName,
                                newCustomer.customerId,
                                customerPhone: newCustomer.phone,
                              );
                          ref.read(customerExpandableProvider.notifier).state =
                              false;

                          navigator.pop();
                        }
                      },
                      text: 'Add New Customer',
                      backgroundColor: theme.colorScheme.surface,
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
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
                  children: [
                    AppButton(
                      onPressed: () {
                        ref.read(tempSelectedCustomerProvider.notifier).state =
                            null;
                        if (selectedCustomer == null) {
                          ref
                              .read(knownIndividualProvider.notifier)
                              .setKnownIndividual(null);
                        }
                        ref.read(customerProvider.notifier).clearSearch();
                        ref
                            .read(customerSearchQueryProvider.notifier)
                            .clearSearch();
                        Navigator.pop(context);
                      },
                      text: 'Cancel',
                      backgroundColor: theme.colorScheme.errorContainer,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                                // Live update selected bill's customer info so HomeBill reflects immediately
                                ref
                                    .read(billProvider.notifier)
                                    .updateSelectedBillCustomer(
                                      tempSelectedCustomer.customerName,
                                      tempSelectedCustomer.customerId,
                                      customerPhone: tempSelectedCustomer.phone,
                                    );
                                ref
                                    .read(customerExpandableProvider.notifier)
                                    .state = false;
                                Navigator.pop(context);
                                ref
                                    .read(customerProvider.notifier)
                                    .clearSearch();
                                ref
                                    .read(customerSearchQueryProvider.notifier)
                                    .clearSearch();
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
