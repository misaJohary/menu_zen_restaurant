import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/features/domains/entities/translation_base.dart';

abstract class CategoryTranslation extends TranslationBase {
  final String name;
  final String? description;

  const CategoryTranslation({
    required this.name,
    this.description,
    required super.languageCode,
  });

  @override
  List<Object?> get props => [name, description, languageCode];
}

abstract class CategoryEntity extends Equatable {
  final int? id;
  final List<CategoryTranslation> translations;
  final Color? themeColor;

  const CategoryEntity({
    this.id,
    this.translations = const [],
    this.themeColor,
  });

  @override
  List<Object?> get props => [id, translations, themeColor];
}
