import 'package:equatable/equatable.dart';
import 'translation_base.dart';

abstract class MenuTranslation extends TranslationBase {
  final String name;
  final String? description;

  const MenuTranslation({
    required this.name,
    this.description,
    required super.languageCode,
  });

  @override
  List<Object?> get props => [name, description, languageCode];
}

class MenuEntity extends Equatable {
  final int? id;
  final List<MenuTranslation> translations;
  final bool? active;

  const MenuEntity({this.id, this.translations = const [], this.active = true});

  ///create copyWith
  ///
  MenuEntity copyWith({
    int? id,
    List<MenuTranslation>? translations,
    bool? active,
  }) {
    return MenuEntity(
      id: id ?? this.id,
      translations: translations ?? this.translations,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [id, translations, active];
}
