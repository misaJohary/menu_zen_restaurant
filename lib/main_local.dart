import 'package:flutter/material.dart';

import 'app.dart';
import 'config_main.dart';

void main() async {
  await configMain(env: ".env.local");
  runApp(App());
}