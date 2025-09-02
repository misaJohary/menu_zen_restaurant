import 'dart:ui';

extension StringExtension on String {
  /// Convert "0xFFAAAAAA" string to Color
  Color? get fromHexString {
    try {
      String cleanHex = this;
      if (cleanHex.startsWith('0x') || cleanHex.startsWith('0X')) {
        cleanHex = cleanHex.substring(2);
      }

      final colorValue = int.parse(cleanHex, radix: 16);
      return Color(colorValue);
    } catch (e) {
      return null;
    }
  }

  String toSnakeCase() {
    return replaceAllMapped(
      RegExp('([a-z])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)?.toLowerCase()}',
    );
  }
}
