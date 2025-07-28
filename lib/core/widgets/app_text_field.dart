import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;
  final bool? showLabel;
  final BoxConstraints? constraints;
  final bool? required;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  const AppTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.onTap,
    this.contentPadding,
    this.autofocus = false,
    this.showLabel = true,
    this.required = false,
    this.textAlign,
    this.constraints,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Create a widget tree that will dismiss keyboard when tapped outside
    return GestureDetector(
      onTap: () {
        // This will unfocus the current focus and dismiss the keyboard
        FocusScope.of(context).unfocus();
      },
      // Use behavior opaque to intercept all taps even on transparent areas
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          showLabel == true
              ? Column(
                children: [
                  Row(
                    children: [
                      Text(
                        labelText ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      if (required == true)
                        Text(
                          '*',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              )
              : const SizedBox.shrink(),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            textAlign: textAlign ?? TextAlign.start,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            readOnly: readOnly,
            focusNode: focusNode,
            maxLines: maxLines,
            minLines: minLines,
            textInputAction: textInputAction,
            onTap: onTap,
            style: textStyle ?? theme.textTheme.bodyMedium,
            autofocus: autofocus,
            decoration: InputDecoration(
              hintText: hintText,
              constraints:
                  constraints ??
                  (maxLines != 1 ? null : BoxConstraints(maxHeight: 45)),
              prefixIcon: prefix,
              suffixIcon: suffix,
              fillColor: theme.colorScheme.surfaceContainer,
              filled: true,
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
