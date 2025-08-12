import 'package:auto_route/auto_route.dart';
import 'package:menu_zen_restaurant/core/navigation/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {

  @override
  RouteType get defaultRouteType => RouteType.material(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    // HomeScreen is generated as HomeRoute because
    // of the replaceInRouteName property
    AutoRoute(
        initial: true,
        page: RestaurantRegistrationRoute.page,
      children: [
        AutoRoute(page: RestaurantForm.page),
        AutoRoute(page: UserForm.page)
      ]),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    // optionally add root guards here
  ];
}