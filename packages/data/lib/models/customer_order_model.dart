import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_order_status.dart';
import 'package:domain/entities/customer_order_type.dart';
import 'package:domain/entities/order_entity.dart' show PaymentStatus;

import 'customer_order_item_model.dart';

class CustomerOrderModel {
  static CustomerOrderEntity fromJson(Map<String, dynamic> json) {
    return CustomerOrderEntity(
      id: (json['id'] as num).toInt(),
      restaurantId: (json['restaurant_id'] as num).toInt(),
      restaurantTableId: (json['restaurant_table_id'] as num?)?.toInt(),
      orderType: CustomerOrderType.fromString(json['order_type'] as String?),
      orderStatus:
          CustomerOrderStatus.fromString(json['order_status'] as String?),
      paymentStatus: _parsePaymentStatus(json['payment_status'] as String?),
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      deliveryNotes: json['delivery_notes'] as String?,
      scheduledFor: _parseDate(json['scheduled_for']),
      totalAmount: (json['total_amount'] as num? ?? 0).toInt(),
      items: (json['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(CustomerOrderItemModel.fromJson)
              .toList() ??
          const [],
      createdAt: _parseDate(json['created_at']) ?? DateTime.now().toUtc(),
    );
  }

  static PaymentStatus _parsePaymentStatus(String? value) {
    return switch (value) {
      'unpaid' => PaymentStatus.unpaid,
      'paid' => PaymentStatus.paid,
      'prepaid' => PaymentStatus.prepaid,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.unpaid,
    };
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    final s = raw.toString();
    final parsed = DateTime.tryParse(s);
    if (parsed == null) return null;
    // Treat naive datetimes as UTC, per backend convention.
    return parsed.isUtc ? parsed : DateTime.parse('${s}Z').toUtc();
  }
}
