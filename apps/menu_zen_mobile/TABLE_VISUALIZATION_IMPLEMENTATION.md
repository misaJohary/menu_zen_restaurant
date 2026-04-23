# Table Visualization — Implementation Plan

This document describes the **step-by-step** plan to introduce a new
**Table Visualization** tab to `apps/menu_zen_mobile`, based on:

- The new `GET /tables` payload described in
  [`RESTAURANT_TABLE_MIGRATION.md`](./RESTAURANT_TABLE_MIGRATION.md)
- The mockup [`assets/table_management_screen.png`](./assets/table_management_screen.png)

The work spans **three layers** of the monorepo (`domain`, `data`,
`apps/menu_zen_mobile`) and follows the existing patterns already used for
orders/notifications (BLoC + `get_it` + `go_router` `StatefulShellRoute`).

---

## 0. Goal & Scope

Add a new bottom-nav tab whose page renders the restaurant tables in a 3-column
grid. Each card reflects the table's current `status` (free / waiting /
assigned / dirty / reserved) using color and a status-specific label
(e.g. server username, elapsed waiting time).

**Out of scope** (for this iteration):
- Mutations (assigning a server, marking a table dirty, etc.)
- Real-time updates over WebSocket
- Reservation details

The page is **read-only** for now; a refresh-to-fetch is enough.

---

## 1. Update the Domain Layer (`packages/domain`)

### 1.1 New `TableStatus` enum


Create a new enum that mirrors the back-end `TableStatus` values and supports
JSON-serialisable string values.

File: `packages/domain/lib/entities/table_status.dart`

```dart
enum TableStatus {
  free,
  reserved,
  waiting,
  assigned,
  dirty;

  static TableStatus fromString(String value) =>
      TableStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => TableStatus.free,
      );
}
```

Notes:
- The values are already lowercase (`free`, `reserved`, …) so plain `name`
  matches the JSON.
- Follow the same shape as `OrderStatus` in `order_entity.dart`.

### 1.2 Update `TableEntity`

File: `packages/domain/lib/entities/table_entity.dart`

Add the new fields returned by the API:

| Field            | Type                | Nullable | Source           |
| ---------------- | ------------------- | -------- | ---------------- |
| `restaurantId`   | `int?`              | yes      | `restaurant_id`  |
| `status`         | `TableStatus`       | no       | `status`         |
| `serverId`       | `int?`              | yes      | `server_id`      |
| `waitingSince`   | `DateTime?`         | yes      | `waiting_since`  |
| `seats`          | `int?`              | yes      | `seats`          |
| `server`         | `UserEntity?`       | yes      | `server`         |
| `activeReservation` | `TableReservationEntity?` | yes  | `active_reservation` |

Keep the existing `id` and `name` fields. **Drop** `isActive` — it is no
longer in the API response.

Update `props` and `copyWith` accordingly. Default `status` to
`TableStatus.free` so callers that build a table without a server still work.

### 1.3 Reservation entities

The full back-end contract is now confirmed:

```json
"active_reservation": {
  "id": 0,
  "reservation_id": 0,
  "table_id": 0,
  "status": "active",
  "reservation": {
    "id": 0,
    "name": "string",
    "phone": "string",
    "reserved_at": "2026-04-22T13:23:47.417Z",
    "status": "active",
    "note": "string",
    "created_by_id": 0,
    "created_at": "2026-04-22T13:23:47.417Z",
    "updated_at": "2026-04-22T13:23:47.417Z"
  },
  "created_at": "2026-04-22T13:23:47.417Z",
  "updated_at": "2026-04-22T13:23:47.417Z"
}
```

Two new entities are introduced. Both are pure Dart, `Equatable`, and live in
`packages/domain/lib/entities/`.

#### 1.3.1 `ReservationStatus` enum

File: `packages/domain/lib/entities/reservation_status.dart`

```dart
enum ReservationStatus {
  active,
  cancelled,
  completed;

  static ReservationStatus fromString(String value) =>
      ReservationStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ReservationStatus.active,
      );
}
```

Only `"active"` is shown in the example payload — add `cancelled` /
`completed` defensively (they are the typical lifecycle siblings) and refine
the list once the back-end documents the full set.

#### 1.3.2 `ReservationEntity` (the inner `reservation` block)

File: `packages/domain/lib/entities/reservation_entity.dart`

| Field          | Type                  | Nullable | JSON key         |
| -------------- | --------------------- | -------- | ---------------- |
| `id`           | `int?`                | yes      | `id`             |
| `name`         | `String?`             | yes      | `name`           |
| `phone`        | `String?`             | yes      | `phone`          |
| `reservedAt`   | `DateTime?`           | yes      | `reserved_at`    |
| `status`       | `ReservationStatus`   | no       | `status`         |
| `note`         | `String?`             | yes      | `note`           |
| `createdById`  | `int?`                | yes      | `created_by_id`  |
| `createdAt`    | `DateTime?`           | yes      | `created_at`     |
| `updatedAt`    | `DateTime?`           | yes      | `updated_at`     |

#### 1.3.3 `TableReservationEntity` (the join row that wraps it)

File: `packages/domain/lib/entities/table_reservation_entity.dart`

| Field           | Type                  | Nullable | JSON key          |
| --------------- | --------------------- | -------- | ----------------- |
| `id`            | `int?`                | yes      | `id`              |
| `reservationId` | `int?`                | yes      | `reservation_id`  |
| `tableId`       | `int?`                | yes      | `table_id`        |
| `status`        | `ReservationStatus`   | no       | `status`          |
| `reservation`   | `ReservationEntity?`  | yes      | `reservation`     |
| `createdAt`     | `DateTime?`           | yes      | `created_at`      |
| `updatedAt`     | `DateTime?`           | yes      | `updated_at`      |

`TableEntity.activeReservation` is typed as `TableReservationEntity?` and is
`null` when the table has no reservation.

### 1.4 Repository signature

`packages/domain/lib/repositories/tables_repository.dart` already exposes the
correct CRUD methods. **No change required**, since the new fields just enrich
what `getAll()` returns.

---

## 2. Update the Data Layer (`packages/data`)

### 2.1 Update / create the models

Three model files mirror the entities of step 1.

#### 2.1.1 `TableModel`

File: `packages/data/lib/models/table_model.dart`

- Add `@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)`
  so the Dart `restaurantId` is mapped to JSON `restaurant_id`, etc.
- Mirror every new field added to `TableEntity` (step 1.2).
- Use `UserModel` for the nested `server` field and
  `TableReservationModel` for `activeReservation` so `fromJson`/`toJson`
  recurse correctly (look at how `OrderModel` does it for `rTable`/`server`).
- Keep the `fromEntity`/`copyWith` factories in sync with the new fields.

#### 2.1.2 `ReservationModel`

File: `packages/data/lib/models/reservation_model.dart`

- Extends `ReservationEntity`.
- Annotated with
  `@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)`.
- Provides `fromJson`, `toJson`, `fromEntity`, and `copyWith`.

#### 2.1.3 `TableReservationModel`

File: `packages/data/lib/models/table_reservation_model.dart`

- Extends `TableReservationEntity`.
- Same annotation as above.
- The nested `reservation` field is typed as `ReservationModel?` so the
  generated `toJson` calls `reservation?.toJson()` (this is what
  `explicitToJson: true` enables).

### 2.2 Regenerate JSON code

From the workspace root:

