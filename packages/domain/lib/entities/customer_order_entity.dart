import 'package:equatable/equatable.dart';

import 'customer_order_item_entity.dart';
import 'customer_order_status.dart';
import 'customer_order_type.dart';
import 'order_entity.dart' show PaymentStatus;

class CustomerOrderEntity extends Equatable {
  final int id;
  final int restaurantId;
  final int? restaurantTableId;
  final CustomerOrderType orderType;
  final CustomerOrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final String? contactName;
  final String? contactPhone;

  /// Free-text delivery address. Required when [orderType] is
  /// [CustomerOrderType.delivery]; `null` for dine-in / pickup.
  final String? deliveryAddress;

  /// Free-text courier instructions (gate code, floor, etc.).
  final String? deliveryNotes;

  final DateTime? scheduledFor;
  final int totalAmount;
  final List<CustomerOrderItemEntity> items;
  final DateTime createdAt;

  const CustomerOrderEntity({
    required this.id,
    required this.restaurantId,
    this.restaurantTableId,
    required this.orderType,
    required this.orderStatus,
    required this.paymentStatus,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
    this.deliveryNotes,
    this.scheduledFor,
    required this.totalAmount,
    this.items = const [],
    required this.createdAt,
  });

  CustomerOrderEntity copyWith({
    int? id,
    int? restaurantId,
    int? restaurantTableId,
    CustomerOrderType? orderType,
    CustomerOrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    String? contactName,
    String? contactPhone,
    String? deliveryAddress,
    String? deliveryNotes,
    DateTime? scheduledFor,
    int? totalAmount,
    List<CustomerOrderItemEntity>? items,
    DateTime? createdAt,
  }) {
    return CustomerOrderEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantTableId: restaurantTableId ?? this.restaurantTableId,
      orderType: orderType ?? this.orderType,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        restaurantTableId,
        orderType,
        orderStatus,
        paymentStatus,
        contactName,
        contactPhone,
        deliveryAddress,
        deliveryNotes,
        scheduledFor,
        totalAmount,
        items,
        createdAt,
      ];
}
