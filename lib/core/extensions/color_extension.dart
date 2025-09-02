import 'dart:ui';

import 'package:flutter/material.dart';

extension ColorToHex on Color {
  /// Returns the color as a hex string: #AARRGGBB
  String get toHex {
    String hex = value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '0x$hex';
  }
}

extension ColorExtension on Color{
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}