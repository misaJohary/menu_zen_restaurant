import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/core/extensions/string_extension.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_menu_item.dart';
import 'package:menu_zen_restaurant/features/domains/entities/table_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_entity.dart';

class OrderEntity extends Equatable {
  final int? id;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final String? clientName;
  final List<OrderMenuItem> orderMenuItems;
  final int restaurantTableId;
  final TableEntity? rTable;
  final UserEntity? server;
  final DateTime? createdAt;
  final int totalAmount;

  const OrderEntity({
    this.id,
    required this.orderStatus,
    required this.paymentStatus,
    this.rTable,
    this.server,
    this.clientName,
    this.orderMenuItems = const [],
    required this.restaurantTableId,
    this.createdAt,
    required this.totalAmount,
  });

  ///create copyWith method
  OrderEntity copyWith({
    int? id,
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    String? clientName,
    List<OrderMenuItem>? orderMenuItems,
    int? restaurantTableId,
    TableEntity? rTable,
    UserEntity? server,
    DateTime? createdAt,
    int? totalAmount,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      clientName: clientName ?? this.clientName,
      orderMenuItems: orderMenuItems ?? this.orderMenuItems,
      restaurantTableId: restaurantTableId ?? this.restaurantTableId,
      rTable: rTable ?? this.rTable,
      server: server ?? this.server,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
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
    rTable,
    server,
    createdAt,
    totalAmount,
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

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.toSnakeCase == value,
      orElse: () => throw ArgumentError('Invalid OrderStatus: $value'),
    );
  }
}

enum PaymentStatus { unpaid, paid, prepaid, refunded }
