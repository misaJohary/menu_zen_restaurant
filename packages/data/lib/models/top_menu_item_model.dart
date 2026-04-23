import 'package:json_annotation/json_annotation.dart';
import 'package:domain/entities/top_menu_item_entity.dart';
import 'package:data/config/base_url_config.dart';

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
      json['picture'] = '${BaseUrlConfig.current}/$pic';
    }
    return _$TopMenuItemModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TopMenuItemModelToJson(this);
}
