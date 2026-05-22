import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/dependencies_injection.dart';
import 'core/navigation/app_router.dart';
import 'l10n/generated/app_localizations.dart';
import 'l10n/material_locale_fallback.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/favorites/favorites_cubit.dart';
import 'presentation/bloc/locale/locale_cubit.dart';
import 'presentation/widgets/offline_banner.dart';

class MenuZenApp extends StatelessWidget {
  const MenuZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc + FavoritesCubit + LocaleCubit are getIt-managed singletons —
    // use .value so the provider does not close them when this subtree rebuilds.
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
        BlocProvider<FavoritesCubit>.value(value: getIt<FavoritesCubit>()),
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            (prev is AuthAuthenticated && curr is! AuthAuthenticated) ||
            (prev is! AuthAuthenticated && curr is AuthAuthenticated),
        listener: (context, state) {
          final favorites = context.read<FavoritesCubit>();
          if (state is AuthAuthenticated) {
            favorites.load();
          } else {
            favorites.reset();
          }
        },
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) {
            return MaterialApp.router(
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
              debugShowCheckedModeBanner: false,
              theme: MenuZenTheme.light(),
              darkTheme: MenuZenTheme.dark(),
              routerConfig: appRouter,
              locale: locale,
              localizationsDelegates: [
                // mg fallback must precede the Global* delegates so Flutter
                // picks it before falling through to English.
                ...localeFallbackDelegates,
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => OfflineBanner(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
