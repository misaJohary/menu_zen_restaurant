import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/order_menu_item/order_menu_item_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/orders_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/stats/stats_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/tables/table_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/users/users_bloc.dart';

import 'core/constants/constants.dart';
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          primaryColor: primaryColor,
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
            displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
            displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
            headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            bodyLarge: TextStyle(fontSize: 14, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              minimumSize: const Size(50, 55),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