```bash
cd packages/data
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `table_model.g.dart` (and any other model touched).

### 2.3 Repository implementation

`packages/data/lib/repositories/tables_repository_impl.dart` only forwards to
`rest.getTables()`, so no logic change is needed. After the model is
regenerated, the deserialised `List<TableModel>` will already carry the new
fields.

### 2.4 REST client

`packages/data/lib/http/rest_client.dart` already declares
`@GET('/tables')` returning `List<TableModel>`. **No change required.**

---

## 3. Presentation Layer (`apps/menu_zen_mobile`)

### 3.1 Existing `TableBloc`

`apps/menu_zen_mobile/lib/presentation/bloc/tables/` already exposes
`TableBloc` with `TableFetched` / `TableCreated` / `TableUpdated` /
`TableDeleted`. Reuse it as-is for read access — `TableFetched` already
populates `state.tables` with `List<TableEntity>`, which now carries the
status, server, etc.

No changes needed unless we want to add status filtering at the BLoC level
(see step 3.4 — keep filtering in the widget for now to stay simple).

### 3.2 New page: `TablesPage`

File: `apps/menu_zen_mobile/lib/presentation/pages/tables_page.dart`

Structure (mirrors `OrdersPage` for visual consistency):

```
Scaffold
└── AppBar (title: "Tables")
└── Body Column
    ├── _StatusFilterBar  (horizontal scrollable chips)
    └── Expanded
        └── BlocBuilder<TableBloc, TableState>
            ├── loading  → CircularProgressIndicator
            ├── failed   → error text + retry
            └── loaded   → RefreshIndicator
                           └── GridView.builder (3 cols)
                               └── _TableCard
```

`initState` should dispatch `TableFetched()` exactly like `OrdersPage` does
with `OrderFetched()`.

### 3.3 `_StatusFilterBar`

A horizontal `ListView` (or `SingleChildScrollView` + `Row`) of chip-like
buttons:

| Label       | Filter                     | Dot color     |
| ----------- | -------------------------- | ------------- |
| Tout        | no filter (selected init.) | none (dark)   |
| Libre       | `TableStatus.free`         | green         |
| Attente     | `TableStatus.waiting`      | orange        |
| Occupé      | `TableStatus.assigned`     | blue          |
| Réservé     | `TableStatus.reserved`     | purple        |
| Nettoyage   | `TableStatus.dirty`        | grey          |

Selected chip: dark filled background + white text (matches the "Tout" pill in
the mockup). Unselected chips: white background, light border, leading colored
dot, dark grey text.

State for the selected filter can live in `TablesPage` as a local
`TableStatus?` (null = "Tout"). Filter the table list in-line:

```dart
final visible = _selected == null
    ? state.tables
    : state.tables.where((t) => t.status == _selected).toList();
```

### 3.4 `_TableCard`

A square-ish card showing:

- Big bold table `name` (e.g. `T1`, `T11`).
- A status-driven secondary line.
- A colored 1.5 px border whose color matches the status.

Status → visual mapping (matches the mockup):

| Status      | Border / Accent          | Secondary line                          |
| ----------- | ------------------------ | --------------------------------------- |
| `free`      | green `#22C55E`          | `"Disponible"` (green)                  |
| `assigned`  | blue   `#3B82F6`         | `server.username` (or "Occupé")         |
| `waiting`   | orange `#F97316`         | `"<n> min\nÉcoulé"` from `waitingSince` |
| `dirty`     | grey   `#9CA3AF`         | `"Nettoyage..."` italic                 |
| `reserved`  | purple `#8B5CF6`         | `activeReservation?.reservation?.name` (fallback `"Réservé"`) |

Helper for the waiting label:

```dart
String _elapsed(DateTime? since) {
  if (since == null) return '';
  final m = DateTime.now().difference(since).inMinutes;
  return '$m min\nÉcoulé';
}
```

Build the cards inside a `GridView.builder` with:
- `crossAxisCount: 3`
- `childAspectRatio: 1.0` (or 0.95 — tweak against the mockup)
- `mainAxisSpacing: 12`, `crossAxisSpacing: 12`
- `padding: EdgeInsets.all(12)`

