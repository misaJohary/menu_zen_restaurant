import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/order_menu_item/order_menu_item_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/orders_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/stats/stats_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/tables/table_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/users/users_bloc.dart';

import 'core/injection/dependencies_injection.dart';
import 'core/navigation/app_router.dart';
import 'features/presentations/managers/auths/auth_bloc.dart';
import 'features/presentations/managers/categories/categories_bloc.dart';
import 'features/presentations/managers/languages/languages_bloc.dart';
import 'features/presentations/managers/menu_item/menu_item_bloc.dart';
import 'features/presentations/managers/menus/menus_bloc.dart';
import 'features/presentations/managers/restaurant/restaurant_bloc.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<RestaurantBloc>()),
        BlocProvider(create: (context) => getIt<MenusBloc>()),
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<CategoriesBloc>()),
        BlocProvider(create: (context) => getIt<MenuItemBloc>()),
        BlocProvider(create: (context) => getIt<OrdersBloc>()),
        BlocProvider(create: (context) => getIt<OrderMenuItemBloc>()),
        BlocProvider(create: (context) => getIt<TableBloc>()),
        BlocProvider(create: (context) => getIt<LanguagesBloc>()),
        BlocProvider(create: (context) => getIt<StatsBloc>()),
        BlocProvider(create: (context) => getIt<UsersBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Menu Zen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
