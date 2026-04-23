import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/app_notification.dart';

part 'notification_state.dart';

/// Manages the in-app notification list.
///
/// Persists notifications in SharedPreferences (key: [_storageKey]).
/// Keeps the most recent [_maxNotifications] entries.
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required SharedPreferencesAsync prefs})
    : _prefs = prefs,
      super(NotificationInitial());

  static const _storageKey = 'app_notifications';
  static const _maxNotifications = 50;

  final SharedPreferencesAsync _prefs;

  Future<void> loadNotifications() async {
    final raw = await _prefs.getString(_storageKey);
    if (raw == null) {
      emit(NotificationLoaded([]));
      return;
    }
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
    emit(NotificationLoaded(list));
  }

  Future<void> addNotification(String message, {int? orderId}) async {
    final current = state is NotificationLoaded
        ? (state as NotificationLoaded).notifications
        : <AppNotification>[];

    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
      timestamp: DateTime.now(),
      orderId: orderId,
    );

    final updated = [notification, ...current].take(_maxNotifications).toList();
    await _save(updated);
    emit(NotificationLoaded(updated));
  }

  Future<void> markRead(String id) async {
    if (state is! NotificationLoaded) return;
    final current = (state as NotificationLoaded).notifications;
    final updated = current
        .map((n) => n.id == id ? n.copyWith(isRead: true, isSeen: true) : n)
        .toList();
    await _save(updated);
    emit(NotificationLoaded(updated));
  }

  Future<void> markAllRead() async {
    if (state is! NotificationLoaded) return;
    final current = (state as NotificationLoaded).notifications;
    final updated = current
        .map((n) => n.copyWith(isRead: true, isSeen: true))
        .toList();
    await _save(updated);
    emit(NotificationLoaded(updated));
  }

  /// Marks every notification as seen so the badge resets to zero.
  /// Does not mark tiles as read — individual items keep their
  /// "new" highlight until the user taps them.
  Future<void> markAllSeen() async {
    if (state is! NotificationLoaded) return;
    final current = (state as NotificationLoaded).notifications;
    if (current.every((n) => n.isSeen)) return;
    final updated = current.map((n) => n.copyWith(isSeen: true)).toList();
    await _save(updated);
    emit(NotificationLoaded(updated));
  }

  Future<void> clearAll() async {
    await _prefs.remove(_storageKey);
    emit(NotificationLoaded([]));
  }

  Future<void> _save(List<AppNotification> notifications) async {
    final json = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await _prefs.setString(_storageKey, json);
  }
}
