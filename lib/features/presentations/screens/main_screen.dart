import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/scheduler.dart';

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
    controller= MainController(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              return MainNavigationPannelWidget(currentRoute: controller.currentRoute);
            },
          ),
          Expanded(child: AutoRouter(
            navigatorObservers:() => [MyObserver(controller)],
          )),
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