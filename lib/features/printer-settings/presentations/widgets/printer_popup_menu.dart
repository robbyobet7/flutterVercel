import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_popup_menu.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';

class PrinterPopupMenu extends StatelessWidget {
  const PrinterPopupMenu({
    super.key,
    required this.label,
    required this.items,
    this.leading,
    this.hintText,
  });

  final String label;
  final List<AppPopupMenuItem<String>> items;
  final Widget? leading;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        LabelText(text: label),
        AppPopupMenu(
          onSelected: (value) {},
          items: items,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            width: double.infinity,
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.surfaceContainer),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    leading != null
                        ? Row(children: [leading!, SizedBox(width: 12)])
                        : SizedBox.shrink(),
                    Text(hintText ?? 'Select'),
                  ],
                ),
                Icon(Icons.arrow_drop_down_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
