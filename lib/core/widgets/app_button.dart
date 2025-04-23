import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double elevation;
  final TextStyle? textStyle;
  final String text;
  const AppButton({
    super.key,
    required this.onPressed,
    this.child,
    this.backgroundColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.elevation = 0,
    this.textStyle,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainer,
        elevation: elevation,
        fixedSize: Size(width ?? 120, height ?? double.infinity),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      child:
          child ??
          Text(
            text,
            style:
                textStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
          ),
    );
  }
}
