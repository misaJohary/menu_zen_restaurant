import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color ink, Color muted) {
    final display = GoogleFonts.frauncesTextTheme();
    final body = GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
        fontSize: 32,
        height: 38 / 32,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
    );
  }

  /// Tabular figures for prices.
  static TextStyle price({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: color,
  );
}
