import 'package:domain/entities/order_entity.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:data/services/db_service.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/main_page.dart';
import '../../presentation/pages/make_order_page.dart';
import '../../presentation/pages/order_card_page.dart';
import '../../presentation/pages/orders_page.dart';
import '../../presentation/pages/order_detail_page.dart';
import '../../presentation/pages/notifications_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../../presentation/pages/tables_page.dart';
import '../injection/dependencies_injection.dart';

/// Global router instance — used by the local-notification tap handler
/// to navigate without a BuildContext.
GoRouter? appRouter;

/// Route stored during cold-start (app was killed) before the router exists.
/// Drained by the router's [redirect] on the first navigation.
String? pendingNotificationRoute;

GoRouter buildRouter({required GlobalKey<NavigatorState> navigatorKey}) {
  appRouter = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/main/commande',
    redirect: (context, state) async {
      final db = getIt<DbService>();
      final isAuth = await db.checkAuth();
      final isLoginPage = state.uri.path.startsWith('/login');
      if (!isAuth && !isLoginPage) return '/login';
      if (isAuth && isLoginPage) return '/main/commande';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainPage(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/commande',
                builder: (context, state) => const MakeOrderPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/panier',
                builder: (context, state) => const OrderCardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/commandes',
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/tables',
                builder: (context, state) => const TablesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/order-detail/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OrderDetailPage(orderId: id);
        },
      ),
      GoRoute(
        path: '/make-order-edit',
        builder: (context, state) {
          final order = state.extra as OrderEntity?;
          return MakeOrderPage(order: order);
        },
      ),
    ],
  );
  return appRouter!;
}
