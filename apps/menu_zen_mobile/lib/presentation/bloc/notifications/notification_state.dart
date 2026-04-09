part of 'notification_cubit.dart';

@immutable
sealed class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoaded extends NotificationState {
  NotificationLoaded(this.notifications);

  final List<AppNotification> notifications;

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
