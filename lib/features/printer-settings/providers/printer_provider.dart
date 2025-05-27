import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rebill_flutter/features/printer-settings/models/printer.dart';

class PrinterNotifier extends StateNotifier<PrinterModel?> {
  PrinterNotifier() : super(null);

  void selectPrinter(PrinterModel printer) {
    state = printer;
  }

  void clearSelection() {
    state = null;
  }
}

final printerProvider = StateNotifierProvider<PrinterNotifier, PrinterModel?>((
  ref,
) {
  return PrinterNotifier();
});

class PrinterLayoutNotifier extends StateNotifier<String> {
  PrinterLayoutNotifier() : super('Normal');

  void setLayout(String layout) {
    state = layout;
  }
}

final printerLayoutProvider =
    StateNotifierProvider<PrinterLayoutNotifier, String>((ref) {
      return PrinterLayoutNotifier();
    });
