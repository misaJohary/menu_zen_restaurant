# Offline-First Plan — `menu_zen` Customer App

> Goal: turn `apps/menu_zen` into an offline-capable Flutter app for **reads**.
> The user should be able to launch the app, browse restaurants/menus, and
> consult past orders & reservations without a network connection.
>
> **Online-only flows (v1):**
> - Authentication (login / register / `me()` / logout)
> - Profile (view & edit)
> - Creating a delivery order
> - Creating a reservation
> - Submitting / editing a review (reading reviews is offline-capable)
> - Toggling a favourite (the user's favourites list is **readable**
>   offline, but adding / removing one requires connectivity)
>
> Online-only flows must surface a clear "you're offline" UX and disable
> their CTAs when there is no connectivity. No write queue / outbox is
> built in v1.

---

## 1. Current State (baseline)

- **Auth:** custom JWT, token persisted in `shared_preferences`. App start
  calls `me()` on the server — fails hard offline.
- **Reads:** every screen calls a `Remote*Datasource` directly via Dio. No
  cache layer in `packages/data`.
- **Writes:** orders & reservations POST synchronously. No retry, no offline
  guard.
- **Connectivity:** not detected anywhere.
- **Local storage:** only `shared_preferences` (token).

## 2. Target Architecture

```
presentation (BLoC/Cubit)
        │
        ▼
domain repository  ◄── unchanged interfaces
        │
        ▼
data repository impl  ──┬──► LocalDataSource  (SQLite via Drift)   ← reads
                        │
                        └──► RemoteDataSource (Dio, existing)      ← reads + writes
                                  ▲
                                  │
                          ConnectivityService (connectivity_plus + ping)
                                  │
                                  └──► gates online-only flows
                                       (auth, profile, create order,
                                        create reservation, submit review,
                                        toggle favourite)
```

**Read strategy — Stale-While-Revalidate (SWR):**
1. Emit cached data immediately from local DB.
2. If online, fetch remote in background, update cache, re-emit.
3. If offline, stay on cache and surface a small "offline" hint in the UI.

**Write strategy — Online-only guard (v1):**
1. Before calling the remote write, check `ConnectivityService.isOnline()`.
2. If offline → block the action and show a clear message
   ("You need an internet connection to place an order").
3. If online → call the remote endpoint normally. On success, update the
   local cache so the new row appears in the offline-browsable history
   (this is what makes favourites readable offline — the list is hydrated
   on the last online toggle, then served from the cache).
4. On HTTP failure, show the server error as today (no retry queue).

> If we later want offline order/reservation/favourite mutations, we
> re-introduce the Outbox pattern (kept as a "Future work" appendix
> below). Not v1.

## 3. Tech Choices

| Concern | Package | Why |
|---|---|---|
| Local relational DB | `drift` (SQLite) | Strongly-typed, supports joins (orders ↔ items, restaurants ↔ menus), reactive `.watch()` streams, migrations |
| Connectivity | `connectivity_plus` | Stream of `ConnectivityResult`; pair with a lightweight HEAD ping for *real* internet |
| Image cache | `cached_network_image` | Offline menu photos |

> **No `uuid` / no `workmanager` needed in v1** — all writes are
> online-only, so no client-generated IDs and no background drain.

## 4. Phased Implementation

Each phase ends in a runnable app. Do not start a phase before the previous one
is merged.

---

### Phase 0 — Dependencies & scaffolding (½ day)

- [ ] Add to `packages/data/pubspec.yaml`: `drift`, `sqlite3_flutter_libs`,
      `path_provider`, `path`, `connectivity_plus`. Dev:
      `drift_dev`, `build_runner`.
- [ ] Add to `apps/menu_zen/pubspec.yaml`: `connectivity_plus` (UI banner),
      `cached_network_image`.
- [ ] `melos bootstrap`.
- [ ] Create `packages/data/lib/local/` folder with `app_database.dart`
      (empty Drift `@DriftDatabase` for now).

---

### Phase 1 — Connectivity service (½ day)

- [ ] `packages/domain/lib/services/connectivity_service.dart` — abstract
      `Stream<bool> get onlineStream;  Future<bool> isOnline();`
- [ ] `packages/data/lib/services/connectivity_service_impl.dart` —
      wraps `connectivity_plus` + a `HEAD https://<api>/health` probe with
      a 3 s timeout (raw connectivity ≠ real internet).
- [ ] Register as `@LazySingleton` in DI.
- [ ] `apps/menu_zen/lib/presentation/widgets/offline_banner.dart` —
      a `MaterialBanner` that listens to the stream. Mount once in
      `app.dart` under the `MaterialApp.router` builder.
- [ ] Expose a small helper (e.g. `OnlineGuard.require(context)`) that the
      auth / profile / create-order / create-reservation flows call before
      hitting the network. On offline → show a snackbar/dialog and bail.

---

### Phase 2 — Local DB schema (1–2 days)

