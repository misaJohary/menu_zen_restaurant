import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Keys shared with the main isolate via SharedPreferences.
const _kUserRestaurant = 'userRestaurant'; // written by DbService (Async API)

/// Public so login_page can update it when the user changes the server URL.
const kWsBaseUrlKey = 'ws_base_url'; // written by configMain (Async API)
const _kWsBaseUrl = kWsBaseUrlKey;
const _kAppForeground = 'app_foreground'; // written by OrdersPage

/// Notification channel used for order alerts.
const _kOrderChannelId = 'menu_zen_orders';
const _kOrderChannelName = 'Nouvelles commandes';
const _kOrderNotifId = 42;

/// Notification channel used by the foreground service itself (Android only).
const _kFgChannelId = 'menu_zen_service';
const _kFgNotifId = 1;

/// Initialises and starts the background service.
/// Call this once from [configMain] after DI is ready.
Future<void> initBackgroundService() async {
  // Create notification channels in the main isolate before the service
  // starts. Android requires the channel to exist before a foreground service
  // can post its persistent notification.
  final notifPlugin = FlutterLocalNotificationsPlugin();
  await notifPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  final androidPlugin =
      notifPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      _kFgChannelId,
      'Service Menu Zen',
      description: 'Canal du service de surveillance des commandes.',
      importance: Importance.low, // silent persistent notification
    ),
  );

  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      _kOrderChannelId,
      _kOrderChannelName,
      description: 'Alertes sonores pour les nouvelles commandes.',
      importance: Importance.high,
      playSound: true,
    ),
  );

  // Android 13+ (API 33+) requires explicit runtime permission for
  // notifications. Without this, show() silently does nothing on a
  // fresh Play Store install.
  await androidPlugin?.requestNotificationsPermission();

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onServiceStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: _kFgChannelId,
      initialNotificationTitle: 'Menu Zen',
      initialNotificationContent: 'Surveillance des commandes…',
      foregroundServiceNotificationId: _kFgNotifId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: _onServiceStart,
      onBackground: _onIosBackground,
    ),
  );

  await service.startService();
}

// ─── iOS background handler ──────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// ─── Service entrypoint (runs in its own isolate) ────────────────────────────

@pragma('vm:entry-point')
void _onServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final notifPlugin = FlutterLocalNotificationsPlugin();
  await notifPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  WebSocketChannel? channel;
  StreamSubscription<dynamic>? wsSub;
  int reconnectDelay = 2;

  // Declared late so the closure can reference itself recursively.
  late Future<void> Function() connect;

  connect = () async {
    try {
      await wsSub?.cancel();
      wsSub = null;
      await channel?.sink.close();
      channel = null;

      final prefs = SharedPreferencesAsync();
      final userRestJson = await prefs.getString(_kUserRestaurant);
      final baseUrl = await prefs.getString(_kWsBaseUrl) ?? '';

      if (userRestJson == null || baseUrl.isEmpty) {
        // Not logged in yet — retry in 30 s.
        await Future<void>.delayed(const Duration(seconds: 30));
        await connect();
        return;
      }

      final userRest =
          json.decode(userRestJson) as Map<String, dynamic>;
      final restaurantId =
          (userRest['restaurant'] as Map<String, dynamic>)['id'];
      if (restaurantId == null) {
        await Future<void>.delayed(const Duration(seconds: 30));
        await connect();
        return;
      }

      final baseUri = Uri.parse(baseUrl);
      final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
      final wsUri = baseUri.replace(scheme: wsScheme);

      channel = WebSocketChannel.connect(
        Uri.parse('$wsUri/ws/orders/$restaurantId'),
      );
      await channel!.ready;
      reconnectDelay = 2; // reset after a successful connection

      wsSub = channel!.stream.listen(
        (raw) async {
          final data =
              json.decode(raw as String) as Map<String, dynamic>;
          await _handleEvent(service, notifPlugin, data);
        },
        onError: (_) async {
          reconnectDelay = (reconnectDelay * 2).clamp(2, 60);
          await Future<void>.delayed(Duration(seconds: reconnectDelay));
          await connect();
        },
        onDone: () async {
          reconnectDelay = (reconnectDelay * 2).clamp(2, 60);
          await Future<void>.delayed(Duration(seconds: reconnectDelay));
          await connect();
        },
        cancelOnError: true,
      );
    } catch (_) {
      reconnectDelay = (reconnectDelay * 2).clamp(2, 60);
      await Future<void>.delayed(Duration(seconds: reconnectDelay));
      await connect();
    }
  };

  await connect();

  // Allow the UI to stop the service (e.g. on logout).
  service.on('stopService').listen((_) async {
    await wsSub?.cancel();
    await channel?.sink.close();
    await service.stopSelf();
  });
}

// ─── Event handling ──────────────────────────────────────────────────────────

Future<void> _handleEvent(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin notifPlugin,
  Map<String, dynamic> data,
) async {
  // Always forward to the UI isolate so OrdersPage can update its state.
  service.invoke('ws_event', data);

  // Show a local notification only when the app is not in the foreground.
  final prefs = SharedPreferencesAsync();
  final isForeground = await prefs.getBool(_kAppForeground) ?? false;
  if (isForeground) return;

  final type = data['type'] as String?;
  String? title;
  String? body;

  switch (type) {
    case 'new_order':
      title = 'Nouvelle commande';
      body = 'Une nouvelle commande est arrivée !';
    case 'update_order_menu_item_status':
      if (data['new_status'] == 'ready') {
        title = 'Article prêt';
        body = 'Un article est prêt à être servi.';
      }
    case 'update_order_status':
      title = 'Statut mis à jour';
      body = "Le statut d'une commande a changé.";
    default:
      return;
  }

  if (title == null) return;

  await notifPlugin.show(
    _kOrderNotifId,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _kOrderChannelId,
        _kOrderChannelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(presentSound: true),
    ),
  );
}