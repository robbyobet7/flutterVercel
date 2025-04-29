import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/models/product.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';

import 'package:rebill_flutter/features/home/presentation/widgets/product_option.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Initialize with 1 as default quantity
    _quantityController.text = _quantity.toString();
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
                // If it's a relative path, prepend your base URL
                imagePath.startsWith('/')
                    ? 'https://yourapi.com$imagePath'
                    : imagePath,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to placeholder on error
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
            child: Row(
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
                              onChanged: (_) => _updateQuantityFromField(),
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
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                          onPressed: () {
                            // Add to cart logic would go here
                            Navigator.pop(context);
                          },

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
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
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
