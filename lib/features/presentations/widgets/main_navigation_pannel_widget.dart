import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/main_controller.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';
import 'nav_links.dart';

class MainNavigationPannelWidget extends StatefulWidget {
  const MainNavigationPannelWidget({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  State<MainNavigationPannelWidget> createState() => _MainNavigationPannelWidgetState();
}

class _MainNavigationPannelWidgetState extends State<MainNavigationPannelWidget> {

  late MainController controller;
  @override
  void initState() {
    super.initState();
    controller = MainController(context);
  }
  @override
  Widget build(BuildContext context) {
    final menuGap = kspacing;
    return SafeArea(
      bottom: false,
      child: Container(
        width: 80,
        height: double.infinity,
        margin: const EdgeInsets.all(8.0),
        padding: EdgeInsets.symmetric(vertical: kspacing *2),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: ThemeData(
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                iconSize: 30,
              ),
            ),
          ),
          child: Column(
            children: [
              ...navLinks(widget.currentRoute).map(
                (link) => Padding(
                  padding: EdgeInsets.only(bottom: menuGap),
                  child: link,
                ),
              ),
              Spacer(),
              IconButton(icon: Icon(Icons.settings), onPressed: () {}),
              IconButton(icon: Icon(Icons.logout_rounded), onPressed: () {
                controller.logout();
              }),
              NavLink(
                label: 'Profil',
                icon: CircleAvatar(child: Text('M')),
                isSelected: widget.currentRoute == '',
                destination: const DashboardRoute(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
