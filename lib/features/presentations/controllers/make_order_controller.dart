import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../domains/entities/category_entity.dart';
import '../../domains/entities/order_entity.dart';
import '../../domains/entities/order_menu_item.dart';
import '../managers/orders/order_menu_item/order_menu_item_bloc.dart';
import '../managers/orders/orders_bloc.dart';

class MakeOrderController extends ChangeNotifier {
  MakeOrderController({required this.context});

  OrdersBloc get bloc => context.read<OrdersBloc>();

  OrderMenuItemBloc get orderMenuItemBloc => context.read<OrderMenuItemBloc>();

  final BuildContext context;

  CategoryEntity? selectedCategory;
  ScrollController? orderListScroll;
  final formKey = GlobalKey<FormBuilderState>();

  void selectCategory(CategoryEntity? category) {
    selectedCategory = category;
    notifyListeners();
  }

  void resetSelection() {
    selectedCategory = null;
    notifyListeners();
  }

  incrementQuantity(int index) {
    orderMenuItemBloc.add(OrderMenuItemIncremented(index));
  }

  decrementQuantity(int index) {
    orderMenuItemBloc.add(OrderMenuItemDecremented(index));
  }

  removeOrderFromList(OrderMenuItem orderMenuItem) {
    orderMenuItemBloc.add(OrderMenuItemRemoved(orderMenuItem));
  }

  addFetchOrderMenuItem() {
    orderMenuItemBloc.add(OrderMenuItemFetched());
  }

  clearOrderMenuItem() {
    orderMenuItemBloc.add(OrderMenuItemCleared());
  }

  List<OrderMenuItem> filterMenuOrdered(OrderMenuItemState state) {
    return state.orderMenuItems
        .where((orderMenu) => orderMenu.quantity > 0)
        .toList();
  }

  orderUpdateInitiated(OrderEntity order) {
    orderMenuItemBloc.add(OrderMenuUpdateInitiated(order));
  }

  updateOrder(OrderEntity order) {
    final firstname = formKey.currentState?.fields['firstname']?.value;
    final orderMenu = filterMenuOrdered(orderMenuItemBloc.state);
    bloc.add(
      OrderUpdated(
        order.copyWith(
          clientName: firstname ?? order.clientName,
          orderMenuItems: orderMenu,
        ),
      ),
    );
  }

  validateOrder(OrderMenuItemState state) {
    final firstname = formKey.currentState?.fields['firstname']?.value;
    final table = formKey.currentState?.fields['table_number']?.value;
    final orderMenu = filterMenuOrdered(state);
    bloc.add(
      OrderCreated(
        OrderEntity(
          clientName: firstname ?? 'Client',
          orderStatus: OrderStatus.created,
          paymentStatus: PaymentStatus.unpaid,
          orderMenuItems: orderMenu,
          restaurantTableId: 1,
        ),
      ),
    );
  }
}
