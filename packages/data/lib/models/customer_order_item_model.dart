import 'package:domain/entities/customer_order_item_entity.dart';

class CustomerOrderItemModel {
  static CustomerOrderItemEntity fromJson(Map<String, dynamic> json) {
    return CustomerOrderItemEntity(
      id: json['id'] as int?,
      menuItemId: (json['menu_item_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num? ?? 0).toInt(),
      notes: json['notes'] as String? ?? json['note'] as String?,
    );
  }
}
