import 'package:intl/intl.dart';

final NumberFormat _whole = NumberFormat('#,##0', 'en_US');
final NumberFormat _withKobo = NumberFormat('#,##0.00', 'en_US');

/// Formats an amount the way prices are written in Nigeria: grouped in
/// thousands, and only carrying kobo when there actually are any.
///
/// Prices used to be interpolated straight into strings, so a twelve thousand
/// naira item read as `₦12550`.
String naira(num? value) {
  final amount = value ?? 0;
  final text =
      amount % 1 == 0 ? _whole.format(amount) : _withKobo.format(amount);
  return '₦$text';
}
