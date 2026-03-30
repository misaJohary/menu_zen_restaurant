import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';
import '../../domains/entities/user_entity.dart';

class NavLink extends StatelessWidget {
  const NavLink({
    super.key,
    required this.iconPath,
    this.label,
    this.isSelected = false,
    required this.destination,
  });

  final PageRouteInfo destination;
  final String? label;
  final bool isSelected;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: kspacing * 2,
            vertical: 4,
          ),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -1),
            leading: SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(
                isSelected ? primaryColor : grey,
                BlendMode.srcIn,
              ),
              width: 24,
              height: 24,
            ),
            title: Text(
              label ?? '',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: isSelected ? primaryColor : grey,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            onTap: () {
              context.router.push(destination);
            },
          ),
        ),
        if (isSelected)
          Positioned(
            right: 0,
            top: 12,
            bottom: 12,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

List<Widget> navLinks(String currentRoute, Role? role) => [
  NavLink(
    label: 'Dashboard',
    iconPath: 'assets/icons/dashboard.svg',
    isSelected: currentRoute == DashboardRoute.name,
    destination: const DashboardRoute(),
  ),
  NavLink(
    label: 'Menus',
    iconPath: 'assets/icons/menus.svg',
    isSelected: currentRoute == MenuRoute.name,
    destination: const MenuRoute(),
  ),
  NavLink(
    label: 'Catégories',
    iconPath: 'assets/icons/categories.svg',
    isSelected: currentRoute == CategoriesRoute.name,
    destination: const CategoriesRoute(),
  ),
  NavLink(
    label: 'Food',
    iconPath: 'assets/icons/food.svg',
    isSelected: currentRoute == MenuItemRoute.name,
    destination: const MenuItemRoute(),
  ),
  NavLink(
    label: 'Tables',
    iconPath: 'assets/icons/tables.svg',
    isSelected: currentRoute == TablesRoute.name,
    destination: const TablesRoute(),
  ),
  NavLink(
    label: 'Commande',
    iconPath: 'assets/icons/commandes.svg',
    isSelected: currentRoute == OrdersRoute.name,
    destination: const OrdersRoute(),
  ),
  if (role == Role.admin || role == Role.superAdmin)
    NavLink(
      label: 'Utilisateurs',
      iconPath: 'assets/icons/user.svg', // Fallback for Users
      isSelected: currentRoute == UsersRoute.name,
      destination: const UsersRoute(),
    ),
];
