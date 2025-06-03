import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';

class ActionsRow extends StatelessWidget {
  const ActionsRow({super.key, required this.tableType});

  final TableType tableType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment:
            tableType == TableType.nav
                ? MainAxisAlignment.end
                : MainAxisAlignment.spaceBetween,
        children: [
          if (tableType != TableType.nav)
            Row(
              spacing: 12,
              children: [AppButton(onPressed: () {}, text: 'No Table')],
            ),
          Row(
            spacing: 12,
            children: [
              AppButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'Cancel',
                backgroundColor: theme.colorScheme.errorContainer,
                textStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              if (tableType != TableType.nav)
                AppButton(
                  onPressed: () {},
                  text: 'Submit',
                  backgroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
