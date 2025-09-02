import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../managers/auths/auth_bloc.dart';

class MainController extends ChangeNotifier {
  final BuildContext context;

  MainController(this.context);

  String _currentRoute = 'DashboardRoute';

  String get currentRoute => _currentRoute;

  bool hidePannel = false;

  togglePannelVisibility({required bool show}){
    hidePannel = !show;
  }

  changeCurrentRoute(String newRoute) {
    _currentRoute = newRoute;
    notifyListeners();
  }

  logout() async {
    context.read<AuthBloc>().add(AuthLoggedOut());
    context.router.reevaluateGuards();
  }
}
