import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

class UserEntity extends Equatable {
  final int? id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String username;
  final String? phone;
  final String? password;
  final Role role;

  const UserEntity({
    this.id,
    this.email,
    this.firstname,
    this.lastname,
    required this.username,
    this.phone,
    this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    firstname,
    lastname,
    username,
    phone,
    password,
    role,
  ];
}

enum Role {
  @JsonValue('super_admin')
  superAdmin,
  admin,
  server,
  cashier,
}
