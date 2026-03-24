import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/datasources/models/table_model.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_entity.dart';

import 'category_model.dart';
import 'menu_item_model.dart';
import 'menu_item_translation_model.dart';
import 'menu_model.dart';
import 'order_menu_item_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends OrderEntity {
  @override
  final List<OrderMenuItemModel> orderMenuItems;

  @override
  final TableModel? rTable;

  const OrderModel({
    super.id,
    super.clientName,
    required this.orderMenuItems,
    required this.rTable,
    required super.orderStatus,
    required super.paymentStatus,
    required super.restaurantTableId,
    super.createdAt,
    required super.totalAmount,
  });

  factory OrderModel.fromEntity(OrderEntity entity) {
    final orderMenuItems = entity.orderMenuItems.map((menu) {
      return OrderMenuItemModel(
        quantity: menu.quantity,
        unitPrice: menu.unitPrice,
        menuItemId: menu.menuItem.id,
        menuItem: MenuItemModel.fromEntity(menu.menuItem),
        status: menu.status,
        notes: menu.notes,
      );
    }).toList();
    return OrderModel(
      id: entity.id,
      clientName: entity.clientName,
      orderStatus: entity.orderStatus,
      rTable: entity.rTable != null ? TableModel.fromEntity(entity.rTable!) : null,
      paymentStatus: entity.paymentStatus,
      orderMenuItems: orderMenuItems,
      restaurantTableId: entity.restaurantTableId,
      totalAmount: entity.totalAmount,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
