import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/core/providers/table_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_dialog.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/features/reservation/presentations/widgets/reservation_dialog.dart';

class AddReservationDialog extends StatelessWidget {
  const AddReservationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDivider(),
          AddReservationContent(),
          Column(
            spacing: 16,
            children: [
              AppDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    onPressed:
                        () => {
                          Navigator.pop(context),
                          AppDialog.showCustom(
                            context,
                            dialogType: DialogType.large,
                            title: 'Reservations',
                            content: const ReservationDialog(),
                          ),
                        },
                    text: 'Back to Reservations',
                    backgroundColor: theme.colorScheme.errorContainer,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    onPressed: () {},
                    text: 'Save Reservation',
                    backgroundColor: theme.colorScheme.primary,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddReservationContent extends ConsumerStatefulWidget {
  const AddReservationContent({super.key});

  @override
  ConsumerState<AddReservationContent> createState() =>
      _AddReservationContentState();
}

class _AddReservationContentState extends ConsumerState<AddReservationContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _nameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const duration = ['30 mins', '60 mins', '90 mins', '120 mins', 'Until End'];
    const spacing = 16.0;
    final theme = Theme.of(context);

    final tables = ref.watch(tableProvider).tables;
    print(tables);

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: spacing,
            children: [
              SizedBox.shrink(), //spacer only
              AppTextField(
                controller: _nameController,
                labelText: 'Name',
                hintText: 'Enter customer name',
              ),
              Row(
                spacing: 30,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        LabelText(text: 'Head Count'),
                        SizedBox(
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 12,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.remove),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: AppTextField(
                                    showLabel: false,
                                    textAlign: TextAlign.center,
                                    controller: TextEditingController(),
                                    onChanged: (_) {},
                                    keyboardType: TextInputType.number,
                                    hintText: 'Qty',
                                    labelText: 'Qty',
                                    constraints: BoxConstraints(maxHeight: 50),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.add,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _nameController,
                      labelText: 'Date & Time',
                      hintText: 'dd/mm/yyyy',
                      suffix: Icon(
                        Icons.calendar_month,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  LabelText(text: 'Duration'),
                  Row(
                    spacing: 12,
                    children:
                        duration.map((e) => OptionContainer(text: e)).toList(),
                  ),
                ],
              ),
              Column(
                children: [
                  LabelText(text: 'Table (optional)'),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 50, // Fixed height for each row
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      return OptionContainer(text: tables[index].tableName);
                    },
                  ),
                ],
              ),
              AppTextField(
                controller: _remarksController,
                labelText: 'Remarks (optional)',
                hintText: 'Enter Remarks',
                minLines: 3,
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionContainer extends StatelessWidget {
  const OptionContainer({super.key, required this.text});

  final String text;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
