import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class KitchenEntity extends Equatable {
  final int? id;
  final int? restaurantId;
  final String name;
  final bool active;
  final List<UserEntity> cooks;

  const KitchenEntity({
    this.id,
    this.restaurantId,
    required this.name,
    this.active = true,
    this.cooks = const [],
  });

  KitchenEntity copyWith({
    int? id,
    int? restaurantId,
    String? name,
    bool? active,
    List<UserEntity>? cooks,
  }) {
    return KitchenEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      active: active ?? this.active,
      cooks: cooks ?? this.cooks,
    );
  }

  @override
  List<Object?> get props => [id, restaurantId, name, active, cooks];
}
