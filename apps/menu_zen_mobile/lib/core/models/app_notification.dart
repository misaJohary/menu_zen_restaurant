/// A persisted in-app notification.
class AppNotification {
  AppNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isSeen = false,
    this.orderId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        isSeen: json['isSeen'] as bool? ?? false,
        orderId: json['orderId'] as int?,
      );

  final String id;
  final String message;
  final DateTime timestamp;

  /// Whether the user has opened/tapped this specific notification.
  /// Drives the per-tile "new" highlight.
  final bool isRead;

  /// Whether the user has visited the notifications list since this
  /// notification arrived. Drives the top-level badge count
  /// (Facebook-style: seen clears the badge, read clears the tile highlight).
  final bool isSeen;

  /// The order this notification relates to, used for deep-linking.
  final int? orderId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'isSeen': isSeen,
    if (orderId != null) 'orderId': orderId,
  };

  AppNotification copyWith({bool? isRead, bool? isSeen}) => AppNotification(
    id: id,
    message: message,
    timestamp: timestamp,
    isRead: isRead ?? this.isRead,
    isSeen: isSeen ?? this.isSeen,
    orderId: orderId,
  );
}
