import 'package:domain/entities/customer_order_entity.dart';
import 'package:domain/entities/customer_reservation_entity.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/discover/discover_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/order/my_orders_page.dart';
import '../../presentation/pages/order/order_detail_page.dart';
import '../../presentation/pages/order/order_request_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/reservation/my_reservations_page.dart';
import '../../presentation/pages/reservation/reservation_detail_page.dart';
import '../../presentation/pages/reservation/reservation_request_page.dart';
import '../../presentation/pages/restaurant/restaurant_detail_page.dart';
import '../../presentation/pages/search/search_page.dart';
import '../../presentation/widgets/main_shell.dart';
import 'route_paths.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.discover,
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          MainShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: RoutePaths.discover,
          pageBuilder: (_, __) => const NoTransitionPage(child: DiscoverPage()),
        ),
        GoRoute(
          path: RoutePaths.search,
          pageBuilder: (_, state) => NoTransitionPage(
            child: SearchPage(initialQuery: state.uri.queryParameters['q']),
          ),
        ),
        GoRoute(
          path: RoutePaths.bookings,
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: MyReservationsPage()),
        ),
        GoRoute(
          path: RoutePaths.profile,
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.authLogin,
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: RoutePaths.authRegister,
      builder: (_, __) => const RegisterPage(),
    ),
    GoRoute(
      path: '${RoutePaths.restaurant}/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return RestaurantDetailPage(restaurantId: id);
      },
      routes: [
        GoRoute(
          path: 'reserve',
          builder: (_, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra;
            return ReservationRequestPage(
              restaurantId: id,
              initialRestaurant:
                  extra is RestaurantPublicEntity ? extra : null,
            );
          },
        ),
        GoRoute(
          path: 'order',
          builder: (_, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra;
            return OrderRequestPage(
              restaurantId: id,
              initialRestaurant:
                  extra is RestaurantPublicEntity ? extra : null,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.favorites,
      builder: (_, __) => const FavoritesPageGate(),
    ),
    GoRoute(
      path: RoutePaths.reservations,
      builder: (_, __) => const MyReservationsPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra;
            return ReservationDetailPage(
              reservationId: id,
              initial:
                  extra is CustomerReservationEntity ? extra : null,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: RoutePaths.orders,
      builder: (_, __) => const MyOrdersPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) {
            final id = int.parse(state.pathParameters['id']!);
            final extra = state.extra;
            return OrderDetailPage(
              orderId: id,
              initial: extra is CustomerOrderEntity ? extra : null,
            );
          },
        ),
      ],
    ),
  ],
);
