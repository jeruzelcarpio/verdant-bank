import 'package:intl/intl.dart';

String formatToLocal(DateTime dateTime, {String pattern = 'MMM dd, yyyy, hh:mm a'}) {
  return DateFormat(pattern).format(dateTime.toLocal());
}