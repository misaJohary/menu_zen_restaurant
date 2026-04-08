# CLAUDE.md — Flutter & Dart Rules for Claude Code

You are an expert in Flutter and Dart development. Your goal is to build
beautiful, performant, and maintainable applications following modern best
practices.

---

## General Behavior

- Assume the user is familiar with programming but may be new to Dart.
- Explain Dart-specific features when relevant: null safety, futures, streams.
- If a request is ambiguous, ask for clarification on the intended functionality
  and the target platform (mobile, web, desktop).
- When suggesting new packages from pub.dev, explain their benefits.
- Use `dart format` to ensure consistent code formatting.
- Use `dart fix` to automatically fix common errors.
- Run `flutter analyze` before proposing changes.

---

## Project Structure — Melos Monorepo

This project is a **Melos monorepo**. The workspace root is the directory
containing this file (`melos.yaml`, `pubspec.yaml`).

```
monorepo/
├── melos.yaml                    ← legacy (config now in pubspec.yaml)
├── pubspec.yaml                  ← root workspace + melos config (scripts)
├── apps/
│   ├── menu_zen_tablet/          ← tablet restaurant app
│   └── menu_zen_mobile/          ← mobile app
└── packages/
    ├── domain/                   ← entities, use cases, repository interfaces
    ├── data/                     ← models, datasources, repository implementations
    └── design_system/            ← theme, tokens, shared widgets
```

### Package Dependency Rules

```
domain        ←  nothing (no external dependencies)
data          ←  domain
design_system ←  nothing (or domain if entities are needed)
apps          ←  domain + data + design_system
```

### Each app's internal structure

```
lib/
├── core/
│   ├── error/                    # Failures, exceptions
│   ├── usecases/                 # UseCase base class (NoParams, etc.)
│   ├── utils/                    # Extensions, helpers, constants
│   └── di/                       # Dependency injection (get_it / injectable)
│
└── presentation/
    ├── bloc/                     # BLoC or Cubit + events + states
    ├── pages/                    # Screens (Page or Screen suffix)
    └── widgets/                  # Reusable widgets
```

### Strict Rules

- `domain` entities are pure Dart classes — no JSON, no Flutter.
- `data` implements `domain` interfaces only.
- `presentation` depends only on `domain` via BLoC/Cubit.
- Never import `data` directly in an app's `presentation/`.
- `get_it` is initialized in each app, never inside packages.
- BLoC/Cubit stays in `apps/*/lib/presentation/bloc/` — not shared.
- `build_runner` / `json_serializable` runs inside `packages/data/`.

---

## Useful Commands

```bash
# Bootstrap the workspace (run after any pubspec.yaml change)
melos bootstrap

# Analyze all packages
melos run analyze

# Format all packages
melos run format

# Run code generation in packages/data
cd packages/data && dart run build_runner build --delete-conflicting-outputs

# Run the tablet app
cd apps/menu_zen_tablet && flutter run

# Run the mobile app
cd apps/menu_zen_mobile && flutter run

# Analyze a single app
flutter analyze apps/menu_zen_tablet

# Add a package to a specific app (run from that app's directory)
flutter pub add <package_name>

# Add a package to a package (run from packages/<name>/)
flutter pub add <package_name>
```

---

## Dart Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart).
- Naming: `PascalCase` for classes, `camelCase` for members/variables/functions,
  `snake_case` for files.
- Line length: 80 characters maximum.
- Short functions with a single purpose (aim for less than 20 lines).
- Avoid abbreviations — use descriptive, consistent names.
- Write straightforward code. Clever or obscure code is hard to maintain.
- Always handle errors — never let code fail silently.

### Modern Dart

- **Null Safety:** write soundly null-safe code. Avoid `!` unless the value is
  guaranteed non-null.
- **Async/Await:** use `Future`/`async`/`await` for async operations with robust
  error handling.
- **Streams:** for sequences of asynchronous events.
- **Pattern matching:** use it when it simplifies the code.
- **Records:** to return multiple values without defining a full class.
- **Exhaustive switch:** prefer exhaustive `switch` expressions without `break`.
- **Arrow functions:** for simple one-line functions.
- **Exceptions:** use `try-catch` with custom exceptions suited to the context.

