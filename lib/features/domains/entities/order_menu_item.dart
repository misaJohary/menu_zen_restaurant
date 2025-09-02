import 'package:equatable/equatable.dart';

import 'menu_item_entity.dart';

class OrderMenuItem extends Equatable {
  final MenuItemEntity menuItem;
  final int? menuItemId;
  final int quantity;
  final double unitPrice;

  const OrderMenuItem({
    required this.menuItem,
    this.menuItemId,
    this.quantity = 0,
    this.unitPrice = 0.0,
  });

  OrderMenuItem copyWith({
    MenuItemEntity? menuItem,
    int? quantity,
    double? unitPrice,
    int? menuItemId,
  }) {
    return OrderMenuItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      menuItemId: menuItemId ?? this.menuItemId,
    );
  }

  @override
  List<Object?> get props => [menuItem, quantity, unitPrice, menuItemId];
}
