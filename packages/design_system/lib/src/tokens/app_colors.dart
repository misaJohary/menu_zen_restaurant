import 'package:flutter/material.dart';

/// Customer-app palette per design.md §3.2.
///
/// The original staff-app constants below are kept for backwards
/// compatibility with the existing tablet/mobile apps. New code should
/// prefer [AppColors].
class AppColors {
  AppColors._();

  // Surface
  static const Color canvas = Color(0xFFF7F2EC); // "linen"
  static const Color card = Color(0xFFFFFFFF);

  // Ink
  static const Color inkPrimary = Color(0xFF1A1714);
  static const Color inkMuted = Color(0xFF6B6258);
  static const Color hairline = Color(0x141A1714); // ink.primary @ 8%

  // Brand
  static const Color terracotta = Color(0xFFC2461E);
  static const Color ember = Color(0xFFE07A3B);

  // Accents
  static const Color sage = Color(0xFF7A8B6F);
  static const Color bordeaux = Color(0xFF5C1A1B);

  // Signals
  static const Color warning = Color(0xFFD4A24C);
  static const Color error = Color(0xFFA8261C);

  // Dark theme inversions
  static const Color canvasDark = Color(0xFF15110D);
  static const Color cardDark = Color(0xFF1F1A15);
  static const Color inkPrimaryDark = Color(0xFFF7F2EC);
  static const Color inkMutedDark = Color(0xFFB5AB9F);
  static const Color hairlineDark = Color(0x33F7F2EC);
}

// ---------------------------------------------------------------------------
// Legacy staff-app constants (preserved).
// ---------------------------------------------------------------------------
const Color primaryColor = Color(0xFFA0CD64);
const Color grey = Color(0xFF999999);

final List<Map<String, dynamic>> categoryColors = [
  {
    'name': 'Red',
    'color': Colors.red.shade100,
    'textColor': Colors.red.shade800,
  },
  {
    'name': 'Blue',
    'color': Colors.blue.shade100,
    'textColor': Colors.blue.shade800,
  },
  {
    'name': 'Green',
    'color': Colors.green.shade100,
    'textColor': Colors.green.shade800,
  },
  {
    'name': 'Yellow',
    'color': Colors.yellow.shade100,
    'textColor': Colors.yellow.shade800,
  },
  {
    'name': 'Purple',
    'color': Colors.purple.shade100,
    'textColor': Colors.purple.shade800,
  },
  {
    'name': 'Pink',
    'color': Colors.pink.shade100,
    'textColor': Colors.pink.shade800,
  },
  {
    'name': 'Indigo',
    'color': Colors.indigo.shade100,
    'textColor': Colors.indigo.shade800,
  },
  {
    'name': 'Gray',
    'color': Colors.grey.shade200,
    'textColor': Colors.grey.shade800,
  },
];
