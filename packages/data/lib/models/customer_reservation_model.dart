import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/entities/reservation_request_status.dart';

import 'restaurant_public_model.dart';
import 'table_assignment_model.dart';

class CustomerReservationModel {
  static CustomerReservationEntity fromJson(Map<String, dynamic> json) {
    return CustomerReservationEntity(
      id: json['id'] as int,
      reservedAt: _parseDate(json['reserved_at'])!,
      status: ReservationRequestStatus.fromString(json['status'] as String?),
      partySize: json['party_size'] as int?,
      note: json['note'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now().toUtc(),
      restaurant: RestaurantPublicModel.fromJson(
        json['restaurant'] as Map<String, dynamic>,
      ),
      assignedTables:
          (json['assigned_tables'] as List?)
                  ?.whereType<Map<String, dynamic>>()
                  .map(TableAssignmentModel.fromJson)
                  .toList() ??
              const [],
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    final s = raw.toString();
    final parsed = DateTime.tryParse(s);
    if (parsed == null) return null;
    // Treat naive datetimes as UTC, per backend convention.
    return parsed.isUtc ? parsed : DateTime.parse('${s}Z').toUtc();
  }
}
