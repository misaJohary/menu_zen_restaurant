import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_item_entity.dart';
part 'menu_item_translation_model.g.dart';

@JsonSerializable()
class MenuItemTranslationModel extends MenuItemTranslation {
  const MenuItemTranslationModel({
    required super.name,
    super.description,
    required super.languageCode,
  });

  factory MenuItemTranslationModel.fromEntity(MenuItemTranslation entity) {
    return MenuItemTranslationModel(
      name: entity.name,
      description: entity.description,
      languageCode: entity.languageCode,
    );
  }

  factory MenuItemTranslationModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemTranslationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemTranslationModelToJson(this);
}