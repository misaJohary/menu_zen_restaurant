import 'package:json_annotation/json_annotation.dart';

import '../../domains/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.firstname,
    super.lastname,
    super.email,
    super.phone,
    required super.username,
    super.password,
    required super.roles,
  });

  /// Constructor from UserEntity
  UserModel.fromEntity(UserEntity entity)
      : super(
    id: entity.id,
    firstname: entity.firstname,
    lastname: entity.lastname,
    email: entity.email,
    phone: entity.phone,
    username: entity.username,
    password: entity.password,
    roles: entity.roles,
  );

  ///copyWith
  UserModel copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? username,
    String? password,
    Role? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      password: password ?? this.password,
      roles: roles ?? this.roles,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}