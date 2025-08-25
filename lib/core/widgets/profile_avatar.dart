import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? name;

  const ProfileAvatar({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ambil inisial dari nama, atau 'A' jika nama tidak ada
    final initials =
        (name?.isNotEmpty ?? false)
            ? name!
                .trim()
                .split(' ')
                .map((l) => l[0])
                .take(2)
                .join()
                .toUpperCase()
            : 'A';

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            initials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name ?? 'Admin', // <-- TAMPILKAN NAMA DI SINI
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Online',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }
}
