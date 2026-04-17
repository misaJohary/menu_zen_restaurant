import 'package:json_annotation/json_annotation.dart';

import 'package:domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.firstname,
    super.lastname,
    @JsonKey(name: 'full_name') super.fullName,
    super.email,
    super.phone,
    required super.username,
    super.password,
    @JsonKey(name: 'role_name') super.role,
    @JsonKey(name: 'role_id') super.roleId,
    @JsonKey(name: 'role_name', includeToJson: false) super.roleName,
    @JsonKey(name: 'must_change_password') super.mustChangePassword,
  });

  /// Constructor from UserEntity
  UserModel.fromEntity(UserEntity entity)
    : super(
        id: entity.id,
        firstname: entity.firstname,
        lastname: entity.lastname,
        fullName: entity.fullName,
        email: entity.email,
        phone: entity.phone,
        username: entity.username,
        password: entity.password,
        role: entity.role,
        roleId: entity.roleId,
        roleName: entity.roleName,
        mustChangePassword: entity.mustChangePassword,
      );

  ///copyWith
  UserModel copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? fullName,
    String? email,
    String? phone,
    String? username,
    String? password,
    Role? role,
    int? roleId,
    String? roleName,
    bool? mustChangePassword,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
