import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

class UserEntity extends Equatable {
  final int? id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String? fullName;
  final String username;
  final String? phone;
  final String? password;
  final Role? role;
  final int? roleId;
  final String? roleName;
  final bool? mustChangePassword;

  const UserEntity({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.fullName,
    required this.username,
    this.phone,
    this.password,
    this.role,
    this.roleId,
    this.roleName,
    this.mustChangePassword,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    firstname,
    lastname,
    fullName,
    username,
    phone,
    password,
    role,
    roleId,
    roleName,
    mustChangePassword,
  ];
}

enum Role {
  @JsonValue('super_admin')
  superAdmin,
  admin,
  server,
  cashier,
  cook,
}
