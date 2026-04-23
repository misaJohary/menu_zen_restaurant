import 'package:equatable/equatable.dart';

import 'reservation_status.dart';

class ReservationEntity extends Equatable {
  final int? id;
  final String? name;
  final String? phone;
  final DateTime? reservedAt;
  final ReservationStatus status;
  final String? note;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReservationEntity({
    this.id,
    this.name,
    this.phone,
    this.reservedAt,
    this.status = ReservationStatus.active,
    this.note,
    this.createdById,
    this.createdAt,
    this.updatedAt,
  });

  ReservationEntity copyWith({
    int? id,
    String? name,
    String? phone,
    DateTime? reservedAt,
    ReservationStatus? status,
    String? note,
    int? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReservationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      reservedAt: reservedAt ?? this.reservedAt,
      status: status ?? this.status,
      note: note ?? this.note,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    reservedAt,
    status,
    note,
    createdById,
    createdAt,
    updatedAt,
  ];
}
