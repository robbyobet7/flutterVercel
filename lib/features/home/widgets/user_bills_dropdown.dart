import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_popup_menu.dart';
import '../models/user_bill.dart';
import '../providers/selected_user_bill_provider.dart';

/// A reusable dropdown for selecting users with their respective bills.
/// This component can be used across different pages for consistency.
class UserBillsDropdown extends ConsumerWidget {
  /// Optional callback to be triggered when a user is selected
  final Function(UserBill)? onUserSelected;

  /// Optional decoration to customize the appearance
  final BoxDecoration? decoration;

  /// Optional height for the dropdown button
  final double height;

  const UserBillsDropdown({
    Key? key,
    this.onUserSelected,
    this.decoration,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedUser = ref.watch(selectedUserBillProvider);

    return AppPopupMenu<String>(
      items:
          UserBill.dummyUsers
              .map(
                (user) => AppPopupMenuItem<String>(
                  value: user.id,
                  text: '${user.name} (${user.openBills})',
                  textColor:
                      user.id == selectedUser.id
                          ? theme.colorScheme.primary
                          : null,
                ),
              )
              .toList(),
      onSelected: (String userId) {
        final user = UserBill.dummyUsers.firstWhere((u) => u.id == userId);

        // Update provider state
        ref.read(selectedUserBillProvider.notifier).selectUser(user);

        // Call the optional callback if provided
        if (onUserSelected != null) {
          onUserSelected!(user);
        }
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
            decoration ??
            BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.surfaceContainer),
              borderRadius: BorderRadius.circular(6),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      selectedUser.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.expand_more,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
