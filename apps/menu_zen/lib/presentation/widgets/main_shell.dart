import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/navigation/route_paths.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final index = _indexFor(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: const [
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.compass),
            selectedIcon: Icon(PhosphorIconsFill.compass),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.magnifyingGlass),
            selectedIcon: Icon(PhosphorIconsFill.magnifyingGlass),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.bookmarkSimple),
            selectedIcon: Icon(PhosphorIconsFill.bookmarkSimple),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIconsRegular.user),
            selectedIcon: Icon(PhosphorIconsFill.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static const _paths = [
    RoutePaths.discover,
    RoutePaths.search,
    RoutePaths.bookings,
    RoutePaths.profile,
  ];

  int _indexFor(String path) {
    if (path.startsWith(RoutePaths.search)) return 1;
    if (path.startsWith(RoutePaths.bookings)) return 2;
    if (path.startsWith(RoutePaths.profile)) return 3;
    return 0;
  }
}
