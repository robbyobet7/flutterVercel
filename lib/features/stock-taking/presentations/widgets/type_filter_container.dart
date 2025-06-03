import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';

class TypeFilterContainer extends StatelessWidget {
  const TypeFilterContainer({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  final String type;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppMaterial(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : null,
          border: Border.all(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
