import 'package:design_system/design_system.dart';
import 'package:domain/entities/opening_hours_entity.dart';

String? formatDistanceKm(double? km) {
  if (km == null || km <= 0) return null;
  if (km < 1) return '${(km * 1000).round()} m';
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  return '${km.round()} km';
}

String restaurantTypeLabel(String? raw) {
  switch (raw) {
    case 'fastfood':
      return 'Fast food';
    case 'casual':
      return 'Casual dining';
    case 'fine_dining':
      return 'Fine dining';
    default:
      return '';
  }
}

class OpenStatusInfo {
  final OpenStatus status;
  final String label;
  const OpenStatusInfo(this.status, this.label);
}

/// Resolves an [OpenStatusInfo] from the periods of [hours] using local time.
/// API convention: `day` is `0 = Monday … 6 = Sunday`, slots are `HH:mm`.
OpenStatusInfo? resolveOpenStatus(OpeningHoursEntity? hours, {DateTime? now}) {
  if (hours == null || hours.periods.isEmpty) return null;
  final n = now ?? DateTime.now();
  final dayKey = n.weekday - 1;
  final currentMinutes = n.hour * 60 + n.minute;
  final slots = hours.periods[dayKey] ?? const <OpeningHoursSlotEntity>[];
  for (final slot in slots) {
    final open = _parseHHmm(slot.open);
    final close = _parseHHmm(slot.close);
    if (open == null || close == null) continue;
    if (currentMinutes >= open && currentMinutes < close) {
      if (close - currentMinutes <= 30) {
        return OpenStatusInfo(OpenStatus.closingSoon, 'Closes ${slot.close}');
      }
      return OpenStatusInfo(OpenStatus.open, 'Open · until ${slot.close}');
    }
  }
  return const OpenStatusInfo(OpenStatus.closed, 'Closed');
}

int? _parseHHmm(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}
