import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

export 'package:design_system/design_system.dart' show kspacing, categoryColors;

/// Primary colour for the mobile app (dark teal matching mockups).
const Color primaryColor = Color(0xFF006D6B);

/// Compact card format: 8500 → "8.50Ar"
String formatPriceCompact(double price) =>
    '${(price / 1000).toStringAsFixed(2)}Ar';

/// Full format: 45000 → "45 000 Ar"
String formatPriceFull(double price) =>
    '${NumberFormat('#,##0', 'fr').format(price.toInt())} Ar';
