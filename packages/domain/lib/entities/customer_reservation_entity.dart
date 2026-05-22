import 'package:equatable/equatable.dart';

import 'reservation_request_status.dart';
import 'restaurant_public_entity.dart';
import 'table_assignment_entity.dart';

class CustomerReservationEntity extends Equatable {
  final int id;
  final DateTime reservedAt;
  final ReservationRequestStatus status;
  final int? partySize;
  final String? note;
  final DateTime createdAt;
  final RestaurantPublicEntity restaurant;
  final List<TableAssignmentEntity> assignedTables;

  const CustomerReservationEntity({
    required this.id,
    required this.reservedAt,
    required this.status,
    required this.partySize,
    required this.note,
    required this.createdAt,
    required this.restaurant,
    this.assignedTables = const [],
  });

  CustomerReservationEntity copyWith({
    int? id,
    DateTime? reservedAt,
    ReservationRequestStatus? status,
    int? partySize,
    String? note,
    DateTime? createdAt,
    RestaurantPublicEntity? restaurant,
    List<TableAssignmentEntity>? assignedTables,
  }) {
    return CustomerReservationEntity(
      id: id ?? this.id,
      reservedAt: reservedAt ?? this.reservedAt,
      status: status ?? this.status,
      partySize: partySize ?? this.partySize,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      restaurant: restaurant ?? this.restaurant,
      assignedTables: assignedTables ?? this.assignedTables,
    );
  }

  @override
  List<Object?> get props => [
        id,
        reservedAt,
        status,
        partySize,
        note,
        createdAt,
        restaurant,
        assignedTables,
      ];
}
