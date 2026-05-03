import 'package:intl/intl.dart';

String formatMoodDate(DateTime date, {String? localeCode}) {
  final code = localeCode ?? 'en';
  return DateFormat.yMMMd(code).format(date.toLocal());
}

String formatMoodDateLong(DateTime date, {String? localeCode}) {
  final code = localeCode ?? 'en';
  return DateFormat.yMMMMd(code).format(date.toLocal());
}
