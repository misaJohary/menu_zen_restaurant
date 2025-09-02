import 'package:json_annotation/json_annotation.dart';

import '../../domains/entities/order_menu_item.dart';
import 'menu_item_model.dart';
part 'order_menu_item_model.g.dart';

@JsonSerializable()
class OrderMenuItemModel extends OrderMenuItem {
  @override
  @JsonKey(includeToJson: false)
  final MenuItemModel menuItem;
  
  const OrderMenuItemModel({
    super.quantity,
    super.unitPrice,
    required this.menuItem,
    super.menuItemId,
  }) : super(menuItem: menuItem);

  factory OrderMenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderMenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMenuItemModelToJson(this);
}