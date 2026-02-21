import 'package:intl/intl.dart';

class DateUtil {
  // Parse date from API response
  static DateTime? parseDate(String? dateString,
      {String format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"}) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateFormat(format).parseUtc(dateString).toLocal();
    } catch (e) {
      print("Error parsing date: $e");
      return null;
    }
  }

  // Format date to a readable string
  static String formatDate(DateTime? date,
      {String format = 'yyyy-MM-dd HH:mm'}) {
    if (date == null) return '';

    try {
      return DateFormat(format).format(date);
    } catch (e) {
      print("Error formatting date: $e");
      return '';
    }
  }

  // Convert date from API to a readable string
  static String formatApiDate(String? dateString,
      {String inputFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
      String outputFormat = 'MMM dd, yyyy hh:mm a'}) {
    DateTime? date = parseDate(dateString, format: inputFormat);
    return formatDate(date, format: outputFormat);
  }
}
