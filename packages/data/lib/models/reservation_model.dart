import 'package:json_annotation/json_annotation.dart';

import 'package:domain/entities/reservation_entity.dart';
import 'package:domain/entities/reservation_status.dart';

part 'reservation_model.g.dart';

@JsonSerializable()
class ReservationModel extends ReservationEntity {
  const ReservationModel({
    super.id,
    super.name,
    super.phone,
    super.reservedAt,
    super.status,
    super.note,
    super.createdById,
    super.createdAt,
    super.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReservationModelToJson(this);

  factory ReservationModel.fromEntity(ReservationEntity entity) {
    return ReservationModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      reservedAt: entity.reservedAt,
      status: entity.status,
      note: entity.note,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  ReservationModel copyWith({
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
    return ReservationModel(
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
}
