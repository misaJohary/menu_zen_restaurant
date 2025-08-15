import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_entity.dart';

part 'menu_model.g.dart';

@JsonSerializable()
class MenuModel extends MenuEntity {
  const MenuModel({super.id, required super.name, required super.description, super.isActive});

  factory MenuModel.fromJson(Map<String, dynamic> json) =>
      _$MenuModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuModelToJson(this);

  @override
  MenuModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return MenuModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  MenuModel.fromEntity(MenuEntity entity)
    : super(id: entity.id, name: entity.name, description: entity.description, isActive: entity.isActive);
}