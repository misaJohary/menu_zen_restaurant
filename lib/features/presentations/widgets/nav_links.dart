import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';

class NavLink extends StatelessWidget {
  const NavLink({
    super.key,
    required this.icon,
    this.label,
    this.isSelected = false,
    required this.destination,
  });

  final PageRouteInfo destination;
  final String? label;
  final bool isSelected;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kspacing * 3),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withOpacity(.3)
            : null,
        borderRadius: BorderRadius.all(Radius.circular(kspacing)),
        border: Border(
          left: isSelected
              ? BorderSide(width: 5, color: primaryColor)
              : BorderSide.none,
        ),
      ),
      child: ListTile(
        title: Text(
          label ?? '',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: isSelected ? Colors.green : grey, fontSize: 22,
          ),
        ),
        onTap: () {
          context.router.push(destination);
        },
      ),
    );
  }
}

List<Widget> navLinks(String currentRoute) => [
  NavLink(
    label: 'Dashboard',
    icon: Icon(Icons.dashboard_rounded),
    isSelected: currentRoute == DashboardRoute.name,
    destination: const DashboardRoute(),
  ),
  NavLink(
    label: 'Menus',
    icon: Icon(Icons.menu),
    isSelected: currentRoute == MenuRoute.name,
    destination: const MenuRoute(),
  ),
  NavLink(
    label: 'Categories',
    icon: Icon(Icons.category),
    isSelected: currentRoute == CategoriesRoute.name,
    destination: const CategoriesRoute(),
  ),
  NavLink(
    label: 'Foods',
    icon: Icon(Icons.fastfood_rounded),
    isSelected: currentRoute == MenuItemRoute.name,
    destination: const MenuItemRoute(),
  ),
  NavLink(
    label: 'Tables',
    icon: Icon(Icons.table_bar_rounded),
    isSelected: currentRoute == TablesRoute.name,
    destination: const TablesRoute(),
  ),
  // NavLink(
  //   label: 'Orders',
  //   icon: Icon(Icons.restaurant_menu_rounded),
  //   isSelected: currentRoute == OrderRoute.name,
  //   destination: const OrderRoute(),
  // ),
];
