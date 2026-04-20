part of 'notification_cubit.dart';

@immutable
sealed class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoaded extends NotificationState {
  NotificationLoaded(this.notifications);

  final List<AppNotification> notifications;

  /// Counts notifications the user has not yet seen (badge count).
  /// A notification is "seen" once the user opens the notifications page,
  /// even if individual tiles remain marked as unread.
  int get unreadCount => notifications.where((n) => !n.isSeen).length;
}
