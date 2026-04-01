import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/navigation/app_router.gr.dart';
import '../../domains/entities/user_entity.dart';

class NavLink extends StatefulWidget {
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
  State<NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<NavLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _hoverScale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverScale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: Stack(
        children: [
          ListenableBuilder(
            listenable: _hoverController,
            builder: (context, child) {
              return Transform.scale(
                scale: _hoverScale.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(
                horizontal: kspacing * 2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? primaryColor.withValues(alpha: 0.08)
                    : _isHovered
                        ? primaryColor.withValues(alpha: 0.04)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -1),
                leading: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(
                    widget.iconPath,
                    key: ValueKey(widget.isSelected),
                    colorFilter: ColorFilter.mode(
                      widget.isSelected ? primaryColor : grey,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                    height: 24,
                  ),
                ),
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(
                    color: widget.isSelected ? primaryColor : grey,
                    fontSize: 16,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  child: Text(widget.label ?? ''),
                ),
                onTap: () {
                  context.router.push(widget.destination);
                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            right: 0,
            top: widget.isSelected ? 12 : 22,
            bottom: widget.isSelected ? 12 : 22,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.isSelected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: widget.isSelected ? 5 : 0,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
  // NavLink(
  //   label: 'Commande',
  //   iconPath: 'assets/icons/commandes.svg',
  //   isSelected: currentRoute == OrdersRoute.name,
  //   destination: const OrdersRoute(),
  // ),
  //if (role == Role.admin || role == Role.superAdmin)
    NavLink(
      label: 'Utilisateurs',
      iconPath: 'assets/icons/user.svg', // Fallback for Users
      isSelected: currentRoute == UsersRoute.name,
      destination: const UsersRoute(),
    ),
];
