import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, this.size = 24, this.value, this.borderRadius});

  final double size;
  final bool? value;
  final double? borderRadius;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppMaterial(
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
      ),
    );
  }
}
