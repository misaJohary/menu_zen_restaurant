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
import '../widgets/logo.dart';
import '../widgets/payment_summary_dialog.dart';

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
      if (!context.mounted) return;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(kspacing * 2),
                    child: _buildNavbar(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kspacing * 3),
                  child: _buildStatusToggles(),
                ),
                const SizedBox(height: kspacing * 2),
                Expanded(
                  child: BlocBuilder<OrdersBloc, OrdersState>(
                    builder: (context, state) {
                      if (state.status == BlocStatus.loading &&
                          state.orders.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final filteredOrders = state.orders.where((order) {
                        if (order.orderStatus != OrderStatus.served) {
                          return false;
                        }

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
      scaffoldBackgroundColor: const Color(0xFFF5F9F4),
      dividerColor: const Color(0xFFE0E0E0),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF9CCC65),
        secondary: const Color(0xFF90CAF9),
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
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
        final user = state.userRestaurant?.user;
        final initials =
            (user?.firstname != null &&
                user!.firstname!.isNotEmpty &&
                user.lastname != null &&
                user.lastname!.isNotEmpty)
            ? "${user.firstname![0]}${user.lastname![0]}".toUpperCase()
            : (user?.fullName?.isNotEmpty ?? false
                      ? user!.fullName![0]
                      : (user?.username.isNotEmpty ?? false
                            ? user!.username[0]
                            : "?"))
                  .toUpperCase();

        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kspacing * 2,
            vertical: kspacing / 2,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Logo(),
              const SizedBox(width: kspacing * 1.5),
              Text(
                "Caissier",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isDarkMode,
                    onChanged: (value) => setState(() => isDarkMode = value),
                    activeThumbColor: const Color(0xFF2E7D32),
                  ),
                ],
              ),
              const SizedBox(width: kspacing * 2),
              GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    'https://flagcdn.com/w40/fr.png',
                    width: 24,
                    height: 18,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: kspacing * 2),
              GestureDetector(
                onTap: () => context.router.push(const ProfileRoute()),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: kspacing),
              IconButton(
                onPressed: () => _confirmLogout(),
                icon: const Icon(Icons.logout),
                color: const Color(0xFF9CCC65),
                padding: const EdgeInsets.all(kspacing),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusToggles() {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final openCount = state.orders
            .where(
              (o) =>
                  o.paymentStatus == PaymentStatus.unpaid &&
                  o.orderStatus == OrderStatus.served,
            )
            .length;
        final completedCount = state.orders
            .where(
              (o) =>
                  (o.paymentStatus == PaymentStatus.paid ||
                      o.paymentStatus == PaymentStatus.prepaid) &&
                  o.orderStatus == OrderStatus.served,
            )
            .length;

        final openCountStr = openCount.toString().padLeft(2, '0');
        final completedCountStr = completedCount.toString().padLeft(2, '0');

        return Row(
          children: [
            _buildTabButton(
              label: "$openCountStr ( À Payer )",
              isActive: !showCompleted,
              onTap: () => setState(() => showCompleted = false),
              activeColor: const Color(0xFFD1D1EB),
              iconColor: const Color(0xFF3F51B5),
            ),
            const SizedBox(width: kspacing * 2),
            _buildTabButton(
              label: "$completedCountStr ( Terminées )",
              isActive: showCompleted,
              onTap: () => setState(() => showCompleted = true),
              activeColor: const Color(0xFFFFE0B2),
              iconColor: const Color(0xFFF36D21),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kspacing * 2,
            vertical: kspacing * 0.75,
          ),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? activeColor : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CashierOrderCard extends StatelessWidget {
  final CardSlot slot;

  const CashierOrderCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final order = slot.order;
    final bool isUnpaid = order.paymentStatus == PaymentStatus.unpaid;
    final bool isPaid =
        order.paymentStatus == PaymentStatus.paid ||
        order.paymentStatus == PaymentStatus.prepaid;

    final String timeStr = order.createdAt != null
        ? DateFormat('hh:mm a').format(order.createdAt!)
        : '--:--';
    final bool showHeader = !slot.showContinuedTop;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.all(kspacing * 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      order.rTable?.name ?? "T-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: kspacing * 1.5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName ?? "Client",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: kspacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Commande #${order.id}",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.payments,
                        color: isPaid ? const Color(0xFF9CCC65) : Colors.grey,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: kspacing * 2),
              child: Divider(height: 1),
            ),
          ],
          if (slot.showContinuedTop)
            _buildContinuedIndicator(context, "Suite...", Icons.arrow_upward),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kspacing * 2),
            child: Column(
              children: [
                for (final item in slot.items)
                  _buildOrderItem(context, slot.order, item),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: kspacing * 2),
            child: Divider(height: 1),
          ),

          if (slot.showContinuedBottom)
            _buildContinuedIndicator(context, "Suite...", Icons.arrow_downward),

          if (slot.showButton) ...[
            Padding(
              padding: const EdgeInsets.all(kspacing * 2),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${(order.totalAmount).toStringAsFixed(0)} Ar",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (isUnpaid) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) =>
                              PaymentSummaryDialog(order: order),
                        );

                        if (result != null) {
                          if (!context.mounted) return;
                          context.read<OrdersBloc>().add(
                            OrderUpdated(
                              order.copyWith(paymentStatus: PaymentStatus.paid),
                            ),
                          );

                          if (result['action'] == 'print_and_pay') {
                            // TODO: Implement printing logic
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9CCC65),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: const Size(double.infinity, 44),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Payer",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (isPaid && slot.showButton)
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
                    color: const Color(0xFF9CCC65),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Payé",
                    style: TextStyle(
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
      padding: const EdgeInsets.symmetric(
        horizontal: kspacing * 2,
        vertical: 4,
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kspacing / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              "${item.quantity}",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
          const SizedBox(width: kspacing * 1.5),
          Expanded(
            child: Text(
              item.menuItem.translations.isNotEmpty
                  ? item.menuItem.translations.first.name
                  : 'Nom',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: kspacing),
          Text(
            "${(item.unitPrice * item.quantity).toStringAsFixed(0)} Ar",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class CardSlot {
  final OrderEntity order;
  final List<OrderMenuItem> items;
  final bool showContinuedTop;
  final bool showContinuedBottom;
  final bool showButton;

  CardSlot({
    required this.order,
    required this.items,
    required this.showContinuedTop,
    required this.showContinuedBottom,
    required this.showButton,
  });
}

List<List<CardSlot>> _buildColumns(
  List<OrderEntity> orders,
  double columnHeight,
) {
  const double headerHeight = 77;
  const double dividerHeight = 1;
  const double continuedHeight = 24;
  const double buttonHeight = 110;
  const double cardGap = kspacing * 2;

  double itemHeight(OrderMenuItem item) {
    return 29;
  }

  final List<List<CardSlot>> columns = [[]];
  double usedHeight = 0;

  for (final order in orders) {
    List<OrderMenuItem> remaining = List<OrderMenuItem>.from(
      order.orderMenuItems,
    );
    bool isFirstSlice = true;

    while (remaining.isNotEmpty) {
      double available = columnHeight - usedHeight - cardGap;
      final double headerBlockHeight = isFirstSlice
          ? (headerHeight + dividerHeight)
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

      for (int i = 0; i < remaining.length; i++) {
        final double nextItemH = itemHeight(remaining[i]);
        final bool isLast = i == remaining.length - 1;
        final double needed =
            nextItemH + (isLast ? buttonHeight : continuedHeight);

        if (sliceHeight + needed <= available) {
          sliceHeight += nextItemH;
          slice.add(remaining[i]);
        } else {
          break;
        }
      }

      if (slice.isEmpty) {
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
        CardSlot(
          order: order,
          items: slice,
          showContinuedTop: !isFirstSlice,
          showContinuedBottom: !isLastForOrder,
          showButton: isLastForOrder,
        ),
      );

      usedHeight +=
          sliceHeight +
          (isLastForOrder ? buttonHeight : continuedHeight) +
          cardGap;
      remaining = remaining.sublist(slice.length);
      isFirstSlice = false;
    }
  }

  if (columns.last.isEmpty && columns.length > 1) {
    columns.removeLast();
  }

  return columns;
}
