import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';

class OutlineAppButton extends StatelessWidget {
  const OutlineAppButton({
    super.key,
    required this.text,
    required this.isSelected,
    this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: AppMaterial(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? theme.colorScheme.primaryContainer : null,
          ),
          child: Center(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
