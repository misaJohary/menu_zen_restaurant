import 'package:flutter/material.dart';

import 'app.dart';
import 'config_main.dart';

Future<void> main() async {
  await configMain(envFile: '.env.staging');
  runApp(const MenuZenApp());
}
