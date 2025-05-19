import 'package:flutter/material.dart';

class TypeFilterContainer extends StatelessWidget {
  const TypeFilterContainer({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Text(type)),
    );
  }
}
