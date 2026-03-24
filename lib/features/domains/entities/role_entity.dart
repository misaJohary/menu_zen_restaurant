import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable {
  final int id;
  final String name;
  final int level;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.level,
  });

  @override
  List<Object?> get props => [id, name, level];
}
