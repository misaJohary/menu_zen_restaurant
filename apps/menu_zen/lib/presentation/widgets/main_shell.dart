import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/navigation/route_paths.dart';
import '../../l10n/generated/app_localizations.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index = _indexFor(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(PhosphorIconsRegular.compass),
            selectedIcon: const Icon(PhosphorIconsFill.compass),
            label: l10n.navDiscover,
          ),
          NavigationDestination(
            icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
            selectedIcon: const Icon(PhosphorIconsFill.magnifyingGlass),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(PhosphorIconsRegular.bookmarkSimple),
            selectedIcon: const Icon(PhosphorIconsFill.bookmarkSimple),
            label: l10n.navBookings,
          ),
          NavigationDestination(
            icon: const Icon(PhosphorIconsRegular.user),
            selectedIcon: const Icon(PhosphorIconsFill.user),
            label: l10n.navProfile,
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
