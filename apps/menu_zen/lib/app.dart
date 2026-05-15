import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';

class MenuZenApp extends StatelessWidget {
  const MenuZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Menu Zen',
      debugShowCheckedModeBanner: false,
      theme: MenuZenTheme.light(),
      darkTheme: MenuZenTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
