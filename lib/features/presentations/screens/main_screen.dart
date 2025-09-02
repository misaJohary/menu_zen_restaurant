import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/scheduler.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                ListenableBuilder(
                  listenable: controller,
                  builder: (context, child) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 1000),
                      child: controller.hidePannel ? SizedBox.shrink(): MainNavigationPannelWidget(
                        currentRoute: controller.currentRoute,
                        controller: controller,
                        onHidePressed: (){
                          context.router.push(MakeOrderRoute());
                        },
                      ),
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
          //Divider(indent: 500, endIndent: 500),
          //Image.asset('assets/images/divider.png', width: 150,),
          RichText(
            text: TextSpan(
              text: 'Powered by ',
              style: Theme.of(context).textTheme.labelMedium,
              children: [
                TextSpan(
                  text: 'Click Menu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                TextSpan(
                  text: ' ZEN ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                WidgetSpan(
                  child: Image.asset('assets/images/leaf.png', width: 15),
                ),
              ],
            ),
          ),
          SizedBox(height: kspacing * 4),
          //Text('Powered By CLICK MENU ZEN')),
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
