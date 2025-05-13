import 'package:intl/intl.dart';

extension StringDateExtension on String {
  /// Converts a date string from one format to another
  /// Example: "Mon May 05 2025 10:30:30" to "05/05/2025 10:30"
  String formatDate({
    String inputFormat = 'EEE MMMM dd yyyy HH:mm:ss',
    String outputFormat = 'dd/MM/yyyy HH:mm',
  }) {
    try {
      final inputDate = DateFormat(inputFormat).parse(this);
      return DateFormat(outputFormat).format(inputDate);
    } catch (e) {
      // Try alternate format with abbreviated month names
      try {
        final alternateFormat = 'EEE MMM dd yyyy HH:mm:ss';
        final inputDate = DateFormat(alternateFormat).parse(this);
        return DateFormat(outputFormat).format(inputDate);
      } catch (e) {
        print(e);
        return this; // Return original string if parsing fails
      }
    }
  }

  /// Shorthand to format "Mon May 05 2025 10:30:30" to "05/05/2025 10:30"
  String toBillDate() {
    return formatDate();
  }

  /// Shorthand to format "Mon May 05 2025 10:30:30" to "05/05/2025"
  String toDateOnly() {
    return formatDate(outputFormat: 'dd/MM/yyyy');
  }

  /// Shorthand to format "Mon May 05 2025 10:30:30" to "10:30"
  String toTimeOnly() {
    return formatDate(outputFormat: 'HH:mm');
  }

  /// Parse string to DateTime
  DateTime? toDateTime({String format = 'EEE MMMM dd yyyy HH:mm:ss'}) {
    try {
      return DateFormat(format).parse(this);
    } catch (e) {
      // Try alternate format with abbreviated month names
      try {
        final alternateFormat = 'EEE MMM dd yyyy HH:mm:ss';
        return DateFormat(alternateFormat).parse(this);
      } catch (e) {
        return null;
      }
    }
  }
}
