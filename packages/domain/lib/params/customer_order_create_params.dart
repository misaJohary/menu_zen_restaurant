import '../entities/customer_order_type.dart';
import 'customer_order_item_create_params.dart';

class CustomerOrderCreateParams {
  final int restaurantId;
  final CustomerOrderType orderType;

  /// Required when [orderType] is [CustomerOrderType.dineIn].
  final int? restaurantTableId;

  final String? contactName;

  /// Required when [orderType] is [CustomerOrderType.delivery] unless the
  /// caller wants the API to fall back to the customer profile's phone.
  final String? contactPhone;

  /// Required when [orderType] is [CustomerOrderType.delivery].
  final String? deliveryAddress;

  /// Optional courier instructions for delivery (gate code, floor…).
  final String? deliveryNotes;

  final DateTime? scheduledFor;
  final List<CustomerOrderItemCreateParams> items;

  const CustomerOrderCreateParams({
    required this.restaurantId,
    required this.orderType,
    this.restaurantTableId,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
    this.deliveryNotes,
    this.scheduledFor,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'restaurant_id': restaurantId,
        'order_type': orderType.apiValue,
        if (restaurantTableId != null)
          'restaurant_table_id': restaurantTableId,
        if (contactName != null && contactName!.isNotEmpty)
          'contact_name': contactName,
        if (contactPhone != null && contactPhone!.isNotEmpty)
          'contact_phone': contactPhone,
        if (deliveryAddress != null && deliveryAddress!.isNotEmpty)
          'delivery_address': deliveryAddress,
        if (deliveryNotes != null && deliveryNotes!.isNotEmpty)
          'delivery_notes': deliveryNotes,
        if (scheduledFor != null)
          'scheduled_for': scheduledFor!.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };
}
