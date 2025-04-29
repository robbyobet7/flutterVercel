import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:intl/intl.dart';

class OptionPreview extends StatefulWidget {
  const OptionPreview({super.key, required this.option});

  final String option;

  @override
  State<OptionPreview> createState() => _OptionPreviewState();
}

class _OptionPreviewState extends State<OptionPreview> {
  // Selected options for each option group
  final Map<String, dynamic> _selectedOptions = {};
  // Toggled extras
  final Set<String> _selectedExtras = {};

  @override
  void initState() {
    super.initState();
    _parseAndInitializeOptions();
  }

  void _parseAndInitializeOptions() {
    try {
      if (!widget.option.startsWith('[')) return;

      final options = json.decode(widget.option) as List;

      // Set default values for required options
      for (final opt in options) {
        // Check if this is a required option and has choices
        if (opt['required'] == true &&
            opt['type'] == 'option' &&
            opt['options'] is List &&
            (opt['options'] as List).isNotEmpty) {
          _selectedOptions[opt['uid']] = (opt['options'] as List).first;
        }
      }
    } catch (e) {
      // Just ignore parsing errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<dynamic> options = [];

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
                        final isSelected = _selectedOptions[optionId] == choice;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOptions[optionId] = choice;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary.withOpacity(
                                        0.1,
                                      )
                                      : theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surfaceVariant,
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
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
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
              final bool isSelected = _selectedExtras.contains(optionId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedExtras.remove(optionId);
                      } else {
                        _selectedExtras.add(optionId);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.tertiaryContainer
                              : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
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
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Complimentary: $optionName',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
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
