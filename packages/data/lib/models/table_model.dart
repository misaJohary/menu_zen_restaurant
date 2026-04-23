import 'package:json_annotation/json_annotation.dart';

import 'package:domain/entities/table_entity.dart';
import 'package:domain/entities/table_status.dart';

import 'table_reservation_model.dart';
import 'user_model.dart';

part 'table_model.g.dart';

@JsonSerializable()
class TableModel extends TableEntity {
  @override
  final UserModel? server;

  @override
  final TableReservationModel? activeReservation;

  const TableModel({
    super.id,
    required super.name,
    super.isActive,
    super.restaurantId,
    super.status,
    super.serverId,
    super.waitingSince,
    super.seats,
    this.server,
    this.activeReservation,
  }) : super(server: server, activeReservation: activeReservation);

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

  factory TableModel.fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
      restaurantId: entity.restaurantId,
      status: entity.status,
      serverId: entity.serverId,
      waitingSince: entity.waitingSince,
      seats: entity.seats,
      server: entity.server != null
          ? UserModel.fromEntity(entity.server!)
          : null,
      activeReservation: entity.activeReservation != null
          ? TableReservationModel.fromEntity(entity.activeReservation!)
          : null,
    );
  }

  @override
  TableModel copyWith({
    int? id,
    String? name,
    bool? isActive,
    int? restaurantId,
    TableStatus? status,
    int? serverId,
    DateTime? waitingSince,
    int? seats,
    covariant UserModel? server,
    covariant TableReservationModel? activeReservation,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      restaurantId: restaurantId ?? this.restaurantId,
      status: status ?? this.status,
      serverId: serverId ?? this.serverId,
      waitingSince: waitingSince ?? this.waitingSince,
      seats: seats ?? this.seats,
      server: server ?? this.server,
      activeReservation: activeReservation ?? this.activeReservation,
    );
  }
}
