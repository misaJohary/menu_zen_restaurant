import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/base_url_config.dart';
import 'core/injection/dependencies_injection.dart';

Future configMain({required String env})async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: env);
  await BaseUrlConfig.init(fallback: dotenv.env['BASE_URL'] ?? '');
  await configureDependencies();
}
