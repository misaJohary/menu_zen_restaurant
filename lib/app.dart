import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection/dependencies_injection.dart';
import 'core/navigation/app_router.dart';
import 'features/presentations/managers/restaurant/restaurant_bloc.dart';


class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<RestaurantBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Menu Zen',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}