import 'package:flutter/material.dart';

class IncrementButton extends StatelessWidget {
  const IncrementButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: IconButton(
        onPressed: onTap,
        iconSize: 20,
        padding: EdgeInsets.all(0),
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
