import 'package:json_annotation/json_annotation.dart';

import 'package:domain/entities/category_entity.dart';

part 'category_translation_model.g.dart';

@JsonSerializable()
class CategoryTranslationModel extends CategoryTranslation {
  const CategoryTranslationModel({
    required super.name,
    super.description,
    required super.languageCode,
  });

  factory CategoryTranslationModel.fromEntity(CategoryTranslation entity) {
    return CategoryTranslationModel(
      name: entity.name,
      description: entity.description,
      languageCode: entity.languageCode,
    );
  }

  factory CategoryTranslationModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryTranslationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryTranslationModelToJson(this);
}
