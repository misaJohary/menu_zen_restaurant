import 'package:equatable/equatable.dart';

import 'menu_item_entity.dart';

class OrderMenuItem extends Equatable {
  final int? id;
  final MenuItemEntity menuItem;
  final int? menuItemId;
  final int quantity;
  final double unitPrice;
  final String status;
  final String? notes;

  const OrderMenuItem({
    this.id,
    required this.menuItem,
    this.menuItemId,
    this.quantity = 0,
    this.unitPrice = 0.0,
    this.status = "init",
    this.notes,
  });

  OrderMenuItem copyWith({
    int? id,
    MenuItemEntity? menuItem,
    int? quantity,
    double? unitPrice,
    int? menuItemId,
    String? status,
    String? notes,
  }) {
    return OrderMenuItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      menuItemId: menuItemId ?? this.menuItemId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    menuItem,
    quantity,
    unitPrice,
    menuItemId,
    status,
    notes,
  ];
}
