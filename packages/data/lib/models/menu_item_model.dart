import 'package:json_annotation/json_annotation.dart';
import 'package:data/models/menu_item_translation_model.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:data/config/base_url_config.dart';

import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/menu_entity.dart';
import 'category_model.dart';
import 'menu_model.dart';

part 'menu_item_model.g.dart';

@JsonSerializable()
class MenuItemModel extends MenuItemEntity {
  @override
  final CategoryModel? category;

  @override
  final List<MenuModel> menus;

  @override
  final List<MenuItemTranslationModel> translations;

  final int? categoryId;

  const MenuItemModel({
    super.id,
    required super.price,
    super.active,
    super.picture,
    required this.category,
    required this.menus,
    required this.translations,
    this.categoryId,
    super.kitchenId,
  }) : super(translations: translations);

  factory MenuItemModel.fromEntity(MenuItemEntity entity) {
    return MenuItemModel(
      id: entity.id,
      price: entity.price,
      active: entity.active,
      picture: entity.picture,
      category: entity.category != null
          ? CategoryModel.fromEntity(entity.category!)
          : null,
      menus: entity.menus.map((menu) => MenuModel.fromEntity(menu)).toList(),
      translations: entity.translations
          .map(
            (translation) => MenuItemTranslationModel.fromEntity(translation),
          )
          .toList(),
      kitchenId: entity.kitchenId,
    );
  }

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    if (json['picture'] != null) {
      final pic = json['picture'];
      json['picture'] = '${BaseUrlConfig.current}/$pic';
    }
    return _$MenuItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);

  @override
  copyWith({
    int? id,
    List<MenuItemTranslation>? translations,
    double? price,
    String? picture,
    bool? active,
    CategoryEntity? category,
    List<MenuEntity>? menus,
    int? categoryId,
    int? kitchenId,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      price: price ?? this.price,
      active: active ?? this.active,
      picture: picture ?? this.picture,
      category: (category != null)
          ? CategoryModel.fromEntity(category)
          : this.category,
      menus: menus != null
          ? menus.map((e) => MenuModel.fromEntity(e)).toList()
          : this.menus,
      translations: translations != null
          ? translations
                .map((e) => MenuItemTranslationModel.fromEntity(e))
                .toList()
          : this.translations,
      categoryId: categoryId ?? this.categoryId,
      kitchenId: kitchenId ?? this.kitchenId,
    );
  }
}
