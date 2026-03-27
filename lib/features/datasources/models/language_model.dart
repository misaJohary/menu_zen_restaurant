import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/language_entity.dart';

part 'language_model.g.dart';

@JsonSerializable()
class LanguageModel extends LanguageEntity {
  const LanguageModel({required super.code, required super.name});

  factory LanguageModel.fromEntity(LanguageEntity entity) {
    return LanguageModel(code: entity.code, name: entity.name);
  }

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);
}
