import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  const LabelText({super.key, required this.text});

  final String text;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(127),
            ),
          ),
        ],
      ),
    );
  }
}
