import 'package:flutter/material.dart';
import 'package:rebill_flutter/core/widgets/app_checkbox.dart';
import 'package:rebill_flutter/core/widgets/app_popup_menu.dart';
import 'package:rebill_flutter/core/widgets/app_text_field.dart';
import 'package:rebill_flutter/core/widgets/decrement_button.dart';
import 'package:rebill_flutter/core/widgets/increment_button.dart';
import 'package:rebill_flutter/core/widgets/label_text.dart';
import 'package:rebill_flutter/features/printer-settings/presentations/widgets/printer_popup_menu.dart';

class AdvancedSetting extends StatelessWidget {
  const AdvancedSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final advancedSettings = [
      AdvancedSettingItem(
        items: [],
        popupMenu: 'Bill Printer',
        formFieldText: 'Print on checkout (copies)',
      ),
      AdvancedSettingItem(
        items: [],
        popupMenu: 'Order Printer',
        formFieldText: 'Print on order (copies)',
      ),
      AdvancedSettingItem(
        items: [],
        popupMenu: 'Order Printer (Bar)',
        formFieldText: '',
      ),
    ];
    return Column(
      spacing: 12,
      children:
          advancedSettings
              .map(
                (e) => Row(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: PrinterPopupMenu(
                        label: e.popupMenu,
                        items: e.items,
                        hintText: 'Select Printer',
                      ),
                    ),
                    Column(
                      children: [
                        LabelText(text: e.formFieldText),
                        SizedBox(
                          width: 150,
                          child: Row(
                            spacing: 12,
                            children: [
                              DecrementButton(),
                              Expanded(
                                child: AppTextField(
                                  controller: TextEditingController(),
                                  showLabel: false,
                                ),
                              ),
                              IncrementButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        LabelText(text: 'Auto Cut'),
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: Center(child: AppCheckbox()),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .toList(),
    );
  }
}

class AdvancedSettingItem {
  final List<AppPopupMenuItem<String>> items;
  final String popupMenu;
  final String formFieldText;

  AdvancedSettingItem({
    required this.items,
    required this.popupMenu,
    required this.formFieldText,
  });
}
