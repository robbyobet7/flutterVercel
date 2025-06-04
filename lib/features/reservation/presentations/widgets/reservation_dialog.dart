import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
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
      Header(flex: 4, textAlign: TextAlign.left, text: 'Name'),
      Header(flex: 2, textAlign: TextAlign.center, text: 'Time'),
      Header(flex: 2, textAlign: TextAlign.center, text: 'Duration'),
      Header(flex: 2, textAlign: TextAlign.center, text: 'Headcount'),
      Header(flex: 2, textAlign: TextAlign.center, text: 'Table'),
      Header(flex: 3, textAlign: TextAlign.center, text: 'Remark'),
      Header(flex: 1, textAlign: TextAlign.center, text: 'Action'),
    ];
    return Column(
      children: [
        Container(
          height: 40,
          width: double.infinity,
          child: Row(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: AppSearchBar(hintText: 'Search reservations...')),
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
      ],
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

  String _formatTimeDisplay(String time) {
    // Check if the time string contains a date with format like "20 May 2025 14:04"
    final RegExp dateTimePattern = RegExp(
      r'^\d{1,2}\s+[A-Za-z]+\s+\d{4}\s+\d{1,2}:\d{2}$',
    );

    if (dateTimePattern.hasMatch(time)) {
      try {
        // Parse the date using intl package for more robust parsing
        final parsedDate = DateFormat('d MMMM yyyy HH:mm').parse(time);
        return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
      } catch (e) {
        // If parsing fails, return the original string
        return time;
      }
    }

    // If it's just a time or doesn't match the pattern, return it as is
    return time;
  }

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
              flex: 2,
              child: Text(
                _formatTimeDisplay(reservation.time),
                textAlign: TextAlign.center,
              ),
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
