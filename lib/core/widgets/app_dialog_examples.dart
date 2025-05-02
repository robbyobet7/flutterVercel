import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';

/// Example methods for using the AppDialog component
class AppDialogExamples {
  /// Example of showing a confirmation dialog
  static void showConfirmationExample(BuildContext context) {
    AppDialog.showConfirmation(
      context,
      title: 'Cancel Bill',
      message: 'Are you sure you want to cancel the current bill?',
      confirmText: 'Yes, Cancel',
      cancelText: 'No, Keep',
      icon: Icons.warning_amber_rounded,
    ).then((confirmed) {
      if (confirmed == true) {
        // User confirmed the action
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bill was cancelled')));
      }
    });
  }

  /// Example of showing an information dialog
  static void showInfoExample(BuildContext context) {
    AppDialog.showInfo(
      context,
      title: 'Payment Complete',
      message: 'The payment has been successfully processed.',
      buttonText: 'Great!',
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Example of showing an error dialog
  static void showErrorExample(BuildContext context) {
    AppDialog.showError(
      context,
      title: 'Connection Error',
      message:
          'Failed to connect to the server. Please check your internet connection and try again.',
    );
  }

  /// Example of showing a custom dialog
  static void showCustomExample(BuildContext context) {
    AppDialog.showCustom(
      context,
      title: 'Select Payment Method',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Credit Card'),
            onTap: () => Navigator.of(context).pop('credit_card'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Digital Wallet'),
            onTap: () => Navigator.of(context).pop('digital_wallet'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Cash'),
            onTap: () => Navigator.of(context).pop('cash'),
          ),
        ],
      ),
      primaryButtonText: 'Cancel',
      onPrimaryButtonPressed: () => Navigator.of(context).pop(),
    ).then((result) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected payment method: $result')),
        );
      }
    });
  }
}
