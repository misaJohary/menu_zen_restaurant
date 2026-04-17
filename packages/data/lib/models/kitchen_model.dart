import 'package:json_annotation/json_annotation.dart';
import 'package:domain/entities/kitchen_entity.dart';
import 'package:domain/entities/user_entity.dart';
import 'user_model.dart';

part 'kitchen_model.g.dart';

@JsonSerializable()
class KitchenModel extends KitchenEntity {
  @JsonKey(name: 'users')
  @override
  final List<UserModel> cooks;

  const KitchenModel({
    super.id,
    super.restaurantId,
    required super.name,
    super.active,
    this.cooks = const [],
  }) : super(cooks: cooks);

  factory KitchenModel.fromJson(Map<String, dynamic> json) =>
      _$KitchenModelFromJson(json);

  Map<String, dynamic> toJson() => _$KitchenModelToJson(this);

  factory KitchenModel.fromEntity(KitchenEntity entity) {
    return KitchenModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      name: entity.name,
      active: entity.active,
      cooks: entity.cooks
          .map((u) => UserModel.fromEntity(u))
          .toList(),
    );
  }

  @override
  KitchenModel copyWith({
    int? id,
    int? restaurantId,
    String? name,
    bool? active,
    List<UserEntity>? cooks,
  }) {
    return KitchenModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      active: active ?? this.active,
      cooks: cooks != null
          ? cooks.map((u) => UserModel.fromEntity(u)).toList()
          : this.cooks,
    );
  }
}
