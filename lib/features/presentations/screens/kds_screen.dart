import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/auths/auth_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/orders_bloc.dart';
import '../../../core/constants/constants.dart';
import '../../domains/entities/order_entity.dart';
import '../../domains/entities/order_menu_item.dart';

@RoutePage()
class KdsScreen extends StatefulWidget {
  const KdsScreen({super.key});

  @override
  State<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends State<KdsScreen> {
  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(OrderFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildNavbar(),
          Expanded(
            child: BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                if (state.status == BlocStatus.loading &&
                    state.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredOrders = state.orders.where((order) {
                  if (showCompleted) {
                    return order.orderStatus == OrderStatus.ready ||
                        order.orderStatus == OrderStatus.served;
                  } else {
                    return order.orderStatus == OrderStatus.created ||
                        order.orderStatus == OrderStatus.inPreparation;
                  }
                }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Text(
                      showCompleted ? "No completed orders" : "No open orders",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableHeight =
                        (constraints.maxHeight - (kspacing * 4))
                            .clamp(0, double.infinity)
                            .toDouble();

                    final columns = _buildColumns(
                      filteredOrders,
                      availableHeight > 0
                          ? availableHeight
                          : constraints.maxHeight,
                    );

                    return Padding(
                      padding: const EdgeInsets.all(kspacing * 2),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (
                              int columnIndex = 0;
                              columnIndex < columns.length;
                              columnIndex++
                            )
                              Padding(
                                padding: EdgeInsets.only(
                                  right: columnIndex == columns.length - 1
                                      ? 0.0
                                      : kspacing * 2,
                                ),
                                child: Column(
                                  children: [
                                    for (
                                      int slotIndex = 0;
                                      slotIndex < columns[columnIndex].length;
                                      slotIndex++
                                    )
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom:
                                              slotIndex ==
                                                  columns[columnIndex].length -
                                                      1
                                              ? 0.0
                                              : kspacing * 2,
                                        ),
                                        child: SizedBox(
                                          width: 320,
                                          child: KdsOrderCard(
                                            slot:
                                                columns[columnIndex][slotIndex],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final restaurantName =
            state.userRestaurant?.restaurant.name ?? "La Botica";
        final userName =
            state.userRestaurant?.user.fullName ??
            state.userRestaurant?.user.username ??
            "";

        return Container(
          color: const Color(0xFF2D2D2D),
          padding: const EdgeInsets.symmetric(
            horizontal: kspacing * 3,
            vertical: kspacing,
          ),
          child: Row(
            children: [
              Text(
                restaurantName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: kspacing * 4),
              _buildStationDropdown(state),
              const Spacer(),
              _buildStatusToggles(),
              const SizedBox(width: kspacing * 4),
              _buildSettingsButton(userName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationDropdown(AuthState state) {
    final stationName =
        state.userRestaurant?.user.roleName?.toUpperCase() ?? "STATION";
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kspacing * 2,
        vertical: kspacing / 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            "$stationName Station - 1",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: kspacing),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildStatusToggles() {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final openCount = state.orders
            .where(
              (o) =>
                  o.orderStatus == OrderStatus.created ||
                  o.orderStatus == OrderStatus.inPreparation,
            )
            .length;
        final completedCount = state.orders
            .where(
              (o) =>
                  o.orderStatus == OrderStatus.ready ||
                  o.orderStatus == OrderStatus.served,
            )
            .length;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                label: "Open ($openCount)",
                isActive: !showCompleted,
                onTap: () => setState(() => showCompleted = false),
                activeColor: const Color(0xFF00897B),
              ),
              _buildToggleButton(
                label: "Completed ($completedCount)",
                isActive: showCompleted,
                onTap: () => setState(() => showCompleted = true),
                activeColor: Colors.white,
                activeTextColor: Colors.black87,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
    Color activeTextColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kspacing * 3,
          vertical: kspacing * 1.5,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? activeTextColor : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(String userName) {
    return PopupMenuButton<String>(
      icon: Row(
        children: [
          Text(
            userName,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: kspacing),
          const Icon(Icons.settings, color: Colors.white),
        ],
      ),
      onSelected: (value) {
        if (value == 'logout') {
          context.read<AuthBloc>().add(AuthLoggedOut());
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
      ],
    );
  }
}

class KdsOrderCard extends StatelessWidget {
  final _CardSlot slot;

  const KdsOrderCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final order = slot.order;
    final bool isInProgress = order.orderStatus == OrderStatus.inPreparation;
    final Color headerColor = isInProgress
        ? const Color(0xFFF36D21)
        : const Color(0xFF4A4A4A);
    final String timeStr = order.createdAt != null
        ? DateFormat('hh:mm a').format(order.createdAt!)
        : '--:--';
    final bool showHeader = !slot.showContinuedTop;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          if (showHeader) ...[
            Container(
              padding: const EdgeInsets.all(kspacing),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order.id}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isInProgress ? Icons.soup_kitchen : Icons.print,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
            // Subheader
            Padding(
              padding: const EdgeInsets.all(kspacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.rTable?.name ?? order.clientName ?? "Take-Out",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Brownie Jennifer", // Hardcoded for now
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          // Continued Top
          if (slot.showContinuedTop)
            _buildContinuedIndicator("Continued...", Icons.arrow_upward),
          // Items
          Padding(
            padding: const EdgeInsets.all(kspacing),
            child: Column(
              children: [for (final item in slot.items) _buildOrderItem(item)],
            ),
          ),
          // Continued Bottom
          if (slot.showContinuedBottom)
            _buildContinuedIndicator("Continued...", Icons.arrow_downward),
          // Action Buttons
          if (slot.showButton)
            if (isInProgress)
              _buildActionButton(
                context,
                "Mark Done",
                const Color(0xFFF36D21),
                OrderStatus.ready,
              )
            else if (order.orderStatus == OrderStatus.created)
              _buildActionButton(
                context,
                "Start",
                const Color(0xFF2D2D2D),
                OrderStatus.inPreparation,
              ),
        ],
      ),
    );
  }

  Widget _buildContinuedIndicator(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kspacing, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderMenuItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kspacing / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${item.quantity}",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: kspacing * 1.5),
              Expanded(
                child: Text(
                  item.menuItem.translations.isNotEmpty
                      ? item.menuItem.translations.first.name
                      : 'Nom',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: kspacing * 3),
              child: Text(
                "${item.notes}",
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    OrderStatus nextStatus,
  ) {
    return Padding(
      padding: const EdgeInsets.all(kspacing),
      child: OutlinedButton(
        onPressed: () {
          context.read<OrdersBloc>().add(
            OrderStatusUpdated(slot.order.id!, nextStatus),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(vertical: kspacing * 1.5),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _CardSlot {
  final OrderEntity order;
  final List<OrderMenuItem> items;
  final bool showContinuedTop;
  final bool showContinuedBottom;
  final bool showButton;

  _CardSlot({
    required this.order,
    required this.items,
    required this.showContinuedTop,
    required this.showContinuedBottom,
    required this.showButton,
  });
}

List<List<_CardSlot>> _buildColumns(
  List<OrderEntity> orders,
  double columnHeight,
) {
  const double headerHeight = 40; // 8*2 padding + title/time text
  const double subHeaderHeight = 100; // 8*2 padding + single line
  const double dividerHeight = 1;
  const double continuedHeight = 20; // 4*2 padding + 12 icon/text
  const double buttonHeight = 54; // 8*2 padding + button height
  const double cardGap = kspacing * 2;

  double itemHeight(OrderMenuItem item) {
    double h = 21; // 8 vertical padding + 13 text
    if (item.notes != null && item.notes!.isNotEmpty) {
      h += 11; // note line
    }
    return h;
  }

  final List<List<_CardSlot>> columns = [[]];
  double usedHeight = 0;

  for (final order in orders) {
    List<OrderMenuItem> remaining = List<OrderMenuItem>.from(
      order.orderMenuItems,
    );
    bool isFirstSlice = true;

    while (remaining.isNotEmpty) {
      double available = columnHeight - usedHeight - cardGap;
      final double headerBlockHeight =
          isFirstSlice ? (headerHeight + subHeaderHeight + dividerHeight) : 0;
      final double minNeeded = headerBlockHeight +
          (isFirstSlice ? 0 : continuedHeight) +
          itemHeight(remaining.first) +
          continuedHeight;

      if (available < minNeeded) {
        columns.add([]);
        usedHeight = 0;
        available = columnHeight;
      }

      final List<OrderMenuItem> slice = [];
      double sliceHeight = headerBlockHeight + (isFirstSlice ? 0 : continuedHeight);
      bool willContinue = false;

      for (int i = 0; i < remaining.length; i++) {
        final double nextItemH = itemHeight(remaining[i]);
        final bool isLast = i == remaining.length - 1;
        final double needed =
            nextItemH + (isLast ? buttonHeight : continuedHeight);

        if (sliceHeight + needed <= available) {
          sliceHeight += nextItemH;
          slice.add(remaining[i]);
        } else {
          willContinue = true;
          break;
        }
      }

      if (!willContinue) {
        sliceHeight += buttonHeight;
      } else {
        sliceHeight += continuedHeight;
      }

      columns.last.add(
        _CardSlot(
          order: order,
          items: slice,
          showContinuedTop: !isFirstSlice,
          showContinuedBottom: willContinue,
          showButton: !willContinue,
        ),
      );

      usedHeight += sliceHeight + cardGap;
      remaining = remaining.sublist(slice.length);
      isFirstSlice = false;
    }
  }

  return columns;
}
