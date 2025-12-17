import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/datasources/models/menu_item_translation_model.dart';

part 'menu_item_update_model.g.dart';

@JsonSerializable()
class MenuItemUpdateModel extends Equatable {
  final int id;
  final double? price;
  final String? picture;
  final int? categoryId;
  final bool? active;
  final List<MenuItemTranslationModel>? translations;

  const MenuItemUpdateModel({
    required this.id,
    this.price,
    this.picture,
    this.categoryId,
    this.active,
    this.translations,
  });

  @override
  List<Object?> get props => [id, price, picture, categoryId, active, translations];

  Map<String, dynamic> toJson() => _$MenuItemUpdateModelToJson(this);
}