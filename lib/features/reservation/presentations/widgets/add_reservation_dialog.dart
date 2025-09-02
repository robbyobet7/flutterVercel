import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rebill_flutter/core/providers/table_provider.dart';
import 'package:rebill_flutter/core/widgets/app_button.dart';
import 'package:rebill_flutter/core/widgets/app_divider.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/decrement_button.dart';
import 'package:rebill_flutter/core/widgets/increment_button.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';

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
          const AppDivider(),
          const Expanded(child: AddReservationContent()),
          Column(
            children: [
              const AppDivider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      onPressed: () => Navigator.pop(context),
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
  final _dateTimeController = TextEditingController();
  final _headCountController = TextEditingController(text: '1');

  DateTime? _selectedDateTime;
  String? _selectedDuration;
  String? _selectedTable;

  @override
  void dispose() {
    _nameController.dispose();
    _remarksController.dispose();
    _dateTimeController.dispose();
    _headCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _dateTimeController.text = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(_selectedDateTime!);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double interactiveElementHeight = 46.0;
    const durationOptions = [
      '30 mins',
      '60 mins',
      '90 mins',
      '120 mins',
      'Until End',
    ];
    const spacing = 16.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NameInput(nameController: _nameController),
              const SizedBox(height: spacing),
              _HeadCountAndDatePicker(
                height: interactiveElementHeight,
                headCountController: _headCountController,
                dateTimeController: _dateTimeController,
                onTapDate: () => _selectDateTime(context),
              ),
              const SizedBox(height: spacing),
              _DurationSelector(
                height: interactiveElementHeight,
                durationOptions: durationOptions,
                selectedDuration: _selectedDuration,
                onSelect: (duration) {
                  setState(() {
                    _selectedDuration = duration;
                  });
                },
              ),
              const SizedBox(height: spacing),
              _TableSelector(
                height: interactiveElementHeight,
                selectedTable: _selectedTable,
                onSelect: (table) {
                  setState(() {
                    _selectedTable = table;
                  });
                },
              ),
              const SizedBox(height: spacing),
              _RemarksInput(remarksController: _remarksController),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  final TextEditingController nameController;

  const _NameInput({required this.nameController});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: nameController,
      labelText: 'Name',
      hintText: 'Enter customer name',
    );
  }
}

class _RemarksInput extends StatelessWidget {
  final TextEditingController remarksController;

  const _RemarksInput({required this.remarksController});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: remarksController,
      labelText: 'Remarks (optional)',
      hintText: 'Enter Remarks',
      minLines: 3,
      maxLines: 5,
    );
  }
}

class _HeadCountAndDatePicker extends StatelessWidget {
  final double height;
  final TextEditingController headCountController;
  final TextEditingController dateTimeController;
  final VoidCallback onTapDate;

  const _HeadCountAndDatePicker({
    required this.height,
    required this.headCountController,
    required this.dateTimeController,
    required this.onTapDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LabelText(text: 'Head Count'),
              const SizedBox(height: 8),
              SizedBox(
                height: height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const DecrementButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        showLabel: false,
                        textAlign: TextAlign.center,
                        controller: headCountController,
                        keyboardType: TextInputType.number,
                        hintText: 'Qty',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const IncrementButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: AppTextField(
            controller: dateTimeController,
            labelText: 'Date & Time',
            hintText: 'Select Date & Time',
            readOnly: true,
            onTap: onTapDate,
            suffix: Icon(
              Icons.calendar_month,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final double height;
  final List<String> durationOptions;
  final String? selectedDuration;
  final ValueChanged<String> onSelect;

  const _DurationSelector({
    required this.height,
    required this.durationOptions,
    required this.selectedDuration,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabelText(text: 'Duration'),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: Row(
            children:
                durationOptions.map((duration) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: OptionContainer(
                        text: duration,
                        isSelected: selectedDuration == duration,
                        onTap: () => onSelect(duration),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TableSelector extends ConsumerWidget {
  final double height;
  final String? selectedTable;
  final ValueChanged<String> onSelect;

  const _TableSelector({
    this.selectedTable,
    required this.onSelect,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tableProvider).tables;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabelText(text: 'Table (optional)'),
        const SizedBox(height: 4),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == tables.length - 1 ? 0 : 8.0,
                ),
                child: SizedBox(
                  width: 90,
                  child: OptionContainer(
                    text: table.tableName,
                    isSelected: selectedTable == table.tableName,
                    onTap: () => onSelect(table.tableName),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class OptionContainer extends StatelessWidget {
  const OptionContainer({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor =
        isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainer;
    final textColor =
        isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
