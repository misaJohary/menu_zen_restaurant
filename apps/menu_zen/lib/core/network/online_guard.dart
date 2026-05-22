import 'package:domain/services/connectivity_service.dart';
import 'package:flutter/material.dart';

import '../di/dependencies_injection.dart';

/// Centralised gate for online-only flows (auth, profile, create order,
/// create reservation, submit review, toggle favourite).
///
/// Call `OnlineGuard.require(context, message: ...)` before performing the
/// network operation. Returns `true` if the device is online; otherwise it
/// surfaces a snackbar and returns `false`.
class OnlineGuard {
  const OnlineGuard._();

  static Future<bool> isOnline() async {
    return getIt<ConnectivityService>().isOnline();
  }

  static Future<bool> require(
    BuildContext context, {
    String message = "You're offline. Connect to the internet to continue.",
  }) async {
    final online = await isOnline();
    if (!online && context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    return online;
  }
}
