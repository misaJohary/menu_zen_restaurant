# Menu Zen Mobile — Developer Guide

This guide documents everything needed to build the `menu_zen_mobile` Flutter app from scratch,
based on the existing `menu_zen_tablet` app, shared packages (domain / data / design_system),
and the provided UI mockups.

---

## 1. Overview

**Target user:** Restaurant server with admin-level access (super server).

**Screens:**
| Screen | Route | Nav tab |
|---|---|---|
| Login | `/login` | — |
| Make Order | `/main/commande` | Tab 1 — Commande |
| Order Card (Panier) | `/main/panier` | Tab 2 — Panier |
| Orders List | `/main/commandes` | Tab 3 — Commandes |
| Order Detail | `/order-detail/:id` | Pushed from Orders |
| Profile | `/profile` | Pushed from Orders |

---

## 2. Package Dependencies (pubspec.yaml)

Add the following to `apps/menu_zen_mobile/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Shared packages
  domain:
    path: ../../packages/domain
  data:
    path: ../../packages/data
  design_system:
    path: ../../packages/design_system

  # State management & DI
  flutter_bloc: ^9.1.1
  get_it: ^8.2.0
  injectable: ^2.5.1   # needed for GetItHelper (used by DataPackageModule)
  equatable: ^2.0.7

  # Navigation
  go_router: ^14.0.0

  # Networking
  dio: ^5.0.0

  # Config & storage
  flutter_dotenv: ^5.2.1
  shared_preferences: ^2.5.3

  # Serialization
  json_annotation: ^4.9.0
  jwt_decoder: ^2.0.1

  # UI & forms
  flutter_form_builder: ^10.1.0
  form_builder_validators: ^11.2.0
  google_fonts: ^8.0.2
  cached_network_image: ^3.4.1
  skeletonizer: ^2.1.0+1

  # Utilities
  intl: ^0.20.2
  logger: ^2.6.1
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/
    - .env.local
```

> **Note:** No `injectable_generator` or `auto_route_generator` needed — DI is set up manually,
> and navigation uses `go_router`.

---

## 3. File Structure

```
lib/
├── main.dart                   ← production entry point
├── main_local.dart             ← local dev entry point
├── config_main.dart            ← shared init (dotenv + DI)
├── app.dart                    ← MaterialApp.router + MultiBlocProvider
├── core/
│   ├── constants/
│   │   └── constants.dart      ← primaryColor alias + kspacing
│   ├── enums/
│   │   └── bloc_status.dart
│   ├── http_connexion/
│   │   └── interceptors.dart   ← LoggingInterceptors + RequestInterceptor
│   ├── injection/
│   │   └── dependencies_injection.dart   ← manual GetIt setup
│   └── navigation/
│       └── app_router.dart     ← go_router config
└── presentation/
    ├── bloc/
    │   ├── auth/
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   ├── orders/
    │   │   ├── orders_bloc.dart
    │   │   ├── orders_event.dart
    │   │   ├── orders_state.dart
    │   │   └── order_menu_item/
    │   │       ├── order_menu_item_bloc.dart   ← extended with note/price/offer events
    │   │       ├── order_menu_item_event.dart
    │   │       └── order_menu_item_state.dart
    │   └── tables/
    │       ├── table_bloc.dart
    │       ├── table_event.dart
    │       └── table_state.dart
    ├── pages/
    │   ├── login_page.dart
    │   ├── main_page.dart          ← StatefulShellRoute shell (bottom nav)
    │   ├── make_order_page.dart
    │   ├── order_card_page.dart
    │   ├── orders_page.dart
    │   ├── order_detail_page.dart
    │   └── profile_page.dart
    └── widgets/
        ├── logo.dart
        └── menu_item_options_sheet.dart
```

---

## 4. Design Tokens

Primary color for the mobile design is dark teal (different from the tablet's lime green):

```dart
// core/constants/constants.dart
import 'package:design_system/design_system.dart' show kspacing, categoryColors;
import 'package:flutter/material.dart';

// Mobile-specific primary (dark teal matching mockups)
const Color primaryColor = Color(0xFF006D6B);
```

Price formatting helpers (define wherever convenient, e.g. a `price_utils.dart`):

```dart
import 'package:intl/intl.dart';

/// Compact card format: 8500 → "8.50Ar"
String formatPriceCompact(double price) =>
    '${(price / 1000).toStringAsFixed(2)}Ar';

/// Full format: 45000 → "45 000 Ar"
String formatPriceFull(double price) =>
    '${NumberFormat('#,##0').format(price.toInt())} Ar';
```

---

## 5. Core Infrastructure Files

### 5.1 `core/enums/bloc_status.dart`
```dart
enum BlocStatus { init, loading, loaded, failed }
```

### 5.2 `core/http_connexion/interceptors.dart`
Copy from tablet. Replace `AppRouter.navKey` with a global navigator key:

```dart
// In app.dart (or a dedicated file):
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
```

Then in `RequestInterceptor.onError`:
```dart
final context = appNavigatorKey.currentContext;
```

### 5.3 `core/injection/dependencies_injection.dart`

No code generation. Manual setup using `GetItHelper` (from injectable) so that
`DataPackageModule().init(gh)` works correctly:

```dart
import 'package:data/config/base_url_config.dart';
import 'package:data/di/data_package_module.module.dart';
import 'package:data/services/db_service.dart';
import 'package:dio/dio.dart';
import 'package:domain/repositories/auth_repository.dart';
import 'package:domain/repositories/orders_repository.dart';
import 'package:domain/repositories/tables_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../http_connexion/interceptors.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/orders/orders_bloc.dart';
import '../../presentation/bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import '../../presentation/bloc/tables/table_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final gh = GetItHelper(getIt, null, null);

  // SharedPreferences (needed by DbService inside DataPackageModule)
  gh.lazySingleton<SharedPreferencesAsync>(() => SharedPreferencesAsync());

  // Base URL string (needed by RestClient inside DataPackageModule)
  gh.factory<String>(
    () => BaseUrlConfig.current,
    instanceName: 'BaseUrl',
  );

  // Dio without auth interceptor (needed by RequestInterceptor for token refresh)
  gh.lazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: BaseUrlConfig.current)),
    instanceName: 'noInterceptor',
  );

  // Dio with auth interceptor (used by RestClient)
  gh.lazySingleton<Dio>(
    () {
      final dio = Dio(BaseOptions(baseUrl: BaseUrlConfig.current));
      dio.interceptors
        ..add(LoggingInterceptors())
        ..add(RequestInterceptor(
          dio: getIt<Dio>(instanceName: 'noInterceptor'),
          db: getIt<DbService>(),
        ));
      return dio;
    },
    instanceName: 'withInterceptor',
  );

  // Data package: registers DbService, RestClient, all repository impls
  await DataPackageModule().init(gh);

  // App-level BLoC factories
  gh.factory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  gh.factory<OrdersBloc>(
    () => OrdersBloc(repo: getIt<OrdersRepository>()),
  );
  gh.factory<OrderMenuItemBloc>(
    () => OrderMenuItemBloc(repo: getIt<OrdersRepository>()),
  );
  gh.factory<TableBloc>(
    () => TableBloc(tablesRepository: getIt<TablesRepository>()),
  );
}
```

### 5.4 `config_main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:data/config/base_url_config.dart';
import 'core/injection/dependencies_injection.dart';

Future<void> configMain({required String env}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: env);
  await BaseUrlConfig.init(fallback: dotenv.env['BASE_URL'] ?? '');
  await configureDependencies();
}
```

### 5.5 `main.dart` / `main_local.dart`
```dart
// main.dart
import 'package:flutter/material.dart';
import 'config_main.dart';
import 'app.dart';

void main() async {
  await configMain(env: '.env.staging');
  runApp(App());
}

// main_local.dart
import 'package:flutter/material.dart';
import 'config_main.dart';
import 'app.dart';

void main() async {
  await configMain(env: '.env.local');
  runApp(App());
}
```

### 5.6 `.env.local`
```
BASE_URL=http://10.0.2.2:8000
```

---

## 6. Navigation (`core/navigation/app_router.dart`)

Uses `go_router` with a `StatefulShellRoute` for the 3-tab bottom navigation.

```dart
import 'package:go_router/go_router.dart';
import 'package:data/services/db_service.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/main_page.dart';
import '../../presentation/pages/make_order_page.dart';
import '../../presentation/pages/order_card_page.dart';
import '../../presentation/pages/orders_page.dart';
import '../../presentation/pages/order_detail_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../injection/dependencies_injection.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/main/commande',
    redirect: (context, state) async {
      final db = getIt<DbService>();
      final isAuth = await db.checkAuth();
      final isLoginPage = state.uri.path.startsWith('/login');
      if (!isAuth && !isLoginPage) return '/login';
      if (isAuth && isLoginPage) return '/main/commande';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainPage(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/main/commande',
              builder: (context, state) => const MakeOrderPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/main/panier',
              builder: (context, state) => const OrderCardPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/main/commandes',
              builder: (context, state) => const OrdersPage(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/order-detail/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OrderDetailPage(orderId: id);
        },
      ),
      GoRoute(
        path: '/make-order-edit',
        builder: (context, state) {
          final order = state.extra as OrderEntity?;
          return MakeOrderPage(order: order);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
```

### 5.7 `app.dart`
```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/injection/dependencies_injection.dart';
import 'core/navigation/app_router.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/orders/orders_bloc.dart';
import 'presentation/bloc/orders/order_menu_item/order_menu_item_bloc.dart';
import 'presentation/bloc/tables/table_bloc.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  App({super.key});

  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<OrdersBloc>()),
        BlocProvider(create: (_) => getIt<OrderMenuItemBloc>()),
        BlocProvider(create: (_) => getIt<TableBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Menu Zen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF006D6B),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: GoogleFonts.poppins().fontFamily,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        routerConfig: _router,
      ),
    );
  }
}
```

---

## 7. BLoC Files

### 7.1 Auth BLoC
Copy verbatim from `apps/menu_zen_tablet/lib/features/presentations/managers/auths/`:
- `auth_bloc.dart` — adjust import paths
- `auth_event.dart`
- `auth_state.dart`

Adjust import:
```dart
// Change:
import '../../../../core/enums/bloc_status.dart';
// To:
import '../../../core/enums/bloc_status.dart';
```

### 7.2 Orders BLoC
Copy from tablet's `managers/orders/`:
- `orders_bloc.dart`, `orders_event.dart`, `orders_state.dart`

Same import path adjustment.

### 7.3 Tables BLoC
Copy from tablet's `managers/tables/`:
- `table_bloc.dart`, `table_event.dart`, `table_state.dart`

### 7.4 OrderMenuItem BLoC (Extended)
Copy from tablet but **add** these new events for the bottom sheet:

```dart
// order_menu_item_event.dart — add these:

/// Update note on an item already in orderedItems (by index)
class OrderMenuItemNoteUpdated extends OrderMenuItemEvent {
  const OrderMenuItemNoteUpdated(this.orderedIndex, this.note);
  final int orderedIndex;
  final String note;
  @override List<Object?> get props => [orderedIndex, note];
}

/// Update price on an item already in orderedItems (by index)
class OrderMenuItemPriceUpdated extends OrderMenuItemEvent {
  const OrderMenuItemPriceUpdated(this.orderedIndex, this.newPrice);
  final int orderedIndex;
  final double newPrice;
  @override List<Object?> get props => [orderedIndex, newPrice];
}

/// Add an offered (free) copy of an ordered item
class OrderMenuItemOffered extends OrderMenuItemEvent {
  const OrderMenuItemOffered(this.item, this.offeredQuantity);
  final OrderMenuItem item;
  final int offeredQuantity;
  @override List<Object?> get props => [item, offeredQuantity];
}

/// Add a custom item (name + price) typed by the user
class OrderMenuItemCustomAdded extends OrderMenuItemEvent {
  const OrderMenuItemCustomAdded(this.name, this.price);
  final String name;
  final double price;
  @override List<Object?> get props => [name, price];
}
```

Add handlers in `order_menu_item_bloc.dart`:

```dart
on<OrderMenuItemNoteUpdated>(_onNoteUpdated);
on<OrderMenuItemPriceUpdated>(_onPriceUpdated);
on<OrderMenuItemOffered>(_onOffered);
on<OrderMenuItemCustomAdded>(_onCustomAdded);

void _onNoteUpdated(OrderMenuItemNoteUpdated event, Emitter<OrderMenuItemState> emit) {
  final items = List<OrderMenuItem>.from(state.orderedItems);
  if (event.orderedIndex < items.length) {
    items[event.orderedIndex] = items[event.orderedIndex].copyWith(notes: event.note);
    emit(state.copyWith(orderedItems: items));
  }
}

void _onPriceUpdated(OrderMenuItemPriceUpdated event, Emitter<OrderMenuItemState> emit) {
  final items = List<OrderMenuItem>.from(state.orderedItems);
  if (event.orderedIndex < items.length) {
    items[event.orderedIndex] = items[event.orderedIndex].copyWith(unitPrice: event.newPrice);
    emit(state.copyWith(orderedItems: items));
  }
}

void _onOffered(OrderMenuItemOffered event, Emitter<OrderMenuItemState> emit) {
  // Offered item = same menuItem, unitPrice = 0, separate entry
  final offeredItem = OrderMenuItem(
    menuItem: event.item.menuItem,
    quantity: event.offeredQuantity,
    unitPrice: 0.0,
    status: 'init',
  );
  emit(state.copyWith(
    orderedItems: [...state.orderedItems, offeredItem],
  ));
}

void _onCustomAdded(OrderMenuItemCustomAdded event, Emitter<OrderMenuItemState> emit) {
  final customItem = OrderMenuItem(
    menuItem: MenuItemEntity(
      id: null,
      translations: [_CustomTranslation(name: event.name)],
      price: event.price,
    ),
    quantity: 1,
    unitPrice: event.price,
    status: 'init',
  );
  emit(state.copyWith(
    orderedItems: [...state.orderedItems, customItem],
  ));
}
```

> **Note:** For `_CustomTranslation`, you need a concrete implementation of
> `MenuItemTranslation`. Since `MenuItemTranslation` is abstract (from domain),
> you can either add a simple concrete class in the mobile app or use an existing
> model from the data package. For example, use `MenuItemTranslationModel` from
> `packages/data/lib/models/menu_item_model.dart`.

---

## 8. Screen-by-Screen Implementation

### 8.1 Login Page (`login_page.dart`)

**Design:** White background, centered card with subtle shadow, no image side panel
(unlike tablet). Title "Click Menu Zen" above the card. Footer "SYSTÈME DE GESTION
HÔTELLERIE V2.4" with dots. Settings icon (top-right) for base URL. Connection dot (bottom).

**Behavior:** Identical to tablet login:
1. `FormBuilder` with `username` and `password` fields.
2. On submit → `AuthBloc.add(AuthLoggedIn(LoginParams(...)))`
3. On `AuthStatus.authenticated` → `AuthBloc.add(AuthUserGot())`
4. On loaded + authenticated → `context.go('/main/commande')`
5. On `AuthStatus.unauthenticated` → show snackbar

**Key widgets:**
```
Scaffold
└── Stack
    ├── Column (centered)
    │   ├── Text("Click Menu\nZen")  ← large teal title
    │   └── Card (rounded, shadow)
    │       └── FormBuilder
    │           ├── Label + FormBuilderTextField("username") ← with badge icon
    │           ├── Label + FormBuilderTextField("password") ← obscure + toggle eye
    │           └── ElevatedButton("SE CONNECTER")
    ├── Text("SYSTÈME DE GESTION HÔTELLERIE V2.4") + 3 dots  ← bottom center
    ├── IconButton(settings)  ← top right
    └── ConnectionIndicator  ← bottom center dot + text
```

### 8.2 Main Page — Bottom Nav Shell (`main_page.dart`)

```dart
class MainPage extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainPage({required this.shell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Commande'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Commandes'),
        ],
      ),
    );
  }
}
```

### 8.3 Make Order Page (`make_order_page.dart`)

**Design:**
- AppBar: hamburger + restaurant name
- Search bar (searches ALL items, ignores category filter)
- Body: `Row` → left category rail + right items grid
- Bottom: custom item quick-add row (`[Nom de l'article]  [Prix]  [+]`)

**Category rail:**
- Vertical list of category names
- Selected: left border + bold teal text
- "All" option at top (no filter)

**Item grid (2 columns, `GridView.builder`):**
- Card: name + price formatted as `formatPriceCompact(price)` → e.g. `8.50Ar`
- Badge top-right showing quantity when > 0 (teal pill)
- **Tap** → `OrderMenuItemBloc.add(OrderMenuItemIncremented(index))` + scale bounce animation
- **Long press** → `showMenuItemOptionsSheet(context, item, orderedIndex)`

**Quick-add field:**
```
Row [
  Expanded(TextField("Nom de l'article")),
  SizedBox(width: 100, TextField("Prix")),
  IconButton(+) → adds OrderMenuItemCustomAdded(name, price)
]
```

**Category derivation from items:**
```dart
final categories = state.orderMenuItems
    .map((i) => i.menuItem.category)
    .whereType<CategoryEntity>()
    .fold<List<CategoryEntity>>([], (list, cat) {
      if (list.every((c) => c.id != cat.id)) list.add(cat);
      return list;
    });
```

**Filtering:**
```dart
List<OrderMenuItem> get displayItems {
  if (searchQuery.isNotEmpty) {
    return state.orderMenuItems.where((i) =>
      i.menuItem.translations.isNotEmpty &&
      i.menuItem.translations.first.name
        .toLowerCase().contains(searchQuery.toLowerCase()),
    ).toList();
  }
  if (selectedCategory == null) return state.orderMenuItems;
  return state.orderMenuItems
    .where((i) => i.menuItem.category?.id == selectedCategory!.id)
    .toList();
}
```

**Item count badge:**
```dart
// Check orderedItems for total quantity of this menuItem.id
int badgeCount(int menuItemId) => state.orderedItems
    .where((o) => o.menuItem.id == menuItemId)
    .fold(0, (sum, o) => sum + o.quantity);
```

**Tap animation:**
Use `AnimatedScale` or an `AnimationController` per item card:
```dart
onTap: () {
  _animController.forward().then((_) => _animController.reverse());
  bloc.add(OrderMenuItemIncremented(globalIndex));
}
```
Or simply wrap with `InkWell` + a stateful scale widget.

### 8.4 Order Card Page (`order_card_page.dart`)

**Design:** Confirmation screen showing the cart.

```
AppBar: ← back   "Confirmation"
Body:
  Label "ARTICLES COMMANDÉS"  Badge("N PLATS")
  ListView of ordered items:
    Card per item:
      Row: item name (bold) + price (teal, large)
             OR "offerts" if unitPrice == 0
      if notes: Chip(notes text)  ← gray badge
      Row: TrashIcon  |  Spacer  |  [−]  qty  [+]
  ──────────────────────────────────────────
  SOUS-TOTAL:          XX XXX Ar
  TVA (20%):           (ignored for now — show disabled row)
  TOTAL À PAYER:       XX XXX Ar  (bold teal)
  ──────────────────────────────────────────
  Label "SÉLECTEUR DE TABLE"   "Table TX active"
  Horizontal chip list of tables
  ──────────────────────────────────────────
  Row: [VIDER btn]  [CONFIRMER btn]
BottomNav
```

**Price logic:**
- `unitPrice == 0` → show `"offerts"` in teal italic, no price number
- else → `formatPriceFull(unitPrice * quantity)` → `"45 000 Ar"`

**Subtotal:** sum of `item.unitPrice * item.quantity` for all items
**Total:** subtotal (TVA ignored)

**Vider:** `OrderMenuItemBloc.add(OrderMenuItemCleared())`

**Confirmer:**
- Validate table selected
- `OrdersBloc.add(OrderCreated(OrderEntity(..., orderMenuItems: orderedItems, restaurantTableId: selectedTableId)))`
- Listen for `createStatus == BlocStatus.loaded` → clear cart + navigate to Commandes tab

**Editing existing order:** When navigating here from orders screen edit button,
pass `OrderEntity order` and call `controller.orderUpdateInitiated(order)` in initState.
Use `OrdersBloc.add(OrderUpdated(...))` instead of `OrderCreated`.

**Long press item:** Same `showMenuItemOptionsSheet` as make_order page.

### 8.5 Orders Page (`orders_page.dart`)

**Design:**
- AppBar: hamburger + "Mes commandes" + user avatar (tappable → profile)
- Search bar
- Toggle tabs: `EN COURS (N)` | `FINI (N)` (pill style)
- `ListView` of order cards

**Order card:**
```
Card (rounded, shadow, teal border if all items ready)
  Row: time (HH:mm)  |  Spacer  |  Badge "X/Y"   ← ready items / total items
  Text: "Table TX"  (bold, large)
  Row: [eye icon btn]  [pencil icon btn]  [TERMINER btn (expanded)]
```

**Badge X/Y:**
```dart
final ready = order.orderMenuItems.where((i) => i.status == 'ready').length;
final total = order.orderMenuItems.length;
// Show "ready/total"
```

**Eye button** → `context.push('/order-detail/${order.id}')`
**Pencil button** → `context.push('/make-order-edit', extra: order)`
**TERMINER button** → `OrdersBloc.add(OrderStatusUpdated(order.id!, OrderStatus.served))`

**Filtering:**
- EN COURS: `orderStatus == created || inPreparation || ready`
- FINI: `orderStatus == served`

**Fetching:** `OrdersBloc.add(OrderFetched())` in initState.

**Search:** `OrdersBloc.add(OrderFetched(search: query))`

### 8.6 Order Detail Page (`order_detail_page.dart`)

**Design:**
- AppBar: `← Table TX`  |  `⋮` (more options)
- Badge: `● EN PRÉPARATION`
- `ListView` of items:
  - Not-ready: bold black text, empty checkbox right
  - Ready: muted/strikethrough text, orange checkbox right
  - Notes below item name (muted italic)
- `TERMINER` button at bottom

**Data:** Find order by id from `OrdersBloc.state.orders`.
If not available, you may need an extra `OrderFetched()` call.

**Checkbox tap:** This is from the KDS (kitchen display) side — the server view is
read-only here. Do NOT allow toggling from this screen. Just display state.

**TERMINER:** `OrdersBloc.add(OrderStatusUpdated(orderId, OrderStatus.served))`
then `context.pop()`.

### 8.7 Profile Page (`profile_page.dart`)

Simple screen showing user info + logout.

```
AppBar: ← Profil
Body:
  CircleAvatar (initials, large)
  Text: fullName or username
  Text: role name
  Text: email (if available)
  ──────────────────────────────
  ListTile(leading: Icon(logout), title: "Se déconnecter")
    → confirm dialog → AuthBloc.add(AuthLoggedOut()) → context.go('/login')
```

---

## 9. Bottom Sheet (`menu_item_options_sheet.dart`)

**Triggered by:** Long press on menu item card (in make_order or order_card).

**Structure:** `showModalBottomSheet` with custom content.

```
BottomSheet
  Handle bar
  Title: item.menuItem.translations.first.name  (bold)
  Subtitle: formatPriceFull(item.unitPrice) Ar
  ─────────────────────────────────────────────────
  ExpandableRow("Éditer prix", icon: edit)
    └─ if expanded: TextField(initialValue: unitPrice) + OK btn
  ExpandableRow("Ajouter note", icon: note)
    └─ if expanded: TextField("Ajouter une instruction...") + OK btn
  ExpandableRow("Offrir", icon: gift)
    └─ if expanded: Row([-] qty [+]) + OK btn
  ─────────────────────────────────────────────────
  Row(red bg): ✕ Annuler
```

**Expandable row behavior:**
- Each row has a trailing `>` arrow (collapsed) or `▼` (expanded)
- Tapping a row toggles its expanded state (only one at a time or all independent)

**On OK — Edit price:**
```dart
final newPrice = double.tryParse(priceController.text) ?? item.unitPrice;
context.read<OrderMenuItemBloc>().add(
  OrderMenuItemPriceUpdated(orderedIndex, newPrice),
);
Navigator.pop(context);
```

**On OK — Add note:**
```dart
context.read<OrderMenuItemBloc>().add(
  OrderMenuItemNoteUpdated(orderedIndex, noteController.text),
);
Navigator.pop(context);
```

**On OK — Offer:**
```dart
context.read<OrderMenuItemBloc>().add(
  OrderMenuItemOffered(item, offeredQty),
);
Navigator.pop(context);
```

**Annuler:** `Navigator.pop(context)` (remove item if it was just added? No — cancel just closes the sheet).

---

## 10. API Endpoints Used

All endpoints are the same as the tablet. They're accessed through the
shared `OrdersRepository`, `AuthRepository`, `TablesRepository` from the `data` package.

| Action | Repository method |
|---|---|
| Login | `AuthRepository.login(LoginParams)` |
| Get current user | `AuthRepository.getUser()` |
| Logout | `AuthRepository.logout()` |
| Get menu items for ordering | `OrdersRepository.getOrderMenuItems({search?})` |
| Create order | `OrdersRepository.createOrder(OrderModel)` |
| Get orders list | `OrdersRepository.getOrders(OrderParams)` |
| Update order | `OrdersRepository.updateOrder(id, OrderModel)` |
| Update order status | `OrdersRepository.updateStatusOrder(id, OrderStatus)` |
| Delete order | `OrdersRepository.deleteOrder(id)` |
| Get tables | `TablesRepository.getAll()` |

---

## 11. Build & Run

```bash
# Bootstrap after pubspec changes
melos bootstrap

# Run the mobile app locally
cd apps/menu_zen_mobile && flutter run -t lib/main_local.dart

# Analyze
flutter analyze apps/menu_zen_mobile

# Format
cd apps/menu_zen_mobile && dart format lib/
```

> **No `build_runner` needed** since the mobile app uses manual DI
> and `go_router` (no code generation required).

---

## 12. Step-by-Step Checklist

- [x] **Step 1 — Foundation** ✅
  - [x] Update `pubspec.yaml` (add all packages)
  - [x] Create `.env.local`
  - [x] Create `core/enums/bloc_status.dart`
  - [x] Create `core/constants/constants.dart`
  - [x] Create `core/http_connexion/interceptors.dart`
  - [x] Create `core/injection/dependencies_injection.dart`
  - [x] Create `core/navigation/app_router.dart`
  - [x] Create `config_main.dart`, `main.dart`, `main_local.dart`
  - [x] Create `app.dart`

- [x] **Step 2 — BLoC files** ✅
  - [x] `presentation/bloc/auth/` (3 files)
  - [x] `presentation/bloc/orders/` (3 files)
  - [x] `presentation/bloc/orders/order_menu_item/` (3 files, extended)
  - [x] `presentation/bloc/tables/` (3 files)

- [x] **Step 3 — Shared widgets** ✅
  - [x] `presentation/widgets/logo.dart`
  - [x] `presentation/widgets/menu_item_options_sheet.dart`

- [x] **Step 4 — Login page** ✅
  - [x] `presentation/pages/login_page.dart`

- [x] **Step 5 — Main shell + Make Order** ✅
  - [x] `presentation/pages/main_page.dart`
  - [x] `presentation/pages/make_order_page.dart`

- [x] **Step 6 — Order Card page** ✅
  - [x] `presentation/pages/order_card_page.dart`

- [x] **Step 7 — Orders page** ✅
  - [x] `presentation/pages/orders_page.dart`

- [x] **Step 8 — Order Detail + Profile** ✅
  - [x] `presentation/pages/order_detail_page.dart`
  - [x] `presentation/pages/profile_page.dart`

- [ ] **Step 9 — Test & polish**
  - [ ] `flutter analyze` clean
  - [ ] Run on Android emulator / iOS simulator
  - [ ] Verify all API calls work
  - [ ] Verify navigation flows
