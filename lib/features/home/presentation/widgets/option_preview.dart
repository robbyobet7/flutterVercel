import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/widgets/app_checkbox.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import '../../../../core/providers/product_provider.dart';
import 'package:rebill_flutter/core/providers/products_providers.dart';

final complimentarySearchProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gunakan ref.read di dalam initState untuk sebuah aksi.
      ref
          .read(productProvider.notifier)
          .initializeProductOptions(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<dynamic> options = [];

    // 1. PISAHKAN antara Notifier (untuk aksi) dan State (untuk UI)
    // Gunakan .read untuk mengambil notifier, karena instance-nya tidak perlu ditonton.
    final productNotifier = ref.read(productProvider.notifier);
    // Gunakan .watch untuk menonton state, karena datanya bisa berubah dan UI perlu update.
    final productState = ref.watch(productProvider);

    try {
      options = List<dynamic>.from(
        (widget.option.startsWith('[')
            ? (widget.option.isNotEmpty ? json.decode(widget.option) : [])
            : []),
      );
    } catch (e) {
      return Container();
    }

    if (options.isEmpty) {
      return Container();
    }

    return Column(
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
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
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: choices.length,
                        itemBuilder: (context, index) {
                          final choice = choices[index];
                          final choiceName = choice['name'] ?? 'Option';
                          final choicePrice = choice['price'] ?? 0;

                          // 2. AMBIL DATA dari 'productState', bukan panggil method dari notifier
                          final selectedValue =
                              productState
                                  .productOptions[widget.productId]?[optionId]
                                  ?.value;
                          final isSelected = productNotifier.isSameOption(
                            selectedValue,
                            choice,
                          );

                          return GestureDetector(
                            onTap: () {
                              // AKSI tetap menggunakan notifier
                              productNotifier.toggleOption(
                                widget.productId,
                                optionId,
                                choice,
                              );
                            },
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                                          : Colors.transparent,
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
                                    ),
                                  ),
                                  if (choicePrice > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(choicePrice)}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
                ),
              );
            }
            // Handle extras (checkboxes or toggles)
            else if (optionType == 'extra') {
              final price = opt['price'] ?? 0;
              // 3. GUNAKAN STATE untuk mengecek, bukan notifier
              final isSelected =
                  productState.productOptions[widget.productId]?.containsKey(
                    optionId,
                  ) ??
                  false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () {
                    // AKSI tetap menggunakan notifier
                    productNotifier.toggleProductExtra(
                      widget.productId,
                      optionId,
                      opt,
                    );
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
                      children: [
                        AppCheckbox(
                          value: isSelected,
                          size: 16,
                          borderRadius: 4,
                        ),
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
                ),
              );
            }
            // Handle complimentary items
            else if (optionType == 'complimentary') {
              // 4. GUNAKAN STATE untuk mendapatkan data, bukan notifier
              final selectedOption =
                  productState
                      .productOptions[widget.productId]?[optionId]
                      ?.value;
              final hasSelectedProduct = selectedOption != null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () {
                    // Reset search provider saat dialog dibuka
                    ref.invalidate(complimentarySearchProvider);
                    AppDialog.showCustom(
                      context,
                      title: 'Select Complimentary',
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppSearchBar(
                            hintText: 'Search products...',
                            onSearch:
                                (value) =>
                                    ref
                                        .read(
                                          complimentarySearchProvider.notifier,
                                        )
                                        .state = value,
                            onClear:
                                () =>
                                    ref
                                        .read(
                                          complimentarySearchProvider.notifier,
                                        )
                                        .state = '',
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final productListAsync = ref.watch(
                                  allProductsProvider,
                                );
                                final searchQuery = ref.watch(
                                  complimentarySearchProvider,
                                );

                                return productListAsync.when(
                                  data: (products) {
                                    final filteredProducts =
                                        searchQuery.isEmpty
                                            ? products
                                            : products
                                                .where(
                                                  (p) =>
                                                      p.productsName
                                                          ?.toLowerCase()
                                                          .contains(
                                                            searchQuery
                                                                .toLowerCase(),
                                                          ) ??
                                                      false,
                                                )
                                                .toList();

                                    if (filteredProducts.isEmpty) {
                                      return const Center(
                                        child: Text('No products found'),
                                      );
                                    }

                                    return ListView.builder(
                                      itemCount: filteredProducts.length,
                                      itemBuilder: (context, index) {
                                        final product = filteredProducts[index];
                                        final isSelected =
                                            selectedOption != null &&
                                            selectedOption is Map &&
                                            selectedOption['id'] == product.id;

                                        return ListTile(
                                          title: Text(
                                            product.productsName ?? 'Unknown',
                                          ),
                                          selected: isSelected,
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
                                            productNotifier.setProductOption(
                                              widget.productId,
                                              optionId,
                                              {
                                                'id': product.id,
                                                'name': product.productsName,
                                                'price': product.productsPrice,
                                                'isComplimentary': true,
                                              },
                                              'option',
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      },
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
                              ? theme.colorScheme.primaryContainer.withAlpha(77)
                              : theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(127),
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
                          child: Text(
                            'Complimentary: ${selectedOption != null && selectedOption is Map ? (selectedOption["name"] ?? "Select Item") : "Select Item"}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
    );
  }
}
