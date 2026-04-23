import 'package:json_annotation/json_annotation.dart';

import 'package:domain/entities/reservation_status.dart';
import 'package:domain/entities/table_reservation_entity.dart';

import 'reservation_model.dart';

part 'table_reservation_model.g.dart';

@JsonSerializable()
class TableReservationModel extends TableReservationEntity {
  @override
  final ReservationModel? reservation;

  const TableReservationModel({
    super.id,
    super.reservationId,
    super.tableId,
    super.status,
    this.reservation,
    super.createdAt,
    super.updatedAt,
  }) : super(reservation: reservation);

  factory TableReservationModel.fromJson(Map<String, dynamic> json) =>
      _$TableReservationModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableReservationModelToJson(this);

  factory TableReservationModel.fromEntity(TableReservationEntity entity) {
    return TableReservationModel(
      id: entity.id,
      reservationId: entity.reservationId,
      tableId: entity.tableId,
      status: entity.status,
      reservation: entity.reservation != null
          ? ReservationModel.fromEntity(entity.reservation!)
          : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  TableReservationModel copyWith({
    int? id,
    int? reservationId,
    int? tableId,
    ReservationStatus? status,
    covariant ReservationModel? reservation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableReservationModel(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      reservation: reservation ?? this.reservation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
