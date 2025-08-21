import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_item_entity.dart';

import 'category_model.dart';
import 'menu_model.dart';

part 'menu_item_model.g.dart';

@JsonSerializable()
class MenuItemModel extends MenuItemEntity {
  final CategoryModel _category;
  final List<MenuModel> _menus;

  @override
  CategoryModel get category => _category;

  @override
  List<MenuModel> get menus => _menus;

  const MenuItemModel({
    super.id,
    required super.name,
    required super.price,
    super.isAvailable,
    super.description,
    super.picture,
    required CategoryModel super.category,
    required List<MenuModel> super.menus,
  }) : _category = category, _menus = menus;

  MenuItemModel.fromEntity(MenuItemEntity entity, this._category, this._menus)
    : super(
        id: entity.id,
        name: entity.name,
        price: entity.price,
        isAvailable: entity.isAvailable,
        description: entity.description,
        picture: entity.picture,
        category: CategoryModel.fromEntity(entity.category),
        menus: entity.menus
            .map((menu) => MenuModel.fromEntity(menu))
            .toList(),
      );

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    if (json['picture'] != null) {
      json['picture'] =
          '${dotenv.env['BASE_URL']!}/${json['picture'].toString()}';
    }
    return _$MenuItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);
}