In `packages/data/lib/local/tables/` create one Drift table per cached entity.
Minimum set for v1 (read-only caches — no `syncStatus`, no `clientId`, since
writes go straight to the server):

- `RestaurantsTable` (id, json blob of `RestaurantPublicEntity`, `cachedAt`)
- `RestaurantDetailsTable` (id, json, `cachedAt`)
- `MenusTable` / `MenuItemsTable` (restaurantId FK)
- `CustomerOrdersTable` (id, restaurantId, status, json body, `updatedAt`,
  `cachedAt`)
- `CustomerOrderItemsTable` (orderId FK, menuItemId, qty, …)
- `CustomerReservationsTable` (same shape as orders)
- `FavoritesTable` (restaurantId PK, json blob of the restaurant card so
  the list renders offline, `cachedAt`)
- `ReviewsTable` (id, restaurantId FK, json blob, `cachedAt`) — anonymous
  cache, no auth required to read
- `MetaTable` (key/value — last sync timestamps per resource)

> Tip: for entities you only read, storing a JSON blob is fine and avoids
> exploding the schema. Use proper columns only for fields you need to query
> or join on (status, restaurantId, updatedAt).

- [ ] Define tables.
- [ ] Generate code: `cd packages/data && dart run build_runner build -d`.
- [ ] Open DB via `NativeDatabase.createInBackground(File(...))` (path from
      `path_provider.getApplicationDocumentsDirectory()`).
- [ ] Register `AppDatabase` as `@LazySingleton` in DI.

---

### Phase 3 — Cache-first reads (2–3 days)

Refactor read repositories one by one. Start with the lowest-risk read path:
restaurant list.

