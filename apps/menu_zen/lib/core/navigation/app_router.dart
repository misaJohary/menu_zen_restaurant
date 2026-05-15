import 'package:go_router/go_router.dart';

import '../../presentation/pages/bookings/bookings_placeholder_page.dart';
import '../../presentation/pages/discover/discover_page.dart';
import '../../presentation/pages/profile/profile_placeholder_page.dart';
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
              const NoTransitionPage(child: BookingsPlaceholderPage()),
        ),
        GoRoute(
          path: RoutePaths.profile,
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: ProfilePlaceholderPage()),
        ),
      ],
    ),
  ],
);
