import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/notifications/notification_cubit.dart';
import '../bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import 'make_order_page.dart';
import 'notifications_page.dart';
import 'order_card_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'tables_page.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell shell;
  const MainPage({required this.shell, super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final PageController _pageController;

  /// True while a tab-tap animation is in progress.
  /// Prevents [_onPageChanged] from calling [goBranch] for intermediate pages.
  bool _programmaticChange = false;

  static const _pages = [
    MakeOrderPage(),
    OrderCardPage(),
    OrdersPage(),
    TablesPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.shell.currentIndex);
  }

  @override
  void didUpdateWidget(MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.shell.currentIndex;
    if (oldWidget.shell.currentIndex != newIndex &&
        _pageController.page?.round() != newIndex) {
      _programmaticChange = true;
      _pageController
          .animateToPage(
            newIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) {
            if (mounted) _programmaticChange = false;
          });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // Ignore intermediate pages triggered by a programmatic animateToPage.
    if (_programmaticChange) return;
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
  }

  void _onTabTap(int index) {
    // Only update the shell; didUpdateWidget will drive the PageController.
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages.map((page) => _KeepAlivePage(child: page)).toList(),
      ),
      bottomNavigationBar: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, notifState) {
          final unreadCount = notifState is NotificationLoaded
              ? notifState.unreadCount
              : 0;
          return BlocBuilder<OrderMenuItemBloc, OrderMenuItemState>(
            builder: (context, state) {
              final cartCount = state.orderedItems.fold(
                0,
                (sum, i) => sum + i.quantity,
              );
              return BottomNavigationBar(
                currentIndex: widget.shell.currentIndex,
                onTap: _onTabTap,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.add_outlined),
                    activeIcon: Icon(Icons.add),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: cartCount > 0,
                      label: Text('$cartCount'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    activeIcon: Badge(
                      isLabelVisible: cartCount > 0,
                      label: Text('$cartCount'),
                      child: const Icon(Icons.shopping_cart),
                    ),
                    label: '',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: '',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.table_restaurant_outlined),
                    activeIcon: Icon(Icons.table_restaurant),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text('$unreadCount'),
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    activeIcon: Badge(
                      isLabelVisible: unreadCount > 0,
                      label: Text('$unreadCount'),
                      child: const Icon(Icons.notifications),
                    ),
                    label: '',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outlined),
                    activeIcon: Icon(Icons.person),
                    label: '',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
