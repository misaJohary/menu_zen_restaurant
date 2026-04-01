import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/auths/auth_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/orders_bloc.dart';

import '../../../core/constants/constants.dart';
import '../../../core/injection/dependencies_injection.dart';
import '../../../core/services/ws_service.dart';
import '../../datasources/models/order_model.dart';
import '../../domains/entities/order_entity.dart';
import '../../domains/entities/order_menu_item.dart';
import '../widgets/logo.dart';

@RoutePage()
class KdsScreen extends StatefulWidget {
  const KdsScreen({super.key});

  @override
  State<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends State<KdsScreen> {
  late final RestaurantWebSocketService _wsService;
  StreamSubscription<dynamic>? _wsSubscription;

  bool showCompleted = false;
  bool isDarkMode = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeWebSocket() async {
    _wsService = getIt<RestaurantWebSocketService>();

    try {
      final channel = await _wsService.connect();
      _wsSubscription = channel?.stream.listen(
        (message) {
          final data = jsonDecode(message);
          switch (data['type']) {
            case 'connection_established':
              break;
            case 'update_order_status':
              _handleUpdateOrderStatus(context, data);
              break;
            case 'new_order':
              _handleNewOrder(context, data);
              break;
            case 'order_deleted':
              _handleOrderDeleted(context, data);
              break;
            case 'order_updated':
              _handleOrderUpdated(context, message);
              break;
            case 'update_order_menu_item_status':
              _handleUpdateOrderMenuItemStatus(context, data);
              break;
          }
        },
        onError: (error) => (),
        onDone: () => (),
      );
    } catch (e) {
      return;
    }
  }

  void _handleNewOrder(BuildContext context, message) {
    _audioPlayer.play(AssetSource('sounds/new_order.ogg'));
    context.read<OrdersBloc>().add(
      OrderAdded(OrderModel.fromJson(json.decode(message['order']))),
    );
  }

  void _handleUpdateOrderStatus(BuildContext context, message) {
    context.read<OrdersBloc>().add(
      OrderStatusRemoteUpdated(
        message['order_id'],
        OrderStatus.fromString(message['new_status']),
      ),
    );
  }

  void _handleUpdateOrderMenuItemStatus(BuildContext context, message) {
    context.read<OrdersBloc>().add(
      OrderMenuItemStatusRemoteUpdated(
        message['order_id'],
        message['item_id'],
        message['new_status'],
      ),
    );
  }

  void _handleOrderDeleted(BuildContext context, message) {
    context.read<OrdersBloc>().add(OrderRemoteDeleted(message['order_id']));
  }

  void _handleOrderUpdated(BuildContext context, message) {
    context.read<OrdersBloc>().add(
      OrderRemoteUpdated(OrderModel.fromJson(json.decode(message['order']))),
    );
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

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kspacing * 2,
            vertical: kspacing / 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (state.userRestaurant != null)
                Logo(imageUrl: state.userRestaurant!.restaurant.logo)
              else
                const SizedBox(height: 40),
              const SizedBox(width: kspacing * 1.5),
              Text(
                "Cuisinier",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(kspacing),
              ),
              const SizedBox(width: kspacing),
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

        final openCountStr = openCount.toString().padLeft(2, '0');
        final completedCountStr = completedCount.toString().padLeft(2, '0');

        return Row(
          children: [
            _buildTabButton(
              label: "$openCountStr Ouvertes",
              isActive: !showCompleted,
              onTap: () => setState(() => showCompleted = false),
              activeColor: const Color(0xFFD1D1EB),
              iconColor: const Color(0xFF3F51B5),
            ),
            const SizedBox(width: kspacing * 2),
            _buildTabButton(
              label: "$completedCountStr Terminées",
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

class KdsOrderCard extends StatelessWidget {
  final CardSlot slot;

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
          // Header
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
                      _buildStatusChip(context, order.orderStatus),
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
          // Continued Top
          if (slot.showContinuedTop)
            _buildContinuedIndicator(context, "Suite...", Icons.arrow_upward),
          // Items
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
          // Continued Bottom
          if (slot.showContinuedBottom)
            _buildContinuedIndicator(context, "Suite...", Icons.arrow_downward),
          // Action Buttons
          if (slot.showButton)
            if (isInProgress)
              _buildLargeActionButton(
                context,
                "Terminer",
                const Color(0xFF9CCC65),
                OrderStatus.ready,
              )
            else if (order.orderStatus == OrderStatus.created)
              _buildLargeActionButton(
                context,
                "DÉMARRER",
                const Color(0xFF757575),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isStarted = order.orderStatus == OrderStatus.inPreparation;
    final bool isReady = item.status == 'ready';
    final bool canToggle = isStarted && order.id != null && item.id != null;
    final String nextStatus = isReady ? 'init' : 'ready';
    final TextDecoration? decoration = isReady
        ? TextDecoration.lineThrough
        : null;
    final Color readyColor = const Color(0xFFF36D21);
    final Color? textColor = isReady ? readyColor : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kspacing / 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canToggle
            ? () {
                context.read<OrdersBloc>().add(
                  OrderMenuItemStatusUpdated(order.id!, item.id!, nextStatus),
                );
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    "${item.quantity}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      decoration: decoration,
                      color: textColor,
                    ),
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
                    isReady ? Icons.check_circle : Icons.radio_button_unchecked,
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
                    color: isReady
                        ? readyColor
                        : (isDark ? Colors.white60 : Colors.black54),
                    decoration: decoration,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color color;
    String label;
    switch (status) {
      case OrderStatus.inPreparation:
        color = const Color(0xFF2196F3);
        label = "EN PRÉPARATION";
        break;
      case OrderStatus.ready:
        color = const Color(0xFF4CAF50);
        label = "PRÊT";
        break;
      case OrderStatus.created:
        color = const Color(0xFF9E9E9E);
        label = "EN ATTENTE";
        break;
      default:
        color = const Color(0xFF9E9E9E);
        label = status.name.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLargeActionButton(
    BuildContext context,
    String label,
    Color color,
    OrderStatus nextStatus,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kspacing * 2,
        vertical: kspacing * 2,
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<OrdersBloc>().add(
            OrderStatusUpdated(slot.order.id!, nextStatus),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: kspacing * 0.75),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
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
  const double headerHeight = 40;
  const double subHeaderHeight = 100;
  const double dividerHeight = 1;
  const double continuedHeight = 20;
  const double buttonHeight = 54;
  const double cardGap = kspacing * 2;

  double itemHeight(OrderMenuItem item) {
    double h = 21;
    if (item.notes != null && item.notes!.isNotEmpty) {
      h += 11;
    }
    return h;
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
        slice.add(remaining.first);
        willContinue = remaining.length > 1;
      }

      if (!willContinue) {
        sliceHeight += buttonHeight;
      } else {
        sliceHeight += continuedHeight;
      }

      columns.last.add(
        CardSlot(
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
