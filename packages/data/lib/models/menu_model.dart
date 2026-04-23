import 'package:json_annotation/json_annotation.dart';
import 'package:domain/entities/menu_entity.dart';

import 'menu_translation_model.dart';

part 'menu_model.g.dart';

@JsonSerializable()
class MenuModel extends MenuEntity {
  @override
  final List<MenuTranslationModel> translations;

  const MenuModel({super.id, required this.translations, super.active});

  factory MenuModel.fromJson(Map<String, dynamic> json) =>
      _$MenuModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuModelToJson(this);

  @override
  MenuModel copyWith({
    int? id,
    covariant List<MenuTranslationModel>? translations,
    bool? active,
  }) {
    return MenuModel(
      id: id ?? this.id,
      translations: translations ?? this.translations,
      active: active ?? this.active,
    );
  }

  factory MenuModel.fromEntity(MenuEntity entity) => MenuModel(
    id: entity.id,
    translations: entity.translations.map((translation) {
      return MenuTranslationModel.fromEntity(translation);
    }).toList(),
    active: entity.active,
  );
}
