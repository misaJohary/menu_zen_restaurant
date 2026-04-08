import 'package:equatable/equatable.dart';

import '../entities/menu_item_entity.dart';

class MenuItemUpdateParams extends Equatable {
  final int id;
  final double? price;
  final String? picture;
  final int? categoryId;
  final bool? active;
  final List<MenuItemTranslation>? translations;

  const MenuItemUpdateParams({
    required this.id,
    this.price,
    this.picture,
    this.categoryId,
    this.active,
    this.translations,
  });

  @override
  List<Object?> get props => [
    id,
    price,
    picture,
    categoryId,
    active,
    translations,
  ];
}
