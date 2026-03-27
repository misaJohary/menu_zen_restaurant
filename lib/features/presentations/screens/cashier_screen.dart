import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/auths/auth_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/orders_bloc.dart';
import '../../../core/constants/constants.dart';
import '../../domains/entities/order_entity.dart';
import '../../domains/entities/order_menu_item.dart';

@RoutePage()
class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  bool showCompleted = false;
  bool isDarkMode = false;

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      context.read<AuthBloc>().add(AuthLoggedOut());
      context.router.replaceAll([const LoginRoute()]);
    }
  }

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
                        if (order.orderStatus != OrderStatus.served) return false;
                        
                        if (showCompleted) {
                          return order.paymentStatus == PaymentStatus.paid ||
                                 order.paymentStatus == PaymentStatus.prepaid;
                        } else {
                          return order.paymentStatus == PaymentStatus.unpaid;
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
                          final double contentHeight =
                              (constraints.maxHeight - (kspacing * 4))
                                  .clamp(0, double.infinity)
                                  .toDouble();

                          final columns = _buildColumns(
                            filteredOrders,
                            contentHeight > 0
                                ? contentHeight
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
                                                child: CashierOrderCard(
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
        final Color navbarColor = isDark
            ? const Color(0xFF1B1B1B)
            : const Color(0xFF2D2D2D);
        final Color controlBg = isDark
            ? const Color(0xFF2E2E2E)
            : const Color(0xFF4A4A4A);
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
        state.userRestaurant?.user.roleName?.toUpperCase() ?? "CAISSE";
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
            "$stationName",
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
        final Color containerColor = isDark
            ? const Color(0xFF2E2E2E)
            : const Color(0xFF4A4A4A);
        final openCount = state.orders
            .where((o) => o.paymentStatus == PaymentStatus.unpaid && o.orderStatus == OrderStatus.served)
            .length;
        final completedCount = state.orders
            .where((o) =>
                (o.paymentStatus == PaymentStatus.paid ||
                o.paymentStatus == PaymentStatus.prepaid) && o.orderStatus == OrderStatus.served)
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
                activeColor: isDark ? const Color(0xFFE0E0E0) : Colors.white,
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
      onSelected: (value) async {
        if (value == 'logout') {
          await _confirmLogout();
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Déconnexion'),
        ),
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

class CashierOrderCard extends StatelessWidget {
  final _CardSlot slot;

  const CashierOrderCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final order = slot.order;
    final bool isUnpaid = order.paymentStatus == PaymentStatus.unpaid;
    final bool isPaid =
        order.paymentStatus == PaymentStatus.paid ||
        order.paymentStatus == PaymentStatus.prepaid;
    
    final Color headerColor = isPaid
        ? primaryColor
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
                    Icons.payments,
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
                        order.server?.fullName ??
                            order.server?.username ??
                            "Serveur",
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
            _buildContinuedIndicator(context, "Suite...", Icons.arrow_upward),
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
          // Details (Total Amount) and Actions
          if (slot.showButton) ...[
            Padding(
              padding: const EdgeInsets.all(kspacing),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Total: ${(order.totalAmount).toStringAsFixed(0)} Ar",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (isUnpaid)
              Padding(
                padding: const EdgeInsets.fromLTRB(kspacing, 0, kspacing, kspacing),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OrdersBloc>().add(
                      OrderUpdated(order.copyWith(paymentStatus: PaymentStatus.paid)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: kspacing * 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Payer", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
          // Continued Bottom
          if (slot.showContinuedBottom)
            _buildContinuedIndicator(context, "Suite...", Icons.arrow_downward),
          
          if (isPaid)
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
                    "Payé",
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
                style: TextStyle(
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
              const SizedBox(width: kspacing),
              Text(
                "${(item.unitPrice * item.quantity).toStringAsFixed(0)} Ar",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: kspacing * 3),
              child: Text(
                "${item.notes}",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
        ],
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
  const double headerHeight = 40;
  const double subHeaderHeight = 100;
  const double dividerHeight = 1;
  const double continuedHeight = 20;
  const double buttonHeight = 100; // Increased to factor in total amount AND Payer button
  const double cardGap = kspacing * 2;

  double itemHeight(OrderMenuItem item) {
    double h = 21;
    if (item.notes != null && item.notes!.isNotEmpty) {
      h += 11;
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
      final double headerBlockHeight = isFirstSlice
          ? (headerHeight + subHeaderHeight + dividerHeight)
          : 0;
      final double minNeeded =
          headerBlockHeight +
          (isFirstSlice ? 0 : continuedHeight) +
          itemHeight(remaining.first) +
          continuedHeight;

      if (available < minNeeded) {
        columns.add([]);
        usedHeight = 0;
        available = columnHeight;
      }

      final List<OrderMenuItem> slice = [];
      double sliceHeight =
          headerBlockHeight + (isFirstSlice ? 0 : continuedHeight);
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

      if (slice.isEmpty) {
        // Prevent infinite loop if an item is simply too tall for an empty column
        if (available == columnHeight) {
          slice.add(remaining.first);
        } else {
          columns.add([]);
          usedHeight = 0;
          continue;
        }
      }

      final bool isLastForOrder = slice.length == remaining.length;
      
      columns.last.add(
        _CardSlot(
          order: order,
          items: slice,
          showContinuedTop: !isFirstSlice,
          showContinuedBottom: !isLastForOrder,
          showButton: isLastForOrder,
        ),
      );

      usedHeight += sliceHeight + (isLastForOrder ? buttonHeight : continuedHeight) + cardGap;
      remaining = remaining.sublist(slice.length);
      isFirstSlice = false;
    }
  }

  if (columns.last.isEmpty && columns.length > 1) {
    columns.removeLast();
  }

  return columns;
}
