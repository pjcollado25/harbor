import 'package:intl/intl.dart';

String formatMoney(int amount, [String currencyCode = 'PHP']) {
  final formatted = NumberFormat.currency(
    locale: 'en_PH',
    name: currencyCode,
    symbol: currencyCode == 'PHP' ? '₱' : currencyCode,
    decimalDigits: 0,
  ).format(amount);
  return formatted.replaceAll('\u00a0', '');
}

String formatDate(DateTime date, {bool year = false}) =>
    DateFormat(year ? 'd MMM yyyy' : 'd MMM').format(date);
String formatLongDate(DateTime date) => DateFormat('EEE, d MMM').format(date);
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
