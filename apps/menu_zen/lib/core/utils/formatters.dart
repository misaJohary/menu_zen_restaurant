import 'package:design_system/design_system.dart';
import 'package:domain/entities/opening_hours_entity.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

String? formatDistanceKm(BuildContext context, double? km) {
  if (km == null || km <= 0) return null;
  final l10n = AppLocalizations.of(context);
  if (km < 1) return l10n.distanceMeters((km * 1000).round());
  if (km < 10) return l10n.distanceKilometersShort(km.toStringAsFixed(1));
  return l10n.distanceKilometersRound(km.round());
}

String restaurantTypeLabel(BuildContext context, String? raw) {
  final l10n = AppLocalizations.of(context);
  switch (raw) {
    case 'fastfood':
      return l10n.cuisineFastFood;
    case 'casual':
      return l10n.cuisineCasualDining;
    case 'fine_dining':
      return l10n.cuisineFineDining;
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
OpenStatusInfo? resolveOpenStatus(
  BuildContext context,
  OpeningHoursEntity? hours, {
  DateTime? now,
}) {
  if (hours == null || hours.periods.isEmpty) return null;
  final l10n = AppLocalizations.of(context);
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
        return OpenStatusInfo(
          OpenStatus.closingSoon,
          l10n.detailStatusClosesAt(slot.close),
        );
      }
      return OpenStatusInfo(
        OpenStatus.open,
        l10n.detailStatusOpenUntil(slot.close),
      );
    }
  }
  return OpenStatusInfo(OpenStatus.closed, l10n.detailStatusClosed);
}

int? _parseHHmm(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}
