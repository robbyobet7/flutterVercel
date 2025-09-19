import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_material.dart';

class AppCheckbox extends StatefulWidget {
  const AppCheckbox({
    super.key,
    this.size = 24,
    this.value,
    this.onChanged,
    this.borderRadius,
  });

  final double size;
  final bool? value; // kalau null -> pakai state internal
  final ValueChanged<bool>? onChanged; // opsional
  final double? borderRadius;

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  bool _internalValue = false;

  bool get _effectiveValue => widget.value ?? _internalValue;

  void _toggle() {
    final newValue = !_effectiveValue;
    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    } else {
      setState(() {
        _internalValue = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppMaterial(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
      child: InkWell(
        onTap: _toggle,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            color: _effectiveValue ? theme.colorScheme.primary : null,
          ),
          child:
              _effectiveValue
                  ? Icon(
                    Icons.check,
                    size: widget.size * 0.7,
                    color: theme.colorScheme.onPrimary,
                  )
                  : null,
        ),
      ),
    );
  }
}
