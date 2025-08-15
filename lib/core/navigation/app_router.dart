import 'package:auto_route/auto_route.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart';
import '../injection/dependencies_injection.dart';
import 'guards/auth_guards.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/restaurant-registration',
      page: RestaurantRegistrationRoute.page,
      children: [
        AutoRoute(page: RestaurantForm.page),
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
        AutoRoute(path: 'foods', page: FoodsRoute.page),
        AutoRoute(path: 'order', page: OrderRoute.page),
        AutoRoute(path: 'tables', page: TablesRoute.page),
      ],
    ),
  ];
}
