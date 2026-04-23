import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data/config/base_url_config.dart';
import 'core/injection/dependencies_injection.dart';
import 'core/services/background_order_service.dart';

Future<void> configMain({required String env}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: env);
  await BaseUrlConfig.init(fallback: dotenv.env['BASE_URL'] ?? '');
  await configureDependencies();

  // Make the base URL available to the background service isolate.
  await SharedPreferencesAsync().setString(
    'ws_base_url',
    BaseUrlConfig.current,
  );

  await initBackgroundService();
}
