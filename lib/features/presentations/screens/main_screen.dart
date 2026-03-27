import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domains/entities/user_entity.dart';
import '../managers/auths/auth_bloc.dart';
import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';

import '../controllers/main_controller.dart';
import '../widgets/main_navigation_pannel_widget.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MainController controller;

  @override
  void initState() {
    super.initState();
    controller = MainController(context);
    // Fetch full user info (including role) as soon as we enter the main screen
    context.read<AuthBloc>().add(AuthUserGot());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final user = authState.userRestaurant?.user;
                    final isCook = user?.role == Role.cook;
                    final isCashier = user?.role == Role.cashier;
                    final isServer = user?.role == Role.server;
                    final isStaff = isCook || isCashier || isServer;

                    // Auto redirect staff to their respective page if they are on dashboard
                    if (isStaff && controller.currentRoute == 'DashboardRoute') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (isCook) {
                          context.router.replaceAll([const KdsRoute()]);
                        } else if (isCashier) {
                          context.router.replaceAll([const CashierRoute()]);
                        } else {
                          context.router.replaceAll([const OrdersRoute()]);
                        }
                      });
                    }

                    return ListenableBuilder(
                      listenable: controller,
                      builder: (context, child) {
                        final shouldHide = controller.hidePannel || isStaff;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: shouldHide
                              ? const SizedBox.shrink()
                              : MainNavigationPannelWidget(
                                  currentRoute: controller.currentRoute,
                                  controller: controller,
                                  onHidePressed: () {
                                    context.router.push(MakeOrderRoute());
                                  },
                                ),
                        );
                      },
                    );
                  },
                ),

                Expanded(
                  child: AutoRouter(
                    navigatorObservers: () => [MyObserver(controller)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class MyObserver extends AutoRouterObserver {
  final MainController controller;

  MyObserver(this.controller);

  @override
  void didPush(Route route, Route? previousRoute) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller.changeCurrentRoute(route.settings.name ?? 'DashboardRoute');
    });
  }
}
