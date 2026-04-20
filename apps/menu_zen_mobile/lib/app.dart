import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:data/models/order_model.dart';
import 'package:domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/http_connexion/interceptors.dart';
import 'core/injection/dependencies_injection.dart';
import 'core/navigation/app_router.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/notifications/notification_cubit.dart';
import 'presentation/bloc/orders/orders_bloc.dart';
import 'presentation/bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import 'presentation/bloc/tables/table_bloc.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  App({super.key}) {
    // Provide the navigator key to interceptors for 403 dialogs.
    appNavigatorKey = _navigatorKey;
  }

  late final _router = buildRouter(navigatorKey: _navigatorKey);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<OrdersBloc>()),
        BlocProvider(create: (_) => getIt<OrderMenuItemBloc>()),
        BlocProvider(create: (_) => getIt<TableBloc>()),
        BlocProvider(
          create: (_) => getIt<NotificationCubit>()..loadNotifications(),
        ),
      ],
      child: _AppRoot(router: _router),
    );
  }
}

/// Root widget under the BLoC providers.
///
/// Owns app-wide side-effects: the WebSocket event listener (so real-time
/// updates work on every page, not only [OrdersPage]) and draining the
/// notification deep-link that was captured before the router existed.
class _AppRoot extends StatefulWidget {
  final GoRouter router;
  const _AppRoot({required this.router});

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<Map<String, dynamic>?>? _bgServiceSub;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _requestNotificationPermission();
    _listenToBackgroundService();
    _drainPendingRoute();
  }

  void _requestNotificationPermission() {
    FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _listenToBackgroundService() {
    _bgServiceSub = FlutterBackgroundService()
        .on('ws_event')
        .cast<Map<String, dynamic>?>()
        .listen((data) {
      if (data == null || !mounted) return;
      _handleWsMessage(data);
    });
  }

  /// Pushes the deep-link captured at cold-start on top of the initial route
  /// so the back button returns to the normal app shell.
  void _drainPendingRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = pendingNotificationRoute;
      if (pending == null || appRouter == null) return;
      pendingNotificationRoute = null;
      appRouter!.push(pending);
    });
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    switch (data['type'] as String?) {
      case 'update_order_menu_item_status':
        _onItemStatusUpdate(data);
      case 'update_order_status':
        _onOrderStatusUpdate(data);
      case 'new_order':
        context.read<OrdersBloc>().add(const OrderFetched());
      case 'order_deleted':
        context.read<OrdersBloc>().add(
              OrderRemoteDeleted(data['order_id'] as int),
            );
      case 'order_updated':
        final model = OrderModel.fromJson(
          data['order'] as Map<String, dynamic>,
        );
        context.read<OrdersBloc>().add(OrderRemoteUpdated(model));
    }
  }

  void _onItemStatusUpdate(Map<String, dynamic> data) {
    final orderId = data['order_id'] as int;
    final itemId = data['item_id'] as int;
    final newStatus = data['new_status'] as String;

    context.read<OrdersBloc>().add(
          OrderMenuItemStatusRemoteUpdated(orderId, itemId, newStatus),
        );

    if (newStatus == 'ready') {
      _playAndVibrate();
      _addItemReadyNotification(orderId, itemId);
    }
  }

  void _onOrderStatusUpdate(Map<String, dynamic> data) {
    context.read<OrdersBloc>().add(
          OrderStatusRemoteUpdated(
            data['order_id'] as int,
            OrderStatus.fromString(data['new_status'] as String),
          ),
        );
    _playAndVibrate();
  }

  void _addItemReadyNotification(int orderId, int itemId) {
    final orders = context.read<OrdersBloc>().state.orders;
    final order = orders.cast<OrderEntity?>().firstWhere(
          (o) => o?.id == orderId,
          orElse: () => null,
        );
    if (order == null) return;

    final item = order.orderMenuItems.cast<dynamic>().firstWhere(
          (i) => i.id == itemId,
          orElse: () => null,
        );
    final itemName = (item != null &&
            item.menuItem.translations.isNotEmpty == true)
        ? (item.menuItem.translations.first.name as String)
        : 'Un article';
    final tableName =
        order.rTable?.name ?? 'Table ${order.restaurantTableId}';

    context.read<NotificationCubit>().addNotification(
          '$itemName est prêt à servir pour $tableName',
          orderId: orderId,
        );
  }

  void _playAndVibrate() {
    _audioPlayer.play(AssetSource('sounds/new_order.ogg'));
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _bgServiceSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Menu Zen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006D6B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF006D6B),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF006D6B),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF006D6B),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006D6B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
      routerConfig: widget.router,
    );
  }
}
