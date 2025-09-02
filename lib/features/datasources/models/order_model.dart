import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_entity.dart';

import 'category_model.dart';
import 'menu_item_model.dart';
import 'menu_model.dart';
import 'order_menu_item_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends OrderEntity {
  @override
  final List<OrderMenuItemModel> orderMenuItems;

  const OrderModel({
    super.id,
    super.clientName,
    required this.orderMenuItems,
    required super.orderStatus,
    required super.paymentStatus,
    required super.restaurantTableId,
    super.createdAt,
  });

  factory OrderModel.fromEntity(OrderEntity entity) {
    final orderMenuItems = entity.orderMenuItems.map((menu) {
      return OrderMenuItemModel(
        quantity: menu.quantity,
        unitPrice: menu.unitPrice,
        menuItemId: menu.menuItem.id,
        menuItem: MenuItemModel.fromEntity(
          menu.menuItem,
          CategoryModel.fromEntity(menu.menuItem.category),
          menu.menuItem.menus
              .map((menu) => MenuModel.fromEntity(menu))
              .toList(),
        ),
      );
    }).toList();
    return OrderModel(
      id: entity.id,
      clientName: entity.clientName,
      orderStatus: entity.orderStatus,
      paymentStatus: entity.paymentStatus,
      orderMenuItems: orderMenuItems,
      restaurantTableId: entity.restaurantTableId,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