For each `*RepositoryImpl`:
1. Inject the matching `LocalDataSource` next to the existing remote one.
2. Change the public method to return `Stream<Either<Failure, T>>` (backed
   by Drift's `.watch()`). The Cubit/BLoC subscribes and re-emits `Loaded`
   on every value.
3. New behaviour:
   ```
   yield cached (if any)
   if (online) {
     try { fresh = await remote.fetch(); local.upsert(fresh); yield fresh; }
     catch (e) { /* keep cache, log */ }
   }
   ```
4. Update the corresponding Cubit/BLoC to subscribe to the stream and emit
   `Loaded` on every value.

**Order to refactor:**
1. `PublicRestaurantsRepository` (discover list + detail)
2. Menus / menu items (part of detail)
3. `CustomerReviewsRepository` — **reads only** are cached and anonymous
   (no auth needed). Submitting / editing a review stays online-only and
   goes through `OnlineGuard`.
4. `FavoritesRepository` — **reads cached** (list renders offline);
   toggling stays online-only via `OnlineGuard`. After a successful
   online toggle, the repository upserts the local row so the list
   reflects the change on the next offline session.
5. `CustomerOrdersRepository.list()` & `.get()` (history is browsable offline)
6. `CustomerReservationsRepository.list()` & `.get()` (history is browsable
   offline)

> After a successful online order/reservation creation, the repository upserts
> the new row into the local cache so it shows up in the offline-browsable
> history list immediately.

---

### Phase 4 — Online-only flows: guard & UX (1 day)

> Replaces the previous "offline-friendly auth" phase. Auth, profile, order
> creation, and reservation creation **require** connectivity in v1.

#### Auth
- [ ] `AuthBloc` on app start: if no connectivity → emit `AuthUnknown` and
      route to a "You're offline — connect to sign in" screen instead of
      calling `me()`. Do **not** read a cached user.
- [ ] Login / Register pages: disable the submit button when offline, with
      a snackbar explaining why.
- [ ] Logout: require online (so the server token is invalidated). If the
      user really wants to clear the session offline, offer a separate
      "Clear local data" destructive action.

#### Profile
- [ ] Profile page (view + edit) checks `ConnectivityService.isOnline()`
      before rendering. If offline → show an "Offline — profile unavailable"
      empty state with a Retry button.
- [ ] Edit-profile save button is disabled offline.

#### Create delivery order
- [ ] `OrderRequestCubit.submitDelivery` calls `OnlineGuard.require()`
      first. If offline → emit `OrderRequestOfflineBlocked` and the page
      shows a dialog: "You need an internet connection to place an order."
- [ ] Cart contents are preserved (they're local state) so the user can
      retry as soon as they're back online.

#### Create reservation
- [ ] Same pattern as create order — guard at the cubit entry point,
      preserve the form, surface a clear offline message.

#### Other writes
- [ ] Review submission / edit goes through `OnlineGuard` (online-only).
- [ ] Favourite toggle goes through `OnlineGuard`. The heart icon is
      disabled offline with a tooltip. On a successful online toggle the
      `FavoritesRepository` upserts the local row so the list reflects
      the change next time the user is offline.

---

### Phase 5 — Conflict & error handling (1 day)

> Much smaller scope than the old plan because we don't have a generic
> outbox.

- [ ] Cache TTL strategy: keep `cachedAt` on every cached row; refuse to show
      cache older than 7 days for restaurants/menus and force an online
      reload (configurable constant).
- [ ] Last-write-wins for cached reads — the server is always source of
      truth, local cache is replaced wholesale on refresh.
- [ ] Auth-expired (401) on any read refresh: clear session, route to login,
      keep cached read data so the next user lands on a warm app.
- [ ] Schema-version column on cached JSON rows; bump invalidates cache.

---

### Phase 6 — UX polish (1 day)

- [ ] Persistent offline banner (from phase 1) with a Retry action.
- [ ] `cached_network_image` everywhere we currently use `Image.network`
      (menu items, restaurant covers).
- [ ] Empty states: "You're offline and we haven't cached this restaurant
      yet."
- [ ] Disable buttons for online-only actions (login, register, place order,
      create reservation, edit profile, submit review, toggle favourite,
      payment) with a tooltip.
- [ ] Pull-to-refresh on lists forces a remote fetch and shows
      `SnackBar("You're offline")` if it fails.

---

### Phase 7 — Testing & rollout (2 days)

> Only when explicitly requested (per CLAUDE.md). When asked:

- [ ] Unit tests for `ConnectivityService` (mock `connectivity_plus`
      + http probe).
- [ ] Repository tests asserting SWR behaviour (cache emitted first, then
      fresh data on success, cache preserved on failure).
- [ ] BLoC tests for `OrderRequestCubit` in offline mode (asserts the
      offline-blocked state is emitted and no HTTP call is made).
- [ ] Manual QA checklist:
  - Airplane mode → app launches, history & menus visible, reviews
    readable, favourites list readable, login/order/reservation/
    submit-review/toggle-favourite CTAs disabled with offline message.
  - Toggle airplane mode off → can log in, place order, toggle a
    favourite; new order appears in history both online and after going
    offline again. Favourite change is reflected in the offline list.
  - Token expired → next online refresh routes to login.

Rollout: ship behind a build flag `offlineMode=true` first, then default
on after a week of dogfooding.

---

## 5. Cross-Cutting Decisions

### Confirmed
1. **Local DB**: ✅ **Drift** (SQLite). Strongly-typed, reactive `.watch()`
   streams, supports the joins we need for menus and orders.
2. **Repository return type**: ✅ **`Stream<Either<Failure, T>>`** for
   read paths. Cubits/BLoCs subscribe and emit `Loaded` on every value;
   Drift's `.watch()` plugs in naturally.
3. **Favourites & reviews scope**: ✅
   - Favourites: offline **read only** (the list is cached after the
     last online sync and renders offline). Toggling stays online-only
     via `OnlineGuard`.
   - Reviews: offline read (anonymous, no auth required); submit / edit
     stays online-only via `OnlineGuard`.

### Open
4. **What is "out of scope" for offline v1?** Suggested out-of-scope (in
   addition to auth/profile/order/reservation/review/favourite-toggle
   writes): payments, real-time order status updates.
5. **Cache eviction policy** — disk quota or just time-based TTL?

## 6. Estimated Effort

| Phase | Estimate |
|---|---|
| 0 — Deps | 0.5 d |
| 1 — Connectivity | 0.5 d |
| 2 — DB schema | 1.5 d |
| 3 — Cache reads | 2.5 d |
| 4 — Online-only guards | 1 d |
| 5 — Conflicts / cache TTL | 1 d |
| 6 — UX polish | 1 d |
| 7 — Tests | 2 d (on request) |
| **Total** | **~8 dev-days** (1 dev) |

Roughly half the original ~13–15 day estimate — we skip the generic
outbox, background sync, offline-auth, and the favourites reconciler.

## 7. Risks

- **Schema drift** between cached JSON and entity classes — mitigate with
  versioned cache rows (`schemaVersion` column) and invalidate on bump.
- **Storage bloat** from cached images/menus — add a periodic cleanup task.
- **Stale history** — a user looking at an old cached order may miss a
  server-side status update; mark the screen with `cachedAt` and force a
  refresh when online.
- **User frustration if offline guards are too aggressive** — make sure the
  blocked-CTA messaging is friendly and the cart/form state is preserved.
- **Stale favourites list** — the cached favourites list reflects the
  state at the last online sync. If the user toggled on another device
  while this one was offline, the list will be slightly out of date until
  the next online refresh. Acceptable for read-only offline favourites.

---

## Appendix A — Future work: offline writes (Outbox)

Kept for reference if we later decide to allow creating orders/reservations
offline. Not built in v1.

- Add `uuid` + `OutboxTable(id, entityType, operation, payloadJson,
  createdAt, attemptCount, lastError, nextRetryAt)`.
- Cubit flow: generate clientId, insert local row with `syncStatus = pending`,
  enqueue outbox entry, emit success immediately.
- `SyncService` subscribes to `onlineStream`, drains the outbox with
  exponential backoff, swaps clientId → serverId on success.
- Requires backend support for `Idempotency-Key` headers on
  order/reservation POSTs to avoid duplicate writes on retry.
- Optional `workmanager` task to drain the outbox when the app is killed.
