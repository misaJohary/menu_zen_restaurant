import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/order_menu_item/order_menu_item_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/orders/orders_bloc.dart';

import 'core/constants/constants.dart';
import 'core/injection/dependencies_injection.dart';
import 'core/navigation/app_router.dart';
import 'features/presentations/managers/auths/auth_bloc.dart';
import 'features/presentations/managers/categories/categories_bloc.dart';
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
      ],
      child: MaterialApp.router(
        title: 'Menu Zen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          primaryColor: primaryColor,
          scaffoldBackgroundColor: Color(0xFFFAFAFA),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              minimumSize: Size(50, 55),
                textStyle: TextStyle(fontSize: 18)
            ),
          ),
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
