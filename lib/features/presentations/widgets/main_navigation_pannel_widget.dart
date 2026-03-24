import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/main_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/custom_container.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';
import 'logo.dart';
import 'nav_links.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domains/entities/user_entity.dart';
import '../managers/auths/auth_bloc.dart';

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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final role = state.userRestaurant?.user.role;
        const menuGap = 2.0;
        return SafeArea(
          bottom: false,
          child: CustomContainer(
            width: 350,
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
                   Text('ROLE: ${role.toString()}', style: TextStyle(color: Colors.white)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: kspacing * 3,
                      vertical: kspacing * 2,
                    ),
                    child: Logo(),
                  ),


                  ...navLinks(currentRoute, role).map(
                    (link) => Padding(
                      padding: EdgeInsets.only(bottom: menuGap),
                      child: link,
                    ),
                  ),
                  const Spacer(),
                  NavLink(
                    label: 'Commande',
                    icon: const CircleAvatar(child: Text('M')),
                    destination: const OrdersRoute(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: kspacing * 3),
                    child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -4),
                      title: Text(
                        'Profil',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: grey,
                          fontSize: 16,
                        ),
                      ),
                      trailing: const CircleAvatar(child: Text('M')),
                      onTap: () => context.router.push(const ProfileRoute()),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: kspacing * 3),
                    child: ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -4),
                      trailing: const Icon(Icons.logout),
                      title: Text(
                        'Se déconnecter',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: grey,
                          fontSize: 16,
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
      },
    );
  }
}
