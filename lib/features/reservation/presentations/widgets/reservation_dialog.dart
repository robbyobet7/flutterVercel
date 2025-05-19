import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_search_bar.dart';
import 'package:rebill_flutter/core/widgets/list_header.dart';
import 'package:rebill_flutter/features/reservation/models/reservation.dart';
import 'package:rebill_flutter/features/reservation/presentations/widgets/add_reservation_dialog.dart';
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

    final headers = [
      Header(flex: 4, text: 'Name'),
      Header(flex: 4, text: 'Time'),
      Header(flex: 2, text: 'Duration'),
      Header(flex: 2, text: 'Headcount'),
      Header(flex: 2, text: 'Table'),
      Header(flex: 3, text: 'Remark'),
      Header(flex: 1, text: 'Action'),
    ];
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
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    AppDialog.showCustom(
                      context,
                      content: AddReservationDialog(),
                      title: 'Add New Reservation',
                      dialogType: DialogType.medium,
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  ListHeader(
                    headers: headers,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),

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
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      cacheExtent: 100,
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
              clipBehavior: Clip.hardEdge,
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
      padding: EdgeInsets.symmetric(horizontal: 24),
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.surfaceContainer,
            width: .5,
          ),
        ),
      ),
      child: SizedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.only(right: 12),
                child: Text(
                  reservation.name,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Time
            Expanded(
              flex: 4,
              child: Text(reservation.time, textAlign: TextAlign.left),
            ),
            // Duration
            Expanded(
              flex: 2,
              child: Text(
                '${reservation.duration} min',
                textAlign: TextAlign.left,
              ),
            ),
            // Headcount
            Expanded(
              flex: 2,
              child: Text(
                '${reservation.headcount}',
                textAlign: TextAlign.left,
              ),
            ),
            // Table
            Expanded(
              flex: 2,
              child: Text(
                reservation.tableName,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Remarks
            Expanded(
              flex: 3,
              child: Text(
                reservation.remarks,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Action
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Icon(
                      Icons.receipt,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Flexible(
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
