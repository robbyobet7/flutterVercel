import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.icon,
  });

  final String text;
  final VoidCallback onTap;
  final bool isSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: AppMaterial(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: icon != null ? null : 45,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary),
            color:
                isSelected
                    ? theme.colorScheme.primaryContainer
                    : Colors.transparent,
          ),
          child: Column(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, size: 24, color: theme.colorScheme.primary),
              Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                  fontWeight: icon != null ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
