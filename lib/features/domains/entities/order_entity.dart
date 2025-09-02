import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/core/extensions/string_extension.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_menu_item.dart';

class OrderEntity extends Equatable {
  final int? id;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final String? clientName;
  final List<OrderMenuItem> orderMenuItems;
  final int restaurantTableId;
  final DateTime? createdAt;

  const OrderEntity({
    this.id,
    required this.orderStatus,
    required this.paymentStatus,
    this.clientName,
    this.orderMenuItems = const [],
    required this.restaurantTableId,
    this.createdAt,
  });

  ///create copyWith method
  OrderEntity copyWith({
    int? id,
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    String? clientName,
    List<OrderMenuItem>? orderMenuItems,
    int? restaurantTableId,
    DateTime? createdAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      clientName: clientName ?? this.clientName,
      orderMenuItems: orderMenuItems ?? this.orderMenuItems,
      restaurantTableId: restaurantTableId ?? this.restaurantTableId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderStatus,
    paymentStatus,
    clientName,
    orderMenuItems,
    restaurantTableId,
    createdAt,
  ];
}

enum OrderStatus {
  created,
  @JsonValue('in_preparation')
  inPreparation,
  ready,
  served;

  String get toSnakeCase => name.toSnakeCase();
  Map<String, String> get toJson => {'status': toSnakeCase};
}

enum PaymentStatus { unpaid, paid, prepaid, refunded }
