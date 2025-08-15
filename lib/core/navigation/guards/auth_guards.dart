import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import '../../services/db_service.dart';
import '../app_router.gr.dart';

@lazySingleton
class AuthGuard extends AutoRouteGuard {
  final DbService dbService;

  AuthGuard({required this.dbService});

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    bool isAuthenticated = await dbService.checkAuth();
    if (isAuthenticated) {
      return resolver.resolveNext(true);
    } else {
      resolver.redirectUntil(LoginRoute(
      ));
      return;
    }
  }
}