import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/features/domains/entities/category_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/translation_base.dart';

import 'menu_entity.dart';

abstract class MenuItemTranslation extends TranslationBase {
  final String name;
  final String? description;

  const MenuItemTranslation({
    required this.name,
    this.description,
    required super.languageCode,
  });

  @override
  List<Object?> get props => [name, description, languageCode];
}

class MenuItemEntity extends Equatable {
  final int? id;
  final List<MenuItemTranslation> translations;
  final double price;
  final String? picture;
  final bool? active;
  final CategoryEntity? category;
  final List<MenuEntity> menus;

  const MenuItemEntity({
    required this.id,
    required this.translations,
    required this.price,
    this.picture,
    this.active,
    this.category,
    this.menus = const [],
  });

  /// Create a copyWith method to allow for easy copying with modifications

  copyWith({
    int? id,
    List<MenuItemTranslation>? translations,
    double? price,
    String? picture,
    bool? active,
    CategoryEntity? category,
    List<MenuEntity>? menus,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      translations: translations ?? this.translations,
      price: price ?? this.price,
      picture: picture ?? this.picture,
      active: active ?? this.active,
      category: category ?? this.category,
      menus: menus ?? this.menus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    translations,
    price,
    picture,
    active,
    category,
    menus,
  ];
}
