import 'package:equatable/equatable.dart';

import 'table_reservation_entity.dart';
import 'table_status.dart';
import 'user_entity.dart';

class TableEntity extends Equatable {
  final int? id;
  final String name;
  final bool? isActive;
  final int? restaurantId;
  final TableStatus status;
  final int? serverId;
  final DateTime? waitingSince;
  final int? seats;
  final UserEntity? server;
  final TableReservationEntity? activeReservation;

  const TableEntity({
    this.id,
    required this.name,
    this.isActive,
    this.restaurantId,
    this.status = TableStatus.free,
    this.serverId,
    this.waitingSince,
    this.seats,
    this.server,
    this.activeReservation,
  });

  TableEntity copyWith({
    int? id,
    String? name,
    bool? isActive,
    int? restaurantId,
    TableStatus? status,
    int? serverId,
    DateTime? waitingSince,
    int? seats,
    UserEntity? server,
    TableReservationEntity? activeReservation,
  }) {
    return TableEntity(
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

  @override
  List<Object?> get props => [
    id,
    name,
    isActive,
    restaurantId,
    status,
    serverId,
    waitingSince,
    seats,
    server,
    activeReservation,
  ];
}
