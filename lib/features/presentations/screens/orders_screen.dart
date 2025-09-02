import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/extensions/color_extension.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/orders_bloc.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';
import '../../domains/entities/order_entity.dart';
import '../controllers/order_controller.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/orders/order_item.dart';

@RoutePage()
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late OrderController controller;

  @override
  void initState() {
    super.initState();
    controller = OrderController(context: context)..addFetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(kspacing * 2),
        child: Column(
          children: [
            BoardTitleWidget(
              title: 'Gestion de commandes',
              labelButton: 'Nouvelle commande',
              onButtonPressed: () async {
                context.router.push(MakeOrderRoute());
              },
            ),
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  final orders = state.orders;
                  return GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: orderStatus.length,
                    crossAxisSpacing: kspacing * 3,
                    childAspectRatio: 2.5,
                    clipBehavior: Clip.none,
                    children: [
                      ...orderStatus.map((status) {
                        final color = status['color'] as Color;
                        return OrderCard(
                          header: HeaderCardStatus(
                            icon: status['icon'] as IconData,
                            label: status['label'] as String,
                            color: color,
                          ),
                          color: color.lighten(),
                          isSelected: false,
                          orderNumber: orders
                              .where(
                                (order) =>
                                    order.orderStatus == status['status'],
                              )
                              .length,
                          onTap: () {
                            controller.setCurrentIndex(
                              orderStatus.indexOf(status),
                            );
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: kspacing * 3),
            Expanded(
              flex: 3,
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  return Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(kspacing),
                      border: Border.all(
                        color: (orderStatus[0]['color'] as Color).withOpacity(
                          .5,
                        ),
                        width: .3,
                      ),
                    ),
                    child: ListenableBuilder(
                      listenable: controller,
                      builder: (context, child) {
                        final index = controller.currentIndex;
                        final currentStatus = orderStatus[index];
                        final orders = state.orders
                            .where((order) => order.orderStatus.index == index)
                            .toList();
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(kspacing * 2),
                              margin: EdgeInsets.only(bottom: kspacing),
                              decoration: BoxDecoration(
                                color: (currentStatus['color'] as Color)
                                    .withOpacity(.3),
                                border: Border(
                                  bottom: BorderSide(
                                    color: (currentStatus['color'] as Color)
                                        .withOpacity(.5),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: HeaderCardStatus(
                                icon: currentStatus['icon'] as IconData,
                                label:
                                    '${currentStatus['label'] as String} (${orders.length})',
                                color: currentStatus['color'] as Color,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(kspacing * 2),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: kspacing * 2,
                                      ),
                                      child: OrderItem(
                                        order: order,
                                        onDelete: () {
                                          final id = order.id;
                                          if (id != null) {
                                            controller.deleteOrder(id);
                                          }
                                        },
                                        onEdit: () {
                                          context.router.push(
                                            MakeOrderRoute(order: order),
                                          );
                                        },
                                        onStatusChanged: (status) {
                                          controller.changeStatusOrder(
                                            order.id!,
                                            status,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final orderStatus = [
  {
    'label': 'En cours',
    'status': OrderStatus.created,
    'icon': Icons.access_time,
    'color': Colors.blueGrey,
    'orderNumber': 0,
  },
  {
    'label': 'Preparation',
    'status': OrderStatus.inPreparation,
    'icon': Icons.access_time,
    'color': Colors.blue,
    'orderNumber': 0,
  },
  {
    'label': 'Prêt',
    'status': OrderStatus.ready,
    'icon': Icons.check_circle_outline,
    'color': Colors.orange,
    'orderNumber': 0,
  },
  {
    'label': 'Servi',
    'status': OrderStatus.served,
    'icon': Icons.check_circle_outline,
    'color': primaryColor,
    'orderNumber': 0,
  },
];

class HeaderCardStatus extends StatelessWidget {
  const HeaderCardStatus({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color.darken(),
          //size: 32,
        ),
        SizedBox(width: kspacing),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color.darken(),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    this.orderNumber = 0,
    required this.color,
    required this.isSelected,
    required this.header,
    this.onTap,
  });

  final int orderNumber;
  final Color color;
  final bool isSelected;
  final Widget header;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final padding = kspacing * 1.5;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: padding, top: padding, bottom: padding),
        decoration: BoxDecoration(
          color: color.withOpacity(.3),
          borderRadius: BorderRadius.circular(kspacing * 2),
          border: Border.all(color: color.withOpacity(.5), width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            SizedBox(height: kspacing),
            Text(
              orderNumber.toString(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color.darken(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
