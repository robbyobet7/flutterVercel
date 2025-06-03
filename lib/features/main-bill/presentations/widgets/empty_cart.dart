import 'package:flutter/material.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Icon(
            Icons.shopping_cart_rounded,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          Column(
            children: [
              Text('No Items in cart'),
              Text('Click product on your left to add to cart'),
            ],
          ),
        ],
      ),
    );
  }
}
