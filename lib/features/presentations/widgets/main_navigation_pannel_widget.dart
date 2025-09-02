import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/main_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/custom_container.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';
import 'logo.dart';
import 'nav_links.dart';

class MainNavigationPannelWidget extends StatelessWidget {
  const MainNavigationPannelWidget({
    super.key,
    required this.currentRoute,
    required this.controller,
    required this.onHidePressed,
  });

  final String currentRoute;
  final MainController controller;
  final VoidCallback onHidePressed;

  @override
  Widget build(BuildContext context) {
    final menuGap = kspacing;
    return SafeArea(
      bottom: false,
      child: CustomContainer(
        width: 300,
        height: double.infinity,
        margin: const EdgeInsets.all(8.0),
        padding: EdgeInsets.symmetric(vertical: kspacing * 2),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: kspacing * 3,
                  vertical: kspacing * 5,
                ),
                child: Logo(),
              ),

              ...navLinks(currentRoute).map(
                (link) => Padding(
                  padding: EdgeInsets.only(bottom: menuGap),
                  child: link,
                ),
              ),
              Spacer(),
              NavLink(
                label: 'Commande',
                icon: CircleAvatar(child: Text('M')),
                destination: OrdersRoute(),
                //destination: const MakeOrderRoute(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kspacing * 3),
                child: ListTile(
                  title: Text(
                    'Profil',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: grey,
                      fontSize: 18,
                    ),
                  ),
                  trailing: CircleAvatar(child: Text('M')),
                  onTap: () {},
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kspacing * 3),
                child: ListTile(
                  trailing: Icon(Icons.logout),
                  title: Text(
                    'Se déconnecter',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: grey,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    controller.logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
