import 'package:equatable/equatable.dart';

class MenuEntity extends Equatable {
  final int? id;
  final String name;
  final String description;
  final bool? isActive;

  const MenuEntity({
    this.id,
    required this.name,
    required this.description,
    this.isActive = true,
  });

  ///create copyWith
  ///
  MenuEntity copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return MenuEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, isActive];
}
