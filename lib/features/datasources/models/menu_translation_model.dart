import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_entity.dart';

part 'menu_translation_model.g.dart';

@JsonSerializable()
class MenuTranslationModel extends MenuTranslation{
  const MenuTranslationModel({
    required super.name,
    super.description,
    required super.languageCode,
  });

  factory MenuTranslationModel.fromEntity(MenuTranslation entity) {
    return MenuTranslationModel(
      name: entity.name,
      description: entity.description,
      languageCode: entity.languageCode,
    );
  }

  factory MenuTranslationModel.fromJson(Map<String, dynamic> json) =>
      _$MenuTranslationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuTranslationModelToJson(this);
}