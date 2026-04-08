import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:data/services/db_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@lazySingleton
class RestaurantWebSocketService {
  WebSocketChannel? _channel;
  final DbService dbService;
  String baseUrl;

  RestaurantWebSocketService({
    required this.dbService,
    @Named('BaseUrl') required this.baseUrl,
  });

  Future connect() async {
    // Connect with YOUR restaurant ID
    final restaurantId = await dbService.getRestaurantId();
    Uri baseUri = Uri.parse(baseUrl);
    String wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    Uri wsUri = baseUri.replace(scheme: wsScheme);
    _channel = WebSocketChannel.connect(
      Uri.parse('$wsUri/ws/orders/$restaurantId'),
    );
    // _channel!.stream.listen(
    //       (message) {
    //     final data = jsonDecode(message);
    //     Logger().e(message);
    //     switch (data['type']) {
    //       case 'connection_established':
    //         print('Connected to restaurant: ${data['restaurant_id']}');
    //         break;
    //       case 'order_status_update':
    //         _streamController?.add(data);
    //         break;
    //       case 'new_order':
    //       // Handle new order
    //         _streamController?.add(data);
    //         break;
    //     }
    //   },
    //   onError: (error) => _reconnect(),
    //   onDone: () => _reconnect(),
    // );

    return _channel;
  }

  WebSocketChannel? get channel => _channel;

  void updateBaseUrl(String value) {
    baseUrl = value;
  }

  void _reconnect() {
    Future.delayed(Duration(seconds: 3), () => connect());
  }

  void dispose() async {
    await _channel?.sink.close();
  }
}
