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
    int? id,
    int quantity = 0,
    double unitPrice = 0.0,
    required this.menuItem,
    int? menuItemId,
    String status = "init",
    String? notes,
  }) : super(
          id: id,
          menuItem: menuItem,
          quantity: quantity,
          unitPrice: unitPrice,
          menuItemId: menuItemId,
          status: status,
          notes: notes,
        );

  factory OrderMenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderMenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMenuItemModelToJson(this);
}