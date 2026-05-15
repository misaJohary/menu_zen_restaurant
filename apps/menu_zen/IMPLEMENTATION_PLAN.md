# Menu Zen Customer — Implementation Plan

> Companion to [`apps/design.md`](../design.md) and
> [`CUSTOMER_API_DOCS.md`](./CUSTOMER_API_DOCS.md). Sequenced, step-by-step
> plan to build the customer-facing app inside the existing Melos monorepo,
> reusing the patterns from `menu_zen_mobile` / `menu_zen_tablet`.

---

## 0. Ground rules

- **Architecture**: Clean Architecture + BLoC (see root `CLAUDE.md`).
  - `domain` → pure Dart entities, repository interfaces, use cases.
  - `data` → models (`json_serializable`), datasources (Dio), repository
    impls returning `Either<Failure, T>`.
  - `design_system` → tokens (`AppColors`, `AppTypography`, `AppSpacing`,
    `AppRadii`, `AppMotion`) + shared widgets.
  - `apps/menu_zen` → only `core/` + `presentation/`. Never imports `data`
    from widgets.
- **State**: `flutter_bloc` only. Cubit for linear flows, BLoC for
  multi-event flows (per §10.4 of `design.md`).
- **DI**: `get_it` + `injectable`. BLoC = factory, repos/use cases =
  `@lazySingleton`. DI lives in the app, never in packages.
- **Auth**: customer JWT (`typ: "customer"`) — separate from staff token.
  Save under a dedicated key (e.g. `customer_access_token`) so a device
  with both apps can keep them apart.
- **Backend base URL**: same FastAPI host as the staff apps; pull from
  `.env.local` / `.env.staging` like `menu_zen_mobile` already does.
- **Naming**: app package stays `menu_zen` (matches the directory). Display
  name is "Menu Zen".

---

## 1. Milestones at a glance

| # | Milestone | Deliverable |
|---|---|---|
| M1 | Foundations | App skeleton, DI, routing, env, theme, auth shell |
| M2 | Domain & Data extensions | New entities, repos, use cases for customer-side |
| M3 | Discovery | Home (3 rails), Search (list + map), filters |
| M4 | Restaurant detail | Hero, sticky tabs (Menu / Reserve / Reviews / About) |
| M5 | Reservations | Wizard, confirmation, list, cancel |
| M6 | Orders | Cart, checkout, list, tracking (WebSocket) |
| M7 | Profile & favorites | Favorites, addresses, language, sign-out |
| M8 | Polish | Empty/error/offline states, a11y, motion, dark theme |
| M9 | Ship-prep | Icons, splash, store metadata, builds |

Each milestone below is broken into concrete, ordered steps.

---

## 2. Milestone 1 — Foundations

Goal: a runnable app shell with theme, routing, DI, env loading, and a
stubbed auth flow — but no customer features yet.

### 2.1 Pubspec & workspace

1. Update `apps/menu_zen/pubspec.yaml`:
   - Set `name: menu_zen`, `description: "Menu Zen — the diner's
     pocket concierge."`, `version: 0.1.0+1`, `resolution: workspace`.
   - Depend on `domain`, `data`, `design_system` (path packages).
   - Mirror `menu_zen_mobile`'s baseline (`flutter_bloc`, `get_it`,
     `injectable`, `go_router`, `dio`, `web_socket_channel`,
     `flutter_dotenv`, `shared_preferences`, `cached_network_image`,
     `skeletonizer`, `google_fonts`, `intl`, `logger`, `jwt_decoder`,
     `equatable`, `flutter_form_builder`, `form_builder_validators`).
   - Add customer-specific packages (per design §10.5):
     - `geolocator`
     - `flutter_map`, `latlong2`
     - `flutter_blurhash`
     - `lottie`
     - `qr_flutter`
     - `flutter_svg`
     - `flutter_animate`
     - `phosphor_flutter` (icon set called out in design §3.6)
     - `image_picker` (for avatar update)
   - Dev deps: `flutter_lints`, `injectable_generator`, `build_runner`.
2. Declare assets folders: `assets/`, `assets/illustrations/`,
   `assets/lottie/`, `.env.local`, `.env.staging`.
3. Add `.env.local` and `.env.staging` (gitignored shapes copied from
   `menu_zen_mobile`): `API_BASE_URL`, `WS_BASE_URL`, `ENV`.
4. Run `melos bootstrap` at the monorepo root.

### 2.2 App entrypoints

Match the staff-app pattern (`main.dart` + `main_local.dart` +
`config_main.dart`):

1. `lib/config_main.dart` — `MainConfig` with `envFile`, `flavor`.
2. `lib/main_local.dart` — loads `.env.local`, calls `bootstrap`.
3. `lib/main.dart` — loads `.env.staging` (or prod), calls `bootstrap`.
4. `lib/app.dart` — root `MaterialApp.router`, theme, locale, scroll
   behavior, providers (multi-`BlocProvider` for app-wide blocs:
   `AuthBloc`, `CartCubit`, `ProfileCubit`).

### 2.3 Core scaffolding

Create the following under `lib/core/`:

```
core/
├── di/dependencies_injection.dart       # @InjectableInit
├── env/env.dart                          # typed dotenv access
├── error/                                # presentation-level Failure→message
├── navigation/app_router.dart           # GoRouter declaration
├── navigation/route_paths.dart          # constants for paths
├── network/                              # Dio interceptors (auth, logging)
├── storage/customer_token_storage.dart  # SharedPreferences wrapper
└── utils/                                # extensions, formatters
```

Notes:
- Reuse `data/lib/http/` and `data/lib/services/` where the staff apps
  already centralize Dio config. Inject a **customer-scoped** Dio
  instance keyed by `@Named('customer')` so it sends the customer JWT.
- Token storage key: `customer_access_token`. Never share with staff
  app's token storage.

### 2.4 Routing (go_router)

Implement the tree from `design.md` §10.6 with two nested shells:

```
/onboarding
/auth (subtree: /auth/phone, /auth/otp, /auth/email)
/  (ShellRoute: bottom nav with 4 tabs)
   /discover
   /search
   /bookings
   /profile
/restaurant/:id
   /restaurant/:id/reserve
   /restaurant/:id/order
/order/:id/track
/booking/:id
```

`redirect` rules:

- Unauthenticated → can access `/onboarding`, `/auth/*`, `/discover`,
  `/search`, `/restaurant/:id` (read-only).
- Auth required on `/restaurant/:id/reserve`, `/restaurant/:id/order`,
  `/order/:id/track`, `/booking/:id`, `/bookings`, `/profile`. Send to
  `/auth/phone` and return to the original location after success.
- Auth state pulled from `AuthBloc` via a `Listenable` adapter on the
  router's `refreshListenable`.

### 2.5 Design tokens & theme

In `packages/design_system/lib/src/`:

1. Add (or extend) `tokens/`:
   - `app_colors.dart` — light + dark palettes from design §3.2.
   - `app_typography.dart` — Fraunces (display) + Inter (body); use
     `google_fonts`. Scale per §3.3.
   - `app_spacing.dart` — `2, 4, 8, 12, 16, 20, 24, 32, 40, 56, 80`.
   - `app_radii.dart` — `sm/md/lg/xl/pill`.
   - `app_motion.dart` — durations + curves for `tap / transition /
     ambient`. Honor `MediaQuery.disableAnimations`.
2. Export them through `design_system.dart`.
3. Build `ThemeData` for light + dark using `ColorScheme.fromSeed` seeded
   on `brand.terracotta`, then override component themes
   (`CardTheme`, `FilledButtonTheme`, `ChipTheme`, `BottomNavigationBar`,
   `AppBarTheme`) so cards use 1-px hairlines (no Material shadow), pills
   are pill-radius, etc.

### 2.6 Auth shell (stub)

Use the existing `AuthRepository` shape from `packages/domain` as
inspiration but add customer-specific use cases. Concrete endpoints
(from `CUSTOMER_API_DOCS.md` §1):

- `POST /customers/register`
- `POST /customers/login` (form-urlencoded; username may be email or
  phone)
- `GET /customers/me`
- `PATCH /customers/me`
- `POST /customers/me/password`
- `DELETE /customers/me`

For M1, ship only the **email/password** path end-to-end. Phone-OTP
(design §6.9) and Google sign-in are deferred to M9 unless backend
already supports them — track as open question.

Steps:

1. `domain`: `customer_entity.dart`, `customer_token_entity.dart`,
   `auth_repository_customer.dart` (separate from staff auth).
2. `data`: `customer_model.dart` (`@JsonSerializable(fieldRename:
   FieldRename.snake)`), `customers_remote_datasource.dart`,
   `auth_repository_customer_impl.dart` returning `Either<Failure,
   CustomerTokenEntity>`.
3. Use cases: `RegisterCustomer`, `LoginCustomer`, `GetMyProfile`,
   `UpdateMyProfile`, `ChangePassword`, `DeleteMyAccount`, `LogOut`.
4. `AuthBloc` with events `AuthStarted`, `AuthLoggedIn`, `AuthLoggedOut`,
   `AuthTokenExpired`, states `AuthInitial`, `AuthAuthenticated`,
   `AuthUnauthenticated`.
5. Pages: `OnboardingPage` (3 swipeable Lottie cards, skippable),
   `PhoneEntryPage` (stub for now), `EmailLoginPage`, `RegisterPage`.
   "Guest" mode = `AuthUnauthenticated` allowed on Discover/Search.

### 2.7 Definition of done — M1

- `flutter run` boots into Discover (empty placeholder), bottom nav
  switches between 4 stub tabs, light/dark themes both render, dotenv
  values logged at startup, tapping a gated screen prompts auth, and a
  full register → login → logout round-trip works against the real
  `/customers/*` API.

---

## 3. Milestone 2 — Domain & data extensions

Goal: add the customer-side domain surface to `packages/domain` +
`packages/data`. Nothing UI-facing here — but every later milestone
depends on this layer being clean.

### 3.1 New / extended entities (`packages/domain/lib/entities/`)

- `customer_entity.dart` — id, email, phone, fullName, avatar, createdAt.
- `customer_token_entity.dart` — accessToken, tokenType, customer.
- `favorite_entity.dart` — id, createdAt, restaurant (`RestaurantEntity`).
- `review_entity.dart` — id, rating, comment, createdAt, customer
  (display\_name + avatar), restaurantId.
- `review_summary_entity.dart` — avg, count, histogram (1..5 → int).
- `customer_reservation_entity.dart` — id, reservedAt, status (reuse
  `ReservationStatus`), partySize, note, createdAt, restaurant,
  assignedTables.
- `customer_order_entity.dart` — id, restaurantId, restaurantTableId,
  orderType (enum: dineIn / pickup / delivery), orderStatus, payment\
  Status, contactName, contactPhone, scheduledFor, totalAmount,
  items: `List<CustomerOrderItemEntity>`, createdAt.
- `customer_order_item_entity.dart` — id, menuItemId, quantity,
  unitPrice, notes.
- `cart_entity.dart` + `cart_item_entity.dart` — local-only; not from
  API. Holds the in-progress order before POST.
- `address_entity.dart` — local-only for now (backend has no addresses
  endpoint yet; see open question).
- `opening_hours_entity.dart` — timezone + periods (day 0..6 → slots).
- `geo_point_entity.dart` — lat, long (small value object).
- `discovery_filters.dart` — value object for Search/Discover queries.

Reuse existing: `RestaurantEntity`, `MenuEntity`, `MenuItemEntity`,
`CategoryEntity`, `LanguageEntity`, `TranslationBase`, etc. — already
defined in `packages/domain/lib/entities/`.

### 3.2 New repository interfaces (`packages/domain/lib/repositories/`)

Each method returns `Future<Either<Failure, T>>`.

- `customer_auth_repository.dart`
  - `register(CustomerCreateParams)`, `login(LoginParams)`, `me()`,
    `updateMe(CustomerUpdateParams)`, `changePassword(...)`,
    `deleteMe()`.
- `public_restaurants_repository.dart` (unauthenticated)
  - `searchNearby(SearchParams)` → `RestaurantSearchResponse`.
  - `getRestaurant(int id)` → `RestaurantDetailEntity`.
  - `listMenus(int restaurantId, {limit, offset})`.
  - `listCategories(int restaurantId, {limit, offset})`.
  - `listMenuItems(int restaurantId, {menuId, categoryId, search,
    limit, offset})`.
  - `getMenuItem(int id)`.
  - `listReviews(int restaurantId, {sort, limit, offset})`.
  - `getReviewSummary(int restaurantId)`.
- `favorites_repository.dart`
  - `list({limit, offset})`, `add(int restaurantId)`,
    `remove(int restaurantId)`.
- `customer_reviews_repository.dart`
  - `create(ReviewCreateParams)`, `listMine({limit, offset})`,
    `update(int id, ReviewUpdateParams)`, `delete(int id)`.
- `customer_reservations_repository.dart`
  - `create(ReservationCreateParams)`, `listMine({status, limit,
    offset})`, `get(int id)`, `cancel(int id)`.
- `customer_orders_repository.dart`
  - `create(OrderCreateParams)`, `listMine({status, limit, offset})`,
    `get(int id)`, `cancel(int id)`.
- `geolocation_repository.dart` — `currentPosition()`,
  `requestPermission()`. Thin wrapper over `geolocator`. Lives in
  `domain` so the BLoC can depend on the interface; impl in `data`.
- `order_events_repository.dart` — exposes a `Stream<OrderEvent>` per
  restaurant\_id; backs the WebSocket in `CUSTOMER_API_DOCS.md` §8.

### 3.3 Use cases (`packages/domain/lib/usecases/`)

One file per use case. Group under sub-folders by feature
(`discovery/`, `favorites/`, `reservations/`, `orders/`, `reviews/`,
`profile/`).

Each implements `UseCase<Out, In>` (base class — copy from existing app
or move to `domain/usecases/base.dart`).

### 3.4 Data layer (`packages/data/`)

For each entity:

1. `models/<name>_model.dart` with `@JsonSerializable(fieldRename:
   FieldRename.snake)`. Many existing models can be reused; create only
   what's new (customer, favorites, reviews, customer reservation,
   customer order, review summary, opening hours, geo).
2. `datasources/<name>_remote_datasource.dart` — uses a customer-scoped
   `Dio` (see §2.3). Public endpoints get a separate unauthenticated
   `Dio` instance.
3. `repositories/<name>_repository_impl.dart` — catch `DioException`,
   translate to `Failure` (`ServerFailure`, `UnauthorizedFailure`,
   `NetworkFailure`, `NotFoundFailure`, etc.).
4. Register all of the above with `@LazySingleton(as:
   <DomainInterface>)`.

### 3.5 Code generation

Run once after every entity/model change:

```bash
cd packages/data && dart run build_runner build --delete-conflicting-outputs
```

### 3.6 Definition of done — M2

- `flutter analyze` is clean across `domain`, `data`, and `menu_zen`.
- A throwaway "smoke test" page in the app (gated behind a debug flag)
  can call each repository against the real backend and prints results
  to the console.

---

## 4. Milestone 3 — Discovery & Search

### 4.1 Design system widgets (build first, reuse everywhere)

Add to `packages/design_system/lib/src/widgets/`:

- `RestaurantCard` (3 variants: `wide`, `compact`, `editorial`).
- `MoodChip` — pill, selectable, with icon.
- `StatusPill` — `Open · Closes 22h` / `Closed`. Color comes from
  `accent.sage` / `signal.warning` / `signal.error`. Shape always
  changes too (not color-only) — small dot + text.
- `HeartButton` — animated spring + 6-particle confetti on add only.
  Honors `disableAnimations`.
- `EmptyState` — illustration slot + title + body + single CTA.
- `SteamLoader` — custom pull-to-refresh indicator.
- `BlurhashImage` — `Image.network` wrapper using `flutter_blurhash`
  while loading, `errorBuilder` with typographic fallback.

### 4.2 Discover page (`presentation/pages/discover/`)

`DiscoverCubit` (linear → cubit). Loads:

1. Greeting + city (from `GeolocationRepository` reverse-geocode, or
   from profile-stored city if permission denied).
2. Mood chips (static list at v1).
3. Three rails via `PublicRestaurantsRepository.searchNearby` with
   different sort/limit:
   - **Near you** — `radius_km` 10, sorted by distance asc.
   - **Trending this week** — same call, future flag for backend
     sort = `popular`. For v1 just call with `limit=10` ordered by
     distance and **mark** the section title — the design accepts this
     as a placeholder ranking.
   - **Picked for you** — single editorial card. For v1 = the
     restaurant with highest `avg_rating` among nearby. Add a TODO to
     swap for a real `/recommended` endpoint when backend ships it.

States: `DiscoverInitial`, `DiscoverLoading`, `DiscoverLoaded({near,
trending, pick, city})`, `DiscoverError`.

UX rules from design §6.1:

- Skeletonizer cards while loading. No spinners.
- "Picked for you" cold-start: when the customer has no history, swap
  the title to **"New on Menu Zen"** and use the most-recently-added
  restaurant.
- Distance never shows `"0 km"` or `"—"` — hide the chip when location
  is unknown.

### 4.3 Search page (`presentation/pages/search/`)

`SearchBloc` (multi-event). Events:

- `SearchQueryChanged(String q)` (debounced 300 ms).
- `SearchFiltersChanged(DiscoveryFilters f)`.
- `SearchModeToggled(SearchMode mode)` — `list` / `map`.
- `SearchScrolledEnd()` — pagination.

States: `SearchIdle`, `SearchLoading`, `SearchLoaded({items, hasMore,
mode})`, `SearchEmpty`, `SearchError`.

Map mode:

- `flutter_map` + OSM tiles. Cluster pins (use
  `flutter_map_marker_cluster`).
- Bottom sheet (`DraggableScrollableSheet`, peek 24%, expand 70%).
- Pin tap → center map + scroll sheet to that card.
- Sheet horizontal swipe → pan map to next/prev result. (Use
  `PageView` inside the sheet for the swipe; map updates in a listener.)

Filter sheet:

- Cuisine (multi), Price `$..$$$$`, Open now / Open at <time>,
  Distance slider 0.2–10 km, Capabilities (reservations / delivers /
  takeaway), Dietary (veg / halal / vegan / GF).
- One **sticky** "Show N places" button — no apply-on-tap.
- Filters that aren't yet backend-supported (capabilities, dietary)
  are applied client-side on the response — flag this in code with a
  `// TODO(api):` comment.

### 4.4 Definition of done — M3

- Cold launch → first paint of Discover < 1.5 s on a mid-range Android.
- Search returns within 600 ms for typical query.
- Map opens in < 800 ms; pin selection updates sheet instantly.
- Reduce-motion mode: all hero / spring animations collapse to
  opacity-only crossfades.

---

## 5. Milestone 4 — Restaurant detail

### 5.1 `RestaurantDetailCubit`

States: `Initial`, `Loading`, `Loaded({detail, menusByCategory,
reviewsPreview, summary})`, `Error`.

`load(int restaurantId)` fans out four calls in parallel:

- `getRestaurant(id)` → `RestaurantDetailEntity`.
- `listCategories(id)` + `listMenuItems(id)` → grouped by category.
- `listReviews(id, sort: recent, limit: 5)`.
- `getReviewSummary(id)`.

Use `Future.wait` and emit one combined state. Each section can
re-fetch independently on retry.

### 5.2 Page anatomy (`presentation/pages/restaurant/`)

- `RestaurantDetailPage` — single `CustomScrollView` with:
  - `SliverAppBar` parallax 0.5× hero (`flutter_animate` `.animate`
    + scroll listener; or `SliverAppBar(stretch: true,
    flexibleSpace: FlexibleSpaceBar(...))` with manual parallax).
  - Title + meta line + status pill.
  - Sticky `TabBar` with 4 tabs: **Menu**, **Reserve**, **Reviews**,
    **About**.
  - Tab content as sliver lists.
  - `BottomAppBar` with two filled buttons: **Reserve** and **Order
    delivery**. Fades in once scroll past the hero (`AnimationController`
    driven by `ScrollController.offset`).
- Hero transition from `RestaurantCard.cover` → detail hero using a
  `Hero(tag: 'cover-${id}')`.

### 5.3 Menu tab

- Sections come from `CategoryEntity.translations` (use device locale,
  fallback to restaurant default language).
- Each row: thumbnail (`BlurhashImage`), name, 2-line clamp
  description, price.
- Inactive / unavailable items are dimmed and tagged `Unavailable`
  (same handling as recent commit `0ad2061` in `menu_zen_mobile`).
- Tap → `MenuItemSheet` (bottom sheet, 90% height), with quantity
  stepper and **Add to cart — Ar 18 000** CTA.

### 5.4 Reserve tab

- Inline date strip (next 14 days, scrollable).
- Party-size stepper (1–10 default, "+" to type bigger).
- Time grid for the chosen day — generated from `opening_hours` for now
  (slots every 30 min). Add a `// TODO(api):` for a real
  `/restaurants/{id}/availability?date=` endpoint when backend ships it.
- CTA → `/restaurant/:id/reserve` (wizard, see M5) prefilled.

### 5.5 Reviews tab

- Aggregate header: avg + histogram bars (`ReviewSummary`).
- Reviews list (paginated). Sort menu: Recent / Top / Low.
- v1 is **read-only**. Writing reviews is gated behind a feature flag
  (`features.write_reviews = false`) and lives in M9 if pulled in.

### 5.6 About tab

- Address + small static map snippet
  (`flutter_map`, single tile, non-interactive).
- Phone (tap to call via `url_launcher`).
- Opening hours table (use `OpeningHoursEntity`).
- Social media links.
- Languages spoken.

### 5.7 Definition of done — M4

- Hero transition from a Discover card opens detail in < 280 ms.
- "Order delivery" CTA is disabled with a polite tooltip when the
  restaurant doesn't deliver (see open question — feature flag on the
  entity, default true).
- All tabs read translated content in device locale.

---

## 6. Milestone 5 — Reservations

### 6.1 Wizard (`presentation/pages/reservation/`)

`ReservationBloc` (multi-step). Events:

- `WizardStarted({restaurantId, prefill})`.
- `DateSelected(DateTime)`.
- `TimeSelected(TimeOfDay)`.
- `PartySizeChanged(int)`.
- `ContactEdited({name?, phone?, note?})`.
- `WizardSubmitted()`.

States: `Step1WhenAndSize`, `Step2Who`, `Step3Confirm`, `Submitting`,
`Confirmed(CustomerReservationEntity)`, `Failed(Failure)`.

Each step is a separate page with progress dots at the top. Step 2's
contact fields are prefilled from `Profile` (`/customers/me`).

### 6.2 Confirmation page

- Circular sage check (`accent.sage`).
- Booking summary card (restaurant + datetime + party + note).
- `QR` (encode `reservation:{id}` — host scans to mark seated).
- CTAs: **Add to calendar** (use `add_2_calendar`), **Get directions**
  (open native maps via `url_launcher`).

### 6.3 Reservation list & cancel

- Lives inside `BookingsPage` (M7's host).
- `cancel` calls `PATCH /customers/me/reservations/{id}/cancel`. Show
  optimistic state, rollback on 409. Already-cancelled returns 200 →
  no-op UI-side.

### 6.4 Status mapping

API enum: `active | honored | cancelled | no_show`. Map to the
design's `pending → confirmed → seated → completed`:

- API `active` → display "Confirmed".
- API `honored` → display "Completed".
- API `cancelled` → "Cancelled".
- API `no_show` → "Missed".

Document this mapping in `core/utils/reservation_status_mapper.dart` so
it's only defined once.

### 6.5 Definition of done — M5

- Wizard supports back-navigation without losing state.
- Cancellation works idempotently and shows the right copy when too
  late (409).
- Calendar export contains restaurant name, party size, address.

---

## 7. Milestone 6 — Orders

### 7.1 Cart (`presentation/bloc/cart/`)

`CartCubit` — app-scoped (registered in root provider). State:

```dart
sealed class CartState {}
class CartEmpty extends CartState {}
class CartActive extends CartState {
  final int restaurantId;
  final List<CartItemEntity> items;
  final int subtotal; // cents-equivalent integer
}
```

Rules from design §6.5:

- **Single-restaurant cart**. Adding from a second restaurant prompts
  "Discard current order from X?" with confirm.
- Persisted across app restarts via `shared_preferences` (JSON).
- Computes subtotal from the latest `MenuItemEntity.price` — server
  recomputes anyway, but we show what we have.

### 7.2 Checkout page (`presentation/pages/order/`)

- Items list (editable quantities).
- Delivery address card (from local `AddressEntity` storage — backend
  doesn't have addresses yet; flagged in open questions).
- Payment selector: Cash on delivery / Mobile money / Card.
  v1 only ships **Cash on delivery** (records intent locally; payment
  capture is a v2 backend concern). Other tiles are disabled with a
  "Coming soon" caption.
- Totals (subtotal + delivery fee placeholder + total).
- **Place order** button → `POST /customers/me/orders` (§6.1 in API
  docs).

For dine-in flows initiated from a table QR (out of scope for v1
customer app — staff/tablet domain). Customer-app orders default to
`delivery` or `pickup`.

### 7.3 Order tracking (`presentation/pages/order/tracking/`)

`OrderTrackingBloc` listens to the WebSocket at
`ws://<host>/ws/orders/{restaurant_id}` (`CUSTOMER_API_DOCS.md` §8).

Flow:

1. On mount, fetch order via `GET /customers/me/orders/{id}` for the
   baseline state.
2. Open the WS channel scoped to `order.restaurant_id`.
3. Filter incoming events to the current `order_id` client-side
   (server doesn't filter; note in §8).
4. Send `{"type":"ping"}` every 30 s; reconnect with exponential
   backoff (1, 2, 4, 8 s, capped at 30 s) on disconnect.
5. Emit a new state for each `order_cancelled` / status change.

Map to UI timeline: `Confirmed → Preparing → Out → Arriving →
Delivered`. Backend's `OrderStatus` (`created`, `in_preparation`,
`ready`, `served`, `cancelled`) maps as follows:

| API status | UI node |
|---|---|
| `created` | Confirmed |
| `in_preparation` | Preparing |
| `ready` | Out (delivery) / Ready (pickup) |
| `served` | Delivered |
| `cancelled` | Cancelled (full-screen state) |

Until we have rider GPS, show a kitchen illustration with animated
steam. Rider map is a v2 stub.

### 7.4 Cancel an order

- Allowed while `created` only (per API §6.4). Disable the cancel
  button otherwise.
- Show a confirm dialog before calling.

### 7.5 Definition of done — M6

- End-to-end: pick items → checkout → place → tracking page shows
  status updates pushed from the staff app in real time.
- WS reconnect handles airplane-mode toggle gracefully.
- Cart survives app restart.

---

## 8. Milestone 7 — Profile, favorites, language

### 8.1 Profile page

Sections (per design §6.8):

- My favorites → reuses `FavoritesPage`.
- Addresses → local CRUD only at v1.
- Payment methods → disabled placeholder.
- Language → opens picker (Inter `BottomSheet`). On change, calls
  `LanguagesRepository.list` once, persists choice to `shared_preferences`,
  rebuilds `MaterialApp.router` `locale`. Translated content uses the
  matching `TranslationBase` row from each entity.
- Dietary preferences → local toggles, fed to Search filter defaults.
- Notifications → permissions only; push tokens belong to staff app.
- Help → email/phone, opens `mailto:` / `tel:`.
- Sign out → clears token, navigates to `/auth/phone`.
- Delete account → `DELETE /customers/me`, then sign out flow.

### 8.2 Favorites

- `FavoritesCubit` — list, add, remove.
- Add is idempotent server-side; UI does optimistic update.
- Remove returns 204 always; UI updates immediately, rolls back on
  network failure.
- Empty state: "Your favorites live here. Tap ♡ on a place you love."

### 8.3 Bookings page

- Single screen, segmented control `Upcoming · Past`.
- Merge two streams (reservations + orders) into one chronological
  list with type-icons (knife-fork vs shopping bag).
- Tap → detail (reservation confirmation or order tracking).

### 8.4 Definition of done — M7

- Language change re-renders the entire app's translated content
  immediately.
- Favorites round-trip cleanly with the server, including idempotent
  add.

---

## 9. Milestone 8 — Polish

### 9.1 Empty / loading / error / offline

Per design §7. For every list and every detail page, implement all 5
states:

- Loading → `Skeletonizer`.
- Empty (cold) → editorial illustration + one CTA.
- Empty (after action) → friendly tone.
- Error → inline retry chip. Network: "We couldn't reach the kitchen."
- Offline → app-bar banner "You're offline — showing your last view.";
  cached lists remain readable. Use `connectivity_plus` (add to
  pubspec) and a `ConnectivityCubit` exposed app-wide.

Plus the special cases:

- Location denied → Discover swaps "Near you" for "Browse by city".
- Restaurant closed → detail disables Order, leaves Reserve enabled.
- Item out of stock at checkout → soft warning, not silent drop.
- Payment fail → keep cart, surface error.

### 9.2 Accessibility audit

- Run a contrast check on every token pair (Stark / manual).
- Test dynamic text scaling at 200% on each pivot screen.
- Wrap every interactive widget in `Semantics(label, button: true,
  …)`. Especially the heart, status pills, time-slot pills, and
  bottom-sheet handle.
- Tap targets ≥ 44 × 44.
- Walk through with VoiceOver and TalkBack; fix label gaps.

### 9.3 Motion

- Honor `MediaQuery.disableAnimations` everywhere (single helper:
  `effectiveCurve(BuildContext)` and `effectiveDuration(BuildContext)`).
- Verify the four signature moments (hero, parallax, sticky CTA, heart
  confetti) collapse cleanly.

### 9.4 Dark theme pass

- Re-check every screen — terracotta shifts to ember in dark, surface
  inverts. No hard-coded colors.

### 9.5 Definition of done — M8

- Every list/page screen has the 5 states implemented.
- A11y review checklist signed off.
- Dark mode parity verified screen-by-screen.

---

## 10. Milestone 9 — Ship prep

### 10.1 Branding assets

- App icon (terracotta on linen).
- Splash screen (`flutter_native_splash`).
- iOS launch storyboard.

### 10.2 Store metadata

- App name: **Menu Zen**.
- Subtitle: *"Discover · Reserve · Order"*.
- Description, screenshots in light + dark.
- Privacy policy URL (required).

### 10.3 Flavors & builds

- Android: `local`, `staging`, `prod` flavors.
- iOS: schemes mirroring the flavors.
- Release builds verified on both.

### 10.4 Crash + logging

- Use `dart:developer` `log()` per `CLAUDE.md`.
- Add Sentry or equivalent — confirm with user.

### 10.5 Definition of done — M9

- Both stores' submission checklist passes locally.
- TestFlight + Play Internal Testing tracks publish a build.

---

## 11. Open questions to resolve before / during build

Tracked from `design.md` §12 — re-check each before the milestone that
needs the answer.

| # | Question | Needed by |
|---|---|---|
| 1 | Final app name | M9 (store metadata) |
| 2 | Geographic scope at launch | M3 (city picker) |
| 3 | Does backend issue customer tokens? **YES** (per `CUSTOMER_API_DOCS.md` §1) | resolved |
| 4 | Payment providers (MVola / Orange / Airtel / Stripe) | M6 |
| 5 | Recommendation engine — backend? | M3 |
| 6 | Reviews — write at v1? | M4 / M9 |
| 7 | Map provider — OSM acceptable? | M3 |
| 8 | Phone-OTP backend support? (API docs only describe email/password) | M1 / M9 |
| 9 | Real availability endpoint for reservations? | M5 |
| 10 | Customer addresses endpoint? | M6 / M7 |

---

## 12. Reusing the staff apps — quick reference

Files worth reading before starting each section:

| Need | Look at |
|---|---|
| App entry / flavors pattern | `apps/menu_zen_mobile/lib/{main.dart, main_local.dart, config_main.dart, app.dart}` |
| DI setup | `apps/menu_zen_mobile/lib/core/injection/dependencies_injection.dart` |
| Dio + interceptors | `packages/data/lib/http/` and `packages/data/lib/services/` |
| Auth bloc shape | `apps/menu_zen_mobile/lib/presentation/bloc/auth/` |
| WebSocket usage | `apps/menu_zen_mobile/lib/presentation/bloc/orders/` and `packages/data/.../order_events*` |
| Order rendering edge cases (unavailable items) | commit `0ad2061` — `make_order_page.dart` |
| Translation handling | any entity in `packages/domain/lib/entities/` extending `TranslationBase` |

Do **not** copy staff-only code (kitchen, table management, stats) — the
customer app has no business reaching those endpoints.

---

## 13. Working agreement during build

- One PR per milestone, broken into smaller commits per step.
- After every step that touches `packages/data` entities, run
  `dart run build_runner build --delete-conflicting-outputs`.
- `melos run analyze` must pass before requesting review.
- No new state-management library, no new routing library, no new
  Material wrapper — stick to `flutter_bloc` + `go_router` per
  `CLAUDE.md`.
- Tests are **not** written automatically (`CLAUDE.md` rule). When the
  user asks, follow the `bloc_test` + `mocktail` pattern.

---

## 14. First-day checklist (start here)

1. `cd apps/menu_zen && flutter pub get` — confirm baseline runs.
2. Apply §2.1 pubspec changes; `melos bootstrap`.
3. Wire `main.dart` / `main_local.dart` / `config_main.dart` / `app.dart`
   from §2.2.
4. Drop in `AppColors` / `AppTypography` / theme into `design_system`
   (§2.5) and confirm `Theme.of(context).colorScheme` returns the
   linen palette.
5. Stand up the bottom-nav shell with 4 placeholder pages and a
   `redirect` rule (§2.4) so navigation works before any feature exists.
6. Build the email/password auth round-trip against the real API
   (§2.6) — this proves the Dio + token + DI plumbing for everything
   that follows.

When step 6 is green, M2 unblocks and the rest is feature work.
