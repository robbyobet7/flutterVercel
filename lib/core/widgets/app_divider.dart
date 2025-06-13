import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 1,
      color: color ?? theme.colorScheme.surfaceContainer,
    );
  }
}