Wrap each card in `InkWell` returning a `SizedBox.shrink()` `onTap` for now —
reserve the gesture for a future bottom-sheet that exposes actions
(assign server, mark dirty, etc.).

### 3.5 Reusable colors

Add a small color map (or extension on `TableStatus`) inside the page file —
do **not** pollute `core/constants/constants.dart` until a second consumer
appears.

```dart
extension TableStatusColors on TableStatus {
  Color get accent => switch (this) {
        TableStatus.free      => const Color(0xFF22C55E),
        TableStatus.assigned  => const Color(0xFF3B82F6),
        TableStatus.waiting   => const Color(0xFFF97316),
        TableStatus.dirty     => const Color(0xFF9CA3AF),
        TableStatus.reserved  => const Color(0xFF8B5CF6),
      };
}
```

---

## 4. Wire the Tab into Navigation

### 4.1 Update `app_router.dart`

File: `apps/menu_zen_mobile/lib/core/navigation/app_router.dart`

Add a new `StatefulShellBranch` between `OrdersPage` and `NotificationsPage`
(position is up to UX, but the mockup suggests this is a primary entry):

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/main/tables',
      builder: (context, state) => const TablesPage(),
    ),
  ],
),
```

Import the new page at the top of the file.

### 4.2 Update `main_page.dart`

File: `apps/menu_zen_mobile/lib/presentation/pages/main_page.dart`

- Import `tables_page.dart`.
- Insert `TablesPage()` inside `_pages` at the same index used in the router.
- Add a matching `BottomNavigationBarItem`. Suggested icons:
  `Icons.table_restaurant_outlined` / `Icons.table_restaurant` (Material 3 has
  this icon out of the box).
- Make sure both lists (`_pages` and `items:`) stay in lockstep — the order
  must mirror the order of `branches` in `app_router.dart`.

### 4.3 No DI changes

`TableBloc` is already registered (`getIt<TableBloc>()`) and provided in
`app.dart`. Nothing to add to `dependencies_injection.dart`.

---

## 5. Verification Checklist

Run from the workspace root unless noted:

```bash
# 1. Bootstrap once after pubspec changes (if any)
melos bootstrap

# 2. Regenerate JSON for the data package
cd packages/data && dart run build_runner build --delete-conflicting-outputs
cd -

# 3. Static analysis on every package
melos run analyze

# 4. Format
melos run format

# 5. Smoke-test the app
cd apps/menu_zen_mobile && flutter run
```

Manual QA:
- The new tab appears in the bottom navigation.
- Tapping it shows a 3-column grid of tables.
- Filter chips filter the grid correctly; "Tout" resets the filter.
- Pull-to-refresh re-fetches the list.
- A `waiting` table shows a live "X min Écoulé" derived from `waitingSince`.
- An `assigned` table shows the `server.username`.
- A `free` table shows "Disponible" in green.
- A `dirty` table shows "Nettoyage..." in italic grey.

---

## 6. Suggested Commit Plan

Split the work into reviewable commits:

1. `feat(domain): extend TableEntity with status, server, reservation`
2. `feat(data): map new RestaurantTable fields in TableModel`
3. `feat(mobile): add TablesPage with status filters and card grid`
4. `feat(mobile): wire tables tab into router and bottom navigation`

Each commit should pass `melos run analyze`.

---

## 7. Follow-ups (not in this PR)

- Tap a card → bottom sheet with actions (assign server, free, mark dirty).
- Real-time updates via the existing background WebSocket service
  (add `table_status_updated` handling next to the existing order events in
  `app.dart#_handleWsMessage`).
- Surface richer reservation details (phone, `reservedAt`, note) in a
  detail bottom-sheet — the `ReservationEntity` already carries them.
- Add a `TablesRepository.getById(int)` if a detail screen is built.
- Treat `seats` as a primary card field once the back-end starts populating
  it (currently `null` in every example row).
