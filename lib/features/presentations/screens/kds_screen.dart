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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(OrderFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                            showCompleted
                                ? "Aucune commande terminée"
                                : "Aucune commande en cours",
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
                                            slotIndex <
                                                columns[columnIndex].length;
                                            slotIndex++
                                          )
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom:
                                                    slotIndex ==
                                                            columns[columnIndex]
                                                                    .length -
                                                                1
                                                        ? 0.0
                                                        : kspacing * 2,
                                              ),
                                              child: SizedBox(
                                                width: 320,
                                                child: KdsOrderCard(
                                                  slot: columns[columnIndex]
                                                      [slotIndex],
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
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      dividerColor: const Color(0xFFE0E0E0),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF2D2D2D),
        secondary: const Color(0xFF00897B),
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      dividerColor: const Color(0xFF2A2A2A),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF1B1B1B),
        secondary: const Color(0xFF26A69A),
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white70,
      ),
    );
  }

  Widget _buildNavbar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color navbarColor =
            isDark ? const Color(0xFF1B1B1B) : const Color(0xFF2D2D2D);
        final Color controlBg =
            isDark ? const Color(0xFF2E2E2E) : const Color(0xFF4A4A4A);
        final restaurantName =
            state.userRestaurant?.restaurant.name ?? "La Botica";
        final userName =
            state.userRestaurant?.user.fullName ??
            state.userRestaurant?.user.username ??
            "";

        return Container(
          color: navbarColor,
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
              _buildStationDropdown(state, controlBg),
              const Spacer(),
              _buildStatusToggles(),
              const SizedBox(width: kspacing * 4),
              _buildThemeToggle(),
              const SizedBox(width: kspacing * 2),
              _buildSettingsButton(userName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationDropdown(AuthState state, Color backgroundColor) {
    final stationName =
        state.userRestaurant?.user.roleName?.toUpperCase() ?? "STATION";
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kspacing * 2,
        vertical: kspacing / 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            "$stationName Poste - 1",
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
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color containerColor =
            isDark ? const Color(0xFF2E2E2E) : const Color(0xFF4A4A4A);
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
            color: containerColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                label: "Ouvertes ($openCount)",
                isActive: !showCompleted,
                onTap: () => setState(() => showCompleted = false),
                activeColor: const Color(0xFF00897B),
              ),
              _buildToggleButton(
                label: "Terminées ($completedCount)",
                isActive: showCompleted,
                onTap: () => setState(() => showCompleted = true),
                activeColor:
                    isDark ? const Color(0xFFE0E0E0) : Colors.white,
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
        const PopupMenuItem<String>(value: 'logout', child: Text('Déconnexion')),
      ],
    );
  }

  Widget _buildThemeToggle() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: Colors.white70,
          size: 18,
        ),
        const SizedBox(width: kspacing),
        Switch(
          value: isDarkMode,
          onChanged: (value) => setState(() => isDarkMode = value),
          activeColor: const Color(0xFF26A69A),
          inactiveThumbColor: Colors.white70,
          inactiveTrackColor: Colors.white24,
        ),
      ],
    );
  }
}

class KdsOrderCard extends StatelessWidget {
  final _CardSlot slot;

  const KdsOrderCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final order = slot.order;
    final bool isInProgress = order.orderStatus == OrderStatus.inPreparation;
    final bool isServed = order.orderStatus == OrderStatus.served;
    final bool isPaid =
        order.paymentStatus == PaymentStatus.paid ||
        order.paymentStatus == PaymentStatus.prepaid;
    final Color headerColor = isServed
        ? primaryColor
        : isInProgress
            ? const Color(0xFFF36D21)
            : const Color(0xFF4A4A4A);
    final String timeStr = order.createdAt != null
        ? DateFormat('hh:mm a').format(order.createdAt!)
        : '--:--';
    final bool showHeader = !slot.showContinuedTop;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
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
                        "Commande #${order.id}",
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
                    order.rTable?.name ?? order.clientName ?? "À emporter",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
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
            _buildContinuedIndicator(
              context,
              "Suite...",
              Icons.arrow_upward,
            ),
          // Items
          Padding(
            padding: const EdgeInsets.all(kspacing),
            child: Column(
              children: [
                for (final item in slot.items)
                  _buildOrderItem(context, slot.order, item),
              ],
            ),
          ),
          // Continued Bottom
          if (slot.showContinuedBottom)
            _buildContinuedIndicator(
              context,
              "Suite...",
              Icons.arrow_downward,
            ),
          // Action Buttons
          if (slot.showButton)
            if (isInProgress)
              _buildActionButton(
                context,
                "Terminer",
                const Color(0xFFF36D21),
                OrderStatus.ready,
              )
            else if (order.orderStatus == OrderStatus.created)
              _buildActionButton(
                context,
                "Démarrer",
                const Color(0xFF2D2D2D),
                OrderStatus.inPreparation,
              ),
          if (isServed)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kspacing,
                0,
                kspacing,
                kspacing,
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kspacing * 1.5,
                    vertical: kspacing / 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPaid ? "Payé" : "Servi",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinuedIndicator(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color muted = isDark ? Colors.white54 : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kspacing, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: muted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: muted),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    OrderEntity order,
    OrderMenuItem item,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isStarted = order.orderStatus == OrderStatus.inPreparation;
    final bool isReady = item.status == 'ready';
    final bool canToggle =
        isStarted && order.id != null && item.id != null;
    final String nextStatus = isReady ? 'init' : 'ready';
    final TextDecoration? decoration =
        isReady ? TextDecoration.lineThrough : null;
    final Color readyColor = const Color(0xFFF36D21);
    final Color? textColor = isReady ? readyColor : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kspacing / 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canToggle
            ? () {
                context.read<OrdersBloc>().add(
                  OrderMenuItemStatusUpdated(
                    order.id!,
                    item.id!,
                    nextStatus,
                  ),
                );
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item.quantity}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    decoration: decoration,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: kspacing * 1.5),
              Expanded(
                child: Text(
                  item.menuItem.translations.isNotEmpty
                      ? item.menuItem.translations.first.name
                      : 'Nom',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: decoration,
                    color: textColor,
                  ),
                ),
              ),
              if (isStarted) ...[
                const SizedBox(width: kspacing),
                Icon(
                  isReady
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: isReady
                      ? readyColor
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ],
          ),
            if (item.notes != null && item.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: kspacing * 3),
                child: Text(
                  "${item.notes}",
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isReady ? readyColor : (isDark ? Colors.white60 : Colors.black54),
                    decoration: decoration,
                  ),
                ),
              ),
          ],
        ),
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
  const double subHeaderHeight = 110; // 8*2 padding + single line
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
