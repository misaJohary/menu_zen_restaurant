import 'package:data/config/base_url_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/dependencies_injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/locale/locale_cubit.dart';

Future<void> configMain({required String envFile}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: envFile);
  await BaseUrlConfig.init(fallback: dotenv.env['BASE_URL'] ?? '');
  await configureDependencies();
  // Restore the user's previously selected app locale (if any).
  await getIt<LocaleCubit>().load();
  // Kick off the auth-state check (reads the persisted token, calls /me).
  getIt<AuthBloc>().add(AuthStarted());
}
