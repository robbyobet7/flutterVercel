import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/product_provider.dart';

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

                        // Check if this choice is selected
                        final selectedOption = productNotifier
                            .getSelectedOption(widget.productId, optionId);
                        final isSelected = productNotifier.isSameOption(
                          selectedOption,
                          choice,
                        );

                        // Debug print to see what's happening
                        print(
                          'Option $optionName: selected=$isSelected, selectedOption=$selectedOption, choice=$choice',
                        );

                        return GestureDetector(
                          onTap: () {
                            print('Tapped on option: $choiceName');
                            // First see if this is already selected
                            final selectedOption = productNotifier
                                .getSelectedOption(widget.productId, optionId);
                            final isThisSelected = productNotifier.isSameOption(
                              selectedOption,
                              choice,
                            );

                            print(
                              'Option tap: already selected? $isThisSelected, isRequired: $isRequired',
                            );

                            if (isThisSelected && !isRequired) {
                              // If already selected and not required, remove it
                              print('Removing option directly');
                              productNotifier.removeProductOption(
                                widget.productId,
                                optionId,
                              );
                            } else {
                              // Otherwise set it
                              print('Setting option directly');
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
                  const SizedBox(height: 12),
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    print('Toggling extra: $optionName');
                    final isSelected = productNotifier.isExtraSelected(
                      widget.productId,
                      optionId,
                    );

                    if (isSelected) {
                      print('Removing extra directly');
                      productNotifier.removeProductOption(
                        widget.productId,
                        optionId,
                      );
                    } else {
                      print('Adding extra directly');
                      productNotifier.setProductOption(
                        widget.productId,
                        optionId,
                        opt,
                        'extra',
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          isSelected
                              ? Border.all(
                                color: theme.colorScheme.tertiary.withOpacity(
                                  0.5,
                                ),
                                width: 1,
                              )
                              : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 18,
                          color:
                              isSelected
                                  ? theme.colorScheme.onTertiaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          optionName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
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
            // Handle complimentary items (just a display, not selectable)
            else if (optionType == 'complimentary') {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
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
                      Text(
                        'Complimentary: $optionName',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FREE',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
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
