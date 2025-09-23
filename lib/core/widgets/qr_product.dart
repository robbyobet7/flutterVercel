// lib/core/widgets/simple_qr_dialog.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/table_dialog.dart';

class QRProduct extends StatelessWidget {
  final String? qrData;

  const QRProduct({super.key, this.qrData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String safeData =
        (qrData == null || qrData!.isEmpty)
            ? 'https://www.rebill-pos.com'
            : qrData!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code
            QrImageView(
              data: safeData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.transparent,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: theme.colorScheme.onSurface,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppDialog.showCustom(
                        context,
                        dialogType: DialogType.large,
                        title: 'Choose Table',
                        content: const TableDialog(tableType: TableType.qr),
                      );
                    },
                    text: 'Choose Table',
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    text: 'Show Menu',
                    backgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
