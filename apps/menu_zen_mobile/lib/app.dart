import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/http_connexion/interceptors.dart';
import 'core/injection/dependencies_injection.dart';
import 'core/navigation/app_router.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/notifications/notification_cubit.dart';
import 'presentation/bloc/orders/orders_bloc.dart';
import 'presentation/bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import 'presentation/bloc/tables/table_bloc.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  App({super.key}) {
    // Provide the navigator key to interceptors for 403 dialogs.
    appNavigatorKey = _navigatorKey;
  }

  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<OrdersBloc>()),
        BlocProvider(create: (_) => getIt<OrderMenuItemBloc>()),
        BlocProvider(create: (_) => getIt<TableBloc>()),
        BlocProvider(
          create: (_) => getIt<NotificationCubit>()..loadNotifications(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Menu Zen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF006D6B),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: GoogleFonts.poppins().fontFamily,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF006D6B),
            elevation: 0,
            titleTextStyle: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF006D6B),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Color(0xFF006D6B),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
