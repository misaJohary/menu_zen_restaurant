import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/top_menu_item_entity.dart';

part 'top_menu_item_model.g.dart';

@JsonSerializable()
class TopMenuItemModel extends TopMenuItemEntity {
  const TopMenuItemModel({
    required super.id,
    required super.name,
    required super.picture,
    required super.category,
    required super.timesOrdered,
    required super.totalQuantity,
    required super.totalRevenue,
  });

  factory TopMenuItemModel.fromJson(Map<String, dynamic> json) {
    if (json['picture'] != null) {
      final pic = json['picture'];
      json['picture'] = '${dotenv.env['BASE_URL']!}/$pic';
    }
    return _$TopMenuItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TopMenuItemModelToJson(this);
}
