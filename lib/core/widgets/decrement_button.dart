import 'package:flutter/material.dart';

class DecrementButton extends StatelessWidget {
  const DecrementButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: IconButton(
        iconSize: 20,
        padding: EdgeInsets.all(0),
        onPressed: () {},
        icon: const Icon(Icons.remove),
      ),
    );
  }
}
