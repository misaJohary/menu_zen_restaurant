import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart';
import '../injection/dependencies_injection.dart';
import 'guards/auth_guards.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  AppRouter() : super(navigatorKey: navKey);

  @override

  RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/restaurant-registration',
      page: RegistrationRoute.page,
      children: [
        AutoRoute(page: RestaurantForm.page),
        AutoRoute(page: RestaurantCustomizeForm.page),
        AutoRoute(page: UserForm.page),
      ],
    ),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(
      initial: true,
      path: '/main',
      page: MainRoute.page,
      guards: [getIt<AuthGuard>()],
      children: [
        AutoRoute(path: '', page: DashboardRoute.page),
        AutoRoute(path: 'menus', page: MenuRoute.page),
        AutoRoute(path: 'categories', page: CategoriesRoute.page),
        AutoRoute(path: 'menu_items', page: MenuItemRoute.page),
        AutoRoute(path: 'tables', page: TablesRoute.page),
        AutoRoute(path: 'users', page: UsersRoute.page),

      ],

    ),
    AutoRoute(path: '/profil', page: ProfileRoute.page),
    AutoRoute(path: '/make_order', page: MakeOrderRoute.page),
    AutoRoute(path: '/order', page: OrdersRoute.page),
    AutoRoute(path: '/kds', page: KdsRoute.page),
  ];
}
