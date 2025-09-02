import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final double? width;
  final bool? disabled;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double elevation;
  final TextStyle? textStyle;
  final String text;
  final TextAlign? textAlign;
  final BorderSide? borderSide;
  final Color? disabledColor;
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
    this.disabled = false,
    this.borderSide,
    this.textAlign,
    this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: disabled == true ? null : onPressed,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: disabledColor ?? theme.disabledColor,
        animationDuration: const Duration(milliseconds: 200),
        backgroundColor:
            disabled == true
                ? theme.colorScheme.onSurface.withAlpha(127)
                : backgroundColor ?? theme.colorScheme.surfaceContainer,
        elevation: elevation,
        fixedSize: Size(width ?? double.infinity, height ?? double.infinity),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          side: borderSide ?? BorderSide.none,
        ),
      ),
      child:
          child ??
          Text(
            text,
            textAlign: textAlign ?? TextAlign.center,
            style:
                textStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
          ),
    );
  }
}
