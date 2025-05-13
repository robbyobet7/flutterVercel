import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/theme/app_theme.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/features/reservation/models/reservation.dart';
import 'package:rebill_flutter/features/reservation/providers/reservation_provider.dart';

class ReservationDialog extends ConsumerStatefulWidget {
  const ReservationDialog({super.key});

  @override
  ConsumerState<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends ConsumerState<ReservationDialog> {
  @override
  void initState() {
    super.initState();
    // Load bills when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationProvider.notifier).fetchReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reservationState = ref.watch(reservationProvider);
    final reservations = reservationState.reservations;
    final isLoading = reservationState.isLoading;
    final error = reservationState.error;

    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: AppSearchBar(hintText: 'Search reservations...'),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  ReservationListHeader(),

                  // Reservation list view with error and loading states
                  Expanded(
                    child: _buildReservationList(
                      reservations,
                      isLoading,
                      error,
                      theme,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AppDivider(),
          SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationList(
    List<List<Reservation>> reservations,
    bool isLoading,
    String? error,
    ThemeData theme,
  ) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          'Error: $error',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      );
    }

    if (reservations.isEmpty) {
      return Center(child: Text('No reservations found.'));
    }

    return ListView.builder(
      itemCount: reservations.length,
      itemBuilder: (context, groupIndex) {
        final group = reservations[groupIndex];
        if (group.isEmpty) return SizedBox.shrink();

        // Get date stamp from the first reservation in the group
        final String dateHeader = _getDateHeader(group.first.stamp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header outside the container
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text(
                dateHeader,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            // Container with reservations
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.surfaceContainer),
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reservation items for this date
                  ...group
                      .map(
                        (reservation) =>
                            ReservationListItem(reservation: reservation),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDateHeader(String? stamp) {
    if (stamp == null) return "Upcoming";

    switch (stamp.toLowerCase()) {
      case "today":
        return "Today";
      case "tomorrow":
        return "Tomorrow";
      default:
        return stamp; // Use the actual date string
    }
  }
}

class ReservationListItem extends StatelessWidget {
  final Reservation reservation;

  const ReservationListItem({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(),
      child: Row(
        spacing: 12,
        children: [
          // Name
          Expanded(
            flex: 3,
            child: Text(
              reservation.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Time
          Expanded(
            flex: 2,
            child: Text(reservation.time, textAlign: TextAlign.center),
          ),
          // Duration
          Expanded(
            flex: 2,
            child: Text(
              '${reservation.duration} min',
              textAlign: TextAlign.center,
            ),
          ),
          // Headcount
          Expanded(
            flex: 2,
            child: Text(
              '${reservation.headcount}',
              textAlign: TextAlign.center,
            ),
          ),
          // Table
          Expanded(
            flex: 2,
            child: Text(
              reservation.tableName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Remarks
          Expanded(
            flex: 3,
            child: Text(
              reservation.remarks,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Action
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.more_vert, size: 18),
              onPressed: () {
                // Show actions menu for this reservation
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationListHeader extends StatelessWidget {
  const ReservationListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          HeaderColumn(flex: 3, text: 'Name'),
          HeaderColumn(flex: 2, text: 'Time'),
          HeaderColumn(flex: 2, text: 'Duration'),
          HeaderColumn(flex: 2, text: 'Headcount'),
          HeaderColumn(flex: 2, text: 'Table'),
          HeaderColumn(flex: 3, text: 'Remark'),
          HeaderColumn(flex: 1, text: 'Action'),
        ],
      ),
    );
  }
}

class HeaderColumn extends StatelessWidget {
  const HeaderColumn({super.key, required this.flex, required this.text});

  final int flex;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
