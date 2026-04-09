/// A persisted in-app notification.
class AppNotification {
  AppNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        message: json['message'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );

  final String id;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        message: message,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
      );
}
