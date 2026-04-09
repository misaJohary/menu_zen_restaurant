import 'package:data/services/db_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Manages the WebSocket connection for real-time order updates.
///
/// Registered as a lazySingleton in GetIt so the connection is shared
/// across the app. Call [connect] once (from OrdersPage.initState) and
/// [dispose] when the widget is torn down.
class RestaurantWebSocketService {
  RestaurantWebSocketService({
    required this.dbService,
    required this.baseUrl,
  });

  final DbService dbService;
  final String baseUrl;

  WebSocketChannel? _channel;

  WebSocketChannel? get channel => _channel;

  Future<WebSocketChannel?> connect() async {
    final restaurantId = await dbService.getRestaurantId();
    if (restaurantId == null) return null;

    final baseUri = Uri.parse(baseUrl);
    final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final wsUri = baseUri.replace(scheme: wsScheme);

    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUri/ws/orders/$restaurantId'),
    );
    return _channel;
  }

  Future<void> dispose() async => _channel?.sink.close();
}
