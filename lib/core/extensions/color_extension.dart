import 'dart:ui';

extension ColorToHex on Color {
  /// Returns the color as a hex string: #AARRGGBB
  String get toHex {
    String hex = value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '0x$hex';
  }
}