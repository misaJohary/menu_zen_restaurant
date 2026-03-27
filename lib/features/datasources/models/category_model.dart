import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/core/extensions/color_extension.dart';
import 'package:menu_zen_restaurant/core/extensions/string_extension.dart';
import 'package:menu_zen_restaurant/features/domains/entities/category_entity.dart';

import 'category_translation_model.dart';

part 'category_model.g.dart';

class ColorConverter implements JsonConverter<Color?, String?> {
  const ColorConverter();

  @override
  Color? fromJson(String? json) {
    if (json == null) return null;
    return json.fromHexString;
  }

  @override
  String? toJson(Color? color) {
    Logger().e('Converting color to String: ${color.toString()}');
    return color?.toHex;
  }
}

@JsonSerializable()
class CategoryModel extends CategoryEntity {
  @override
  final List<CategoryTranslationModel> translations;

  const CategoryModel({super.id, required this.translations, this.color})
    : super(themeColor: color);

  @ColorConverter()
  final Color? color;

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      color: entity.themeColor,
      translations: entity.translations.map((translation) {
        return CategoryTranslationModel.fromEntity(translation);
      }).toList(),
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryModel copyWith({
    int? id,
    List<CategoryTranslationModel>? translations,
    Color? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      translations: translations ?? this.translations,
      color: color ?? this.color,
    );
  }
}