---

## Flutter Best Practices

- **Immutability:** widgets (`StatelessWidget`) are immutable.
- **Composition:** compose small widgets rather than extending existing ones.
- **Private widgets:** use small private `Widget` classes instead of helper
  methods returning a `Widget`.
- **`build()` methods:** break large `build()` methods into smaller reusable
  private widget classes.
- **`const` constructors:** use them as much as possible to reduce rebuilds.
- **Long lists:** use `ListView.builder` or `SliverList` for lazy-loaded lists.
- **Heavy computations:** use `compute()` to run in a separate isolate and avoid
  blocking the UI thread.
- **`build()` performance:** never perform expensive operations (network calls,
  complex computations) directly inside `build()`.

---

## State Management — BLoC / Cubit

This project uses `flutter_bloc`. Do not use any other state management solution
unless explicitly requested.

### When to Use Cubit vs BLoC

- **Cubit:** simple state, no event history needed, linear logic (e.g. toggle,
  counter, loading a list).
- **BLoC:** complex logic with multiple distinct events, conditional state
  transitions, or needing to react differently to the same action type depending
  on context.

### Cubit Pattern

```dart
// states: feature_state.dart
part of 'feature_cubit.dart';

@immutable
sealed class FeatureState {}
class FeatureInitial extends FeatureState {}
class FeatureLoading extends FeatureState {}
class FeatureLoaded extends FeatureState {
  const FeatureLoaded(this.data);
  final MyEntity data;
}
class FeatureError extends FeatureState {
  const FeatureError(this.message);
  final String message;
}

// feature_cubit.dart
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit(this._useCase) : super(FeatureInitial());

  final GetFeatureUseCase _useCase;

  Future<void> load() async {
    emit(FeatureLoading());
    final result = await _useCase(NoParams());
    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (data)    => emit(FeatureLoaded(data)),
    );
  }
}
```

### BLoC Pattern

```dart
// events: feature_event.dart
part of 'feature_bloc.dart';

@immutable
sealed class FeatureEvent {}
class FeatureStarted extends FeatureEvent {}
class FeatureRefreshed extends FeatureEvent {}

// states: feature_state.dart  (same structure as Cubit above)

// feature_bloc.dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc(this._useCase) : super(FeatureInitial()) {
    on<FeatureStarted>(_onStarted);
    on<FeatureRefreshed>(_onRefreshed);
  }

  final GetFeatureUseCase _useCase;

  Future<void> _onStarted(
    FeatureStarted event,
    Emitter<FeatureState> emit,
  ) async {
    emit(FeatureLoading());
    final result = await _useCase(NoParams());
    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (data)    => emit(FeatureLoaded(data)),
    );
  }

  Future<void> _onRefreshed(
    FeatureRefreshed event,
    Emitter<FeatureState> emit,
  ) async => _onStarted(FeatureStarted(), emit);
}
```

### BLoC Conventions

- One file per responsibility: `_bloc.dart`, `_event.dart`, `_state.dart`
  (or `_cubit.dart` + `_state.dart`).
- States use `sealed class` for exhaustive switches.
- Always `@immutable` on states and events.
- Name events in the past tense: `FeatureStarted`, `ItemDeleted`.
- Name states by what they represent: `FeatureLoaded`, `FeatureError`.
- Use `dartz` (`Either<Failure, T>`) for use case return values.
- Never call a repository directly from a BLoC/Cubit — always go through a use
  case.

### In Widgets

```dart
// Provide the BLoC via BlocProvider
BlocProvider(
  create: (context) => getIt<FeatureCubit>()..load(),
  child: const FeaturePage(),
);

// Consume the state
BlocBuilder<FeatureCubit, FeatureState>(
  builder: (context, state) => switch (state) {
    FeatureInitial()             => const SizedBox.shrink(),
    FeatureLoading()             => const CircularProgressIndicator(),
    FeatureLoaded(:final data)   => FeatureContent(data: data),
    FeatureError(:final message) => ErrorWidget(message: message),
  },
);

// Listen for side effects (navigation, snackbar)
BlocListener<FeatureCubit, FeatureState>(
  listener: (context, state) {
    if (state is FeatureError) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message)));
    }
  },
);
```

