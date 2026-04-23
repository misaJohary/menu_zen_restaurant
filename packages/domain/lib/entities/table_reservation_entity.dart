import 'package:equatable/equatable.dart';

import 'reservation_entity.dart';
import 'reservation_status.dart';

class TableReservationEntity extends Equatable {
  final int? id;
  final int? reservationId;
  final int? tableId;
  final ReservationStatus status;
  final ReservationEntity? reservation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TableReservationEntity({
    this.id,
    this.reservationId,
    this.tableId,
    this.status = ReservationStatus.active,
    this.reservation,
    this.createdAt,
    this.updatedAt,
  });

  TableReservationEntity copyWith({
    int? id,
    int? reservationId,
    int? tableId,
    ReservationStatus? status,
    ReservationEntity? reservation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableReservationEntity(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      reservation: reservation ?? this.reservation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    reservationId,
    tableId,
    status,
    reservation,
    createdAt,
    updatedAt,
  ];
}
