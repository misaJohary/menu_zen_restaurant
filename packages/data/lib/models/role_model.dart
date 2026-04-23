import 'package:json_annotation/json_annotation.dart';
import 'package:domain/entities/role_entity.dart';

part 'role_model.g.dart';

@JsonSerializable()
class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    required super.level,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