### Dependency Injection

- Use `get_it` + `injectable` for injection.
- Register BLoC/Cubit as `@injectable` (factory, not singleton).
- Register repositories and use cases as `@lazySingleton`.

---

## Navigation

- Use **`go_router`** for declarative navigation, deep linking, and web support.

```dart
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
);

MaterialApp.router(routerConfig: _router);
```

- Configure `go_router`'s `redirect` property to handle authentication flows.
- Use `Navigator` only for short-lived, non-deep-linkable screens (dialogs,
  temporary views).

---

## JSON Serialization

- Use **`json_serializable`** and **`json_annotation`**.
- Use `fieldRename: FieldRename.snake` to convert Dart camelCase to snake_case
  JSON keys.

```dart
import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String firstName;
  final String lastName;

  User({required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

---

## Logging

- Use `dart:developer` for structured logging integrated with DevTools.

```dart
import 'dart:developer' as developer;

developer.log('Simple message');

try {
  // ...
} catch (e, s) {
  developer.log(
    'Network error',
    name: 'myapp.network',
    level: 1000, // SEVERE
    error: e,
    stackTrace: s,
  );
}
```

---

## Code Generation

- `build_runner` must be listed as a dev dependency in `pubspec.yaml`.
- After modifying files that require code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Tests

⚠️ **NEVER generate or run test files automatically.**
Tests are written only when explicitly requested by the user.
Do not run `flutter test` or create any `*_test.dart` file on your own initiative.

When tests are explicitly requested:
- **Unit tests:** `package:test` — use cases, repositories, entities.
- **BLoC/Cubit tests:** `package:bloc_test` — use `blocTest()`.
- **Widget tests:** `package:flutter_test` — UI components.
- **Mocks:** use `mocktail` (preferred over mockito, no code generation needed).
- **Pattern:** Arrange-Act-Assert.

```dart
// Example Cubit test with bloc_test
blocTest<FeatureCubit, FeatureState>(
  'emits [Loading, Loaded] when load() succeeds',
  build: () {
    when(() => mockUseCase(any())).thenAnswer((_) async => Right(fakeData));
    return FeatureCubit(mockUseCase);
  },
  act: (cubit) => cubit.load(),
  expect: () => [isA<FeatureLoading>(), isA<FeatureLoaded>()],
);
```

---

## Theme & Design

### ThemeData

- Use `ColorScheme.fromSeed()` to generate a harmonious color palette.
- Define both a light theme (`theme`) and a dark theme (`darkTheme`).
- Centralize component styles inside `ThemeData`.

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
  ),
  home: const MyHomePage(),
);
```

### 60-30-10 Color Rule

- **60%** primary / neutral color
- **30%** secondary color
- **10%** accent color

### Typography

- Maximum 2 font families.
- Line height: 1.4x–1.6x the font size.
- Body line length: 45–75 characters.
- Use `google_fonts` for custom fonts.

### Layout

- `Expanded` / `Flexible` for flexible Row/Column children.
- `Wrap` to avoid overflow.
- `ListView.builder` / `GridView.builder` for long lists.
- `LayoutBuilder` / `MediaQuery` for responsive UIs.

### Images

- Local images: `Image.asset`
- Network images: `Image.network` with `loadingBuilder` and `errorBuilder`
- Cached network images: `cached_network_image`

```dart
Image.network(
  'https://example.com/image.png',
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return const Center(child: CircularProgressIndicator());
  },
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error);
  },
);
```

---

## Accessibility (A11Y)

- Text contrast: minimum ratio of **4.5:1** (normal text), **3:1** (large text).
- Test the UI with dynamic system font scaling enabled.
- Use the `Semantics` widget to provide descriptive labels for UI elements.
- Regularly test with TalkBack (Android) and VoiceOver (iOS).

---

## Analysis (analysis_options.yaml)

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
```

---

## Documentation

- Use `///` for doc comments (dartdoc style).
- Start with a concise one-sentence summary ending with a period.
- Prioritize documenting all public APIs.
- Explain the **why**, not the **what** — the code should be self-explanatory.
- Include code examples where appropriate.
