import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/make_order_controller.dart';

import '../../domains/entities/order_entity.dart';
import '../managers/auths/auth_bloc.dart';
import '../managers/orders/order_menu_item/order_menu_item_bloc.dart';
import '../widgets/make_orders/orders_widgets.dart';

@RoutePage()
class MakeOrderScreen extends StatefulWidget {
  const MakeOrderScreen({super.key, this.order});

  final OrderEntity? order;

  @override
  State<MakeOrderScreen> createState() => _MakeOrderScreenState();
}

class _MakeOrderScreenState extends State<MakeOrderScreen> {
  late MakeOrderController controller;

  @override
  void initState() {
    super.initState();
    controller = MakeOrderController(context: context)..addFetchOrderMenuItem();
    controller.orderListScroll = ScrollController();
    context.read<AuthBloc>().add(AuthUserGot());
    if (widget.order != null) {
      controller.orderUpdateInitiated(widget.order!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        context.read<OrderMenuItemBloc>().add(OrderMenuItemCleared());
      },
      child: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    OrderHeader(),
                    OrderMenuItemsBody(controller: controller),
                  ],
                ),
              ),
              BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
                builder: (context, state) {
                  final orders = controller.filterMenuOrdered(state);
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 2000),
                    child: orders.isNotEmpty
                        ? OrderSummaryPannel(controller: controller, order: widget.order,)
                        : SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
