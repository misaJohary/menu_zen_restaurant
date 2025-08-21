import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/features/domains/entities/category_entity.dart';

import 'menu_entity.dart';

class MenuItemEntity extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String? picture;
  final bool? isAvailable;
  final CategoryEntity category;
  final List<MenuEntity> menus;

  const MenuItemEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.picture,
    this.isAvailable,
    required this.category,
    required this.menus,
  });

  /// Create a copyWith method to allow for easy copying with modifications

  copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? picture,
    bool? isAvailable,
    CategoryEntity? category,
    List<MenuEntity>? menus,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      picture: picture ?? this.picture,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      menus: menus ?? this.menus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    picture,
    isAvailable,
    category,
    menus,
  ];
}
