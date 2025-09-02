import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../domains/entities/category_entity.dart';
import '../../domains/entities/order_entity.dart';
import '../../domains/entities/order_menu_item.dart';
import '../managers/orders/order_menu_item/order_menu_item_bloc.dart';
import '../managers/orders/orders_bloc.dart';

class OrderController extends ChangeNotifier {
  OrderController({required this.context});

  OrdersBloc get bloc => context.read<OrdersBloc>();

  final BuildContext context;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  addFetchOrders() {
    bloc.add(OrderFetched());
  }

  changeStatusOrder(int orderId, OrderStatus orderStatus) {
    bloc.add(OrderStatusUpdated(orderId, orderStatus));
  }

  deleteOrder(int orderId){
    bloc.add(OrderDeleted(orderId));
  }
}
