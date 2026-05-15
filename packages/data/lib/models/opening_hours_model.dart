import 'package:domain/entities/opening_hours_entity.dart';

class OpeningHoursModel {
  static OpeningHoursEntity? parse(Map<String, dynamic>? json) {
    if (json == null) return null;

    final timezone = json['timezone'] as String?;
    final periods = <int, List<OpeningHoursSlotEntity>>{};

    final raw = json['periods'];

    if (raw is List) {
      // ✅ Handles your JSON structure: [{day, slots}, ...]
      for (final entry in raw.whereType<Map>()) {
        final dayKey = entry['day'];
        if (dayKey is! int) continue;

        final slots = entry['slots'];
        if (slots is! List) continue;

        periods[dayKey] = slots
            .whereType<Map>()
            .map(
              (slot) => OpeningHoursSlotEntity(
            open: slot['open']?.toString() ?? '',
            close: slot['close']?.toString() ?? '',
          ),
        )
            .toList();
      }
    } else if (raw is Map) {
      // Legacy fallback: {"0": [...], "1": [...]}
      raw.forEach((key, value) {
        final dayKey = int.tryParse(key.toString());
        if (dayKey == null || value is! List) return;
        periods[dayKey] = value
            .whereType<Map>()
            .map(
              (slot) => OpeningHoursSlotEntity(
            open: slot['open']?.toString() ?? '',
            close: slot['close']?.toString() ?? '',
          ),
        )
            .toList();
      });
    }

    return OpeningHoursEntity(timezone: timezone, periods: periods);
  }
}
