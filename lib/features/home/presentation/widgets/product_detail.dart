import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/providers/cart_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/models/cart_item.dart';

import 'package:rebill_flutter/features/home/presentation/widgets/product_option.dart';
import 'package:rebill_flutter/features/main_bill/constants/bill_constants.dart';
import 'package:rebill_flutter/features/main_bill/providers/main_bill_provider.dart';

class ProductDetail extends ConsumerStatefulWidget {
  const ProductDetail({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<ProductDetail> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  int _quantity = 1;

  // Store selected options and extras
  final Map<String, dynamic> _selectedOptions = {};
  final Set<String> _selectedExtras = {};

  @override
  void initState() {
    super.initState();
    // Initialize with 1 as default quantity
    _quantityController.text = _quantity.toString();
    _initializeDefaultOptions();
  }

  void _initializeDefaultOptions() {
    try {
      if (widget.product.option != null &&
          widget.product.option!.startsWith('[')) {
        final options = List<dynamic>.from(json.decode(widget.product.option!));

        for (final opt in options) {
          // Set default selection for required options
          if (opt['required'] == true &&
              opt['type'] == 'option' &&
              opt['options'] is List &&
              (opt['options'] as List).isNotEmpty) {
            _selectedOptions[opt['uid']] = (opt['options'] as List).first;
          }
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    // Check if we're at the maximum allowed quantity (based on available stock)
    if (!widget.product.hasInfiniteStock &&
        _quantity >= widget.product.availableStock) {
      // Don't allow increasing beyond available stock
      return;
    }

    setState(() {
      _quantity++;
      _quantityController.text = _quantity.toString();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _quantityController.text = _quantity.toString();
      });
    }
  }

  void _updateQuantityFromField() {
    final enteredValue = int.tryParse(_quantityController.text) ?? 0;
    if (enteredValue <= 0) {
      // Reset to 1 if invalid value entered
      setState(() {
        _quantity = 1;
        _quantityController.text = '1';
      });
      return;
    }

    // Check if entered value exceeds available stock
    if (!widget.product.hasInfiniteStock &&
        enteredValue > widget.product.availableStock) {
      setState(() {
        _quantity = widget.product.availableStock;
        _quantityController.text = _quantity.toString();
      });
      return;
    }

    setState(() {
      _quantity = enteredValue;
    });
  }

  // Method to handle option selection
  void selectOption(String optionId, dynamic choice) {
    setState(() {
      _selectedOptions[optionId] = choice;
    });
  }

  // Method to toggle extras
  void toggleExtra(String extraId) {
    setState(() {
      if (_selectedExtras.contains(extraId)) {
        _selectedExtras.remove(extraId);
      } else {
        _selectedExtras.add(extraId);
      }
    });
  }

  // Add the current product to cart
  void _addToCart() {
    try {
      // Convert product options to CartItemOption format if needed
      List<CartItemOption>? productOptions;

      if (_selectedOptions.isNotEmpty || _selectedExtras.isNotEmpty) {
        productOptions = [];

        // Add selected dropdown options
        _selectedOptions.forEach((optionId, value) {
          if (value is Map<String, dynamic>) {
            productOptions!.add(
              CartItemOption(
                optionName: value['group'] ?? 'Option',
                name: value['name'] ?? 'Unknown',
                type: 'option',
                price:
                    value['price'] != null
                        ? (value['price'] is int
                            ? (value['price'] as int).toDouble()
                            : (value['price'] as double))
                        : 0.0,
                purchPrice:
                    value['purchPrice'] != null
                        ? (value['purchPrice'] is int
                            ? (value['purchPrice'] as int).toDouble()
                            : (value['purchPrice'] as double))
                        : 0.0,
                relationItem: value['relation_item'],
              ),
            );
          }
        });

        // Add selected extras (complimentary items)
        _selectedExtras.forEach((extraId) {
          // Get the extra details from the product configuration
          try {
            final options = json.decode(widget.product.option ?? '[]') as List;
            for (var group in options) {
              if (group['type'] == 'extra') {
                final extras = group['options'] as List;
                for (var extra in extras) {
                  if (extra['uid'] == extraId) {
                    productOptions!.add(
                      CartItemOption(
                        name: extra['name'] ?? 'Extra',
                        type: 'complimentary',
                        price: 0.0,
                        purchPrice: 0.0,
                        productId: extra['product_id'],
                        productStock: extra['product_stock'],
                        productType: extra['product_type'],
                      ),
                    );
                    break;
                  }
                }
              }
            }
          } catch (e) {
            print('Error processing extras: $e');
          }
        });
      }

      ref
          .read(cartProvider.notifier)
          .addProductFromProduct(
            product: widget.product,
            quantity: _quantity,
            options: productOptions,
            productNotes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          );

      Navigator.pop(context);
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Widget _buildProductImage() {
    final theme = Theme.of(context);

    // Check if product has an image path
    final imagePath = widget.product.productImage;
    final hasValidImage =
        imagePath != null &&
        !imagePath.contains('noimage') &&
        imagePath.isNotEmpty;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          hasValidImage
              ? Image.network(
                imagePath.startsWith('/')
                    ? 'https://yourapi.com$imagePath'
                    : imagePath,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/product_placeholder.webp',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              )
              : Image.asset(
                'assets/images/product_placeholder.webp',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainBillComponent = ref.watch(mainBillProvider);
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        spacing: 12,
        children: [
          Expanded(
            child: Row(
              spacing: 12,
              children: [
                Expanded(flex: 2, child: _buildProductImage()),
                ProductOption(product: widget.product),
              ],
            ),
          ),
          Container(
            height: 40,
            child:
                mainBillComponent == MainBillComponent.defaultComponent
                    ? Center(
                      child: Text(
                        'Create new bill to add items',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 12,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            showLabel: false,
                            constraints: BoxConstraints(maxHeight: 40),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            controller: _notesController,
                            hintText: 'Notes',
                            labelText: 'Notes',
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            spacing: 12,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              Row(
                                spacing: 12,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: IconButton(
                                      onPressed: _decrementQuantity,
                                      icon: const Icon(Icons.remove),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    height: 40,
                                    child: AppTextField(
                                      showLabel: false,
                                      textAlign: TextAlign.center,
                                      controller: _quantityController,
                                      onChanged:
                                          (_) => _updateQuantityFromField(),
                                      keyboardType: TextInputType.number,
                                      hintText: 'Qty',
                                      labelText: 'Qty',
                                      constraints: BoxConstraints(
                                        maxWidth: 70,
                                        maxHeight: 40,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: IconButton(
                                      onPressed: _incrementQuantity,
                                      icon: const Icon(Icons.add),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: AppButton(
                                  height: 50,
                                  backgroundColor: theme.colorScheme.primary,
                                  textStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                  onPressed: _addToCart,
                                  text: '',
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Icon(
                                        Icons.add_shopping_cart,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      Text(
                                        'Add to Cart',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
