import 'package:data/config/base_url_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/dependencies_injection.dart';

Future<void> configMain({required String envFile}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: envFile);
  await BaseUrlConfig.init(fallback: dotenv.env['BASE_URL'] ?? '');
  await configureDependencies();
}
