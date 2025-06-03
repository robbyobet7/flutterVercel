import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/widgets/app_checkbox.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';

import '../../../../core/providers/product_provider.dart';
import '../../../../core/providers/products_providers.dart';

class OptionPreview extends ConsumerStatefulWidget {
  const OptionPreview({
    super.key,
    required this.option,
    required this.productId,
  });

  final String option;
  final int productId;

  @override
  ConsumerState<OptionPreview> createState() => _OptionPreviewState();
}

class _OptionPreviewState extends ConsumerState<OptionPreview> {
  @override
  void initState() {
    super.initState();
    // Initialize options when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productProvider.notifier)
          .initializeProductOptions(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<dynamic> options = [];

    // Get the product provider
    final productNotifier = ref.watch(productProvider.notifier);

    try {
      // Try to parse the option string as JSON
      options = List<dynamic>.from(
        (widget.option.startsWith('[')
            ? (widget.option.isNotEmpty ? json.decode(widget.option) : [])
            : []),
      );
    } catch (e) {
      // If parsing fails, return an empty container
      return Container();
    }

    if (options.isEmpty) {
      return Container();
    }

    // Build the option selectors for each option type
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          options.map((opt) {
            final String optionName = opt['name'] ?? 'Option';
            final String optionType = opt['type'] ?? 'option';
            final String optionId = opt['uid'] ?? '';
            final bool isRequired = opt['required'] == true;

            // Handle option type (dropdown options)
            if (optionType == 'option' && opt['options'] is List) {
              final List<dynamic> choices = opt['options'];
              if (choices.isEmpty) return const SizedBox.shrink();

              return Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            optionName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (isRequired)
                            Text(
                              '*',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: choices.length,
                      itemBuilder: (context, index) {
                        final choice = choices[index];
                        final choiceName = choice['name'] ?? 'Option';
                        final choicePrice = choice['price'] ?? 0;

                        // Check if this choice is selected
                        final selectedOption = productNotifier
                            .getSelectedOption(widget.productId, optionId);
                        final isSelected = productNotifier.isSameOption(
                          selectedOption,
                          choice,
                        );

                        return GestureDetector(
                          onTap: () {
                            // First see if this is already selected
                            final selectedOption = productNotifier
                                .getSelectedOption(widget.productId, optionId);
                            final isThisSelected = productNotifier.isSameOption(
                              selectedOption,
                              choice,
                            );

                            if (isThisSelected && !isRequired) {
                              // If already selected and not required, remove it
                              productNotifier.removeProductOption(
                                widget.productId,
                                optionId,
                              );
                            } else {
                              // Otherwise set it
                              productNotifier.setProductOption(
                                widget.productId,
                                optionId,
                                choice,
                                'option',
                              );
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceContainer,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  choiceName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        isSelected
                                            ? theme.colorScheme.primary
                                            : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                if (choicePrice > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(choicePrice)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          isSelected
                                              ? theme.colorScheme.primary
                                              : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            // Handle extras (checkboxes or toggles)
            else if (optionType == 'extra') {
              final price = opt['price'] ?? 0;
              final bool isSelected = productNotifier.isExtraSelected(
                widget.productId,
                optionId,
              );

              return GestureDetector(
                onTap: () {
                  final isSelected = productNotifier.isExtraSelected(
                    widget.productId,
                    optionId,
                  );

                  if (isSelected) {
                    productNotifier.removeProductOption(
                      widget.productId,
                      optionId,
                    );
                  } else {
                    productNotifier.setProductOption(
                      widget.productId,
                      optionId,
                      opt,
                      'option',
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppCheckbox(value: isSelected, size: 16, borderRadius: 4),
                      const SizedBox(width: 8),
                      Text(
                        optionName,
                        style: theme.textTheme.bodyMedium?.copyWith(),
                      ),
                      const Spacer(),
                      if (price > 0)
                        Text(
                          '+${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(price)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
            // Handle complimentary items (just a display, not selectable)
            else if (optionType == 'complimentary') {
              // Check if a complimentary product is already selected
              final selectedOption = productNotifier.getSelectedOption(
                widget.productId,
                optionId,
              );
              final hasSelectedProduct = selectedOption != null;

              return GestureDetector(
                onTap: () {
                  AppDialog.showCustom(
                    context,
                    title: 'Select Complimentary',
                    content: Expanded(
                      child: Column(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSearchBar(hintText: 'Search products...'),
                          // Product list
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                // Get all products
                                final productList = ref.watch(
                                  availableProductsProvider,
                                );
                                // Get currently selected product for this option
                                final selectedOption = ref
                                    .watch(productProvider.notifier)
                                    .getSelectedOption(
                                      widget.productId,
                                      optionId,
                                    );

                                return productList.when(
                                  data: (products) {
                                    // Filter products based on search
                                    final searchText = '';
                                    final filteredProducts =
                                        products
                                            .where(
                                              (product) =>
                                                  product.productsName
                                                      ?.toLowerCase()
                                                      .contains(searchText) ??
                                                  false,
                                            )
                                            .toList();

                                    if (filteredProducts.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text('No products found'),
                                        ),
                                      );
                                    }

                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (selectedOption != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16.0,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                // Remove product selection
                                                ref
                                                    .read(
                                                      productProvider.notifier,
                                                    )
                                                    .removeProductOption(
                                                      widget.productId,
                                                      optionId,
                                                    );
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .errorContainer
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete_outline,
                                                      size: 16,
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .error,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Clear selection',
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color:
                                                                theme
                                                                    .colorScheme
                                                                    .error,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: filteredProducts.length,
                                            itemBuilder: (context, index) {
                                              final product =
                                                  filteredProducts[index];
                                              // Check if this product is selected
                                              final isSelected =
                                                  selectedOption != null &&
                                                  selectedOption['id'] ==
                                                      product.id;

                                              return ListTile(
                                                title: Text(
                                                  product.productsName ??
                                                      'Unknown',
                                                  style:
                                                      isSelected
                                                          ? TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                theme
                                                                    .colorScheme
                                                                    .primary,
                                                          )
                                                          : null,
                                                ),
                                                subtitle: Text(
                                                  NumberFormat.currency(
                                                    locale: 'id',
                                                    symbol: 'Rp',
                                                    decimalDigits: 0,
                                                  ).format(
                                                    product.productsPrice ?? 0,
                                                  ),
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                                trailing:
                                                    isSelected
                                                        ? Icon(
                                                          Icons.check_circle,
                                                          color:
                                                              theme
                                                                  .colorScheme
                                                                  .primary,
                                                        )
                                                        : null,
                                                onTap: () {
                                                  // Set product as complimentary option
                                                  ref
                                                      .read(
                                                        productProvider
                                                            .notifier,
                                                      )
                                                      .setProductOption(
                                                        widget.productId,
                                                        optionId,
                                                        {
                                                          'id': product.id,
                                                          'name':
                                                              product
                                                                  .productsName,
                                                          'price':
                                                              product
                                                                  .productsPrice,
                                                          'isComplimentary':
                                                              true,
                                                        },
                                                        'option',
                                                      );
                                                  Navigator.of(context).pop();
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  loading:
                                      () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  error:
                                      (_, __) => const Center(
                                        child: Text('Error loading products'),
                                      ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    dialogType: DialogType.medium,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color:
                        hasSelectedProduct
                            ? theme.colorScheme.primaryContainer.withOpacity(
                              0.3,
                            )
                            : theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complimentary: ${selectedOption != null && selectedOption is Map ? (selectedOption["name"] ?? "Select Item") : "Select Item"}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (hasSelectedProduct &&
                                selectedOption['name'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'FREE',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    if (selectedOption['price'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp',
                                            decimalDigits: 0,
                                          ).format(selectedOption['price']),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.7),
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              );
            }
            // Other option types can be implemented similarly

            return const SizedBox.shrink();
          }).toList(),
    );
  }
}
