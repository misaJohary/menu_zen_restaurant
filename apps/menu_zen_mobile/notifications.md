# Notifications — Implementation Guide

Real-time notifications for the mobile app (servers) via WebSocket, with sound,
vibration, and a persistent notification center.

---

## Architecture

```
Kitchen (tablet)
    └─ marks item as ready
           │  WebSocket push
           ▼
RestaurantWebSocketService  ──── singleton (GetIt)
           │  stream.listen
           ▼
_OrdersPageState._handleWsMessage()
    ├─ dispatches OrderMenuItemStatusRemoteUpdated → OrdersBloc
    │       └─ BlocBuilder in OrderDetailPage re-renders automatically
    ├─ calls AudioPlayer.play('sounds/new_order.ogg')
    ├─ calls HapticFeedback.mediumImpact()
    └─ calls NotificationCubit.addNotification(message)
               └─ persists to SharedPreferences ('app_notifications')
               └─ updates badge count on bell icon (AppBar of OrdersPage)
```

---

## Files Added / Modified

| Path | Role |
|------|------|
| `lib/core/services/ws_service.dart` | WebSocket singleton |
| `lib/core/models/app_notification.dart` | Notification model + JSON |
| `lib/presentation/bloc/notifications/notification_cubit.dart` | State management |
| `lib/presentation/bloc/notifications/notification_state.dart` | Sealed states |
| `lib/presentation/pages/notifications_page.dart` | Notification center screen |
| `lib/core/injection/dependencies_injection.dart` | DI registration |
| `lib/app.dart` | MultiBlocProvider + NotificationCubit |
| `lib/core/navigation/app_router.dart` | `/notifications` route |
| `lib/presentation/pages/orders_page.dart` | WS init, sound, vibration, badge |
| `assets/sounds/new_order.ogg` | Notification sound |
| `pubspec.yaml` | `web_socket_channel`, `audioplayers` dependencies |

---

## WebSocket Message Types

| `type` | Action |
|--------|--------|
| `connection_established` | ignored |
| `update_order_menu_item_status` | update item status in BLoC + notify if `ready` |
| `update_order_status` | update order status in BLoC + play sound/vibrate |
| `new_order` | trigger full order list refresh |
| `order_deleted` | remove order from BLoC state |
| `order_updated` | replace order in BLoC state |

Expected message shape for `update_order_menu_item_status`:
```json
{
  "type": "update_order_menu_item_status",
  "order_id": 42,
  "item_id": 7,
  "new_status": "ready"
}
```

---

## Notification Messages

Generated in `_OrdersPageState._addItemReadyNotification()`.
Format: `"<Item name> est prêt à servir pour <Table name>"`

Example: `"Le poulet rôti est prêt à servir pour T1"`

---

## NotificationCubit API

```dart
cubit.loadNotifications();       // call once at app start (app.dart)
cubit.addNotification(message);  // called by orders_page on WS event
cubit.markAllRead();             // called by NotificationsPage.initState
cubit.clearAll();                // "Effacer" button in NotificationsPage
```

Notifications are stored under SharedPreferences key `app_notifications` as a
JSON array. Maximum 50 entries are kept; oldest are dropped.

---

## Adding a New WebSocket Message Type

1. Add a new `case` in `_handleWsMessage()` in `orders_page.dart`.
2. If it modifies order state, dispatch the appropriate `OrdersBloc` event
   (prefer the `Remote*` variants which skip the API round-trip).
3. If it should generate a notification, call
   `context.read<NotificationCubit>().addNotification(message)`.

---

## Setup After Cloning

```bash
# 1. Install dependencies
melos bootstrap

# 2. Verify no analysis errors
flutter analyze apps/menu_zen_mobile

# 3. Run the app
cd apps/menu_zen_mobile && flutter run
```

---

## Manual Testing Checklist

- [ ] From kitchen tablet, mark a menu item as ready
  - [ ] Mobile plays `new_order.ogg`
  - [ ] Mobile vibrates
  - [ ] `readyItems/totalItems` badge updates on the order card
  - [ ] Bell badge increments
- [ ] Open order detail → item appears checked
- [ ] Tap bell icon → notification center shows the message
- [ ] Bell badge resets to 0 after visiting the screen
- [ ] Kill and reopen app → notifications still present
- [ ] "Effacer" button clears all notifications
