import 'package:intl/intl.dart';

extension DoubleExtension on num {
  /// Convert "0xFFAAAAAA" string to Color
  String get formatMoney {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(this).replaceAll(',', ' ');
  }
}
