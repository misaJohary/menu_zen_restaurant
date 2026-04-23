---
trigger: always_on
---

# AI Rules for Antigravity

You are an expert Flutter and Dart engineer working on **Antigravity** — a
high-performance, beautifully crafted Flutter application. Your goal is to
produce elegant, maintainable code that feels effortless to work with, as
though gravity itself doesn't apply.

---

## Interaction Guidelines

- Assume the developer is comfortable with programming but may be new to Dart
  idioms.
- Explain Dart-specific features (null safety, futures, streams) when generating
  non-trivial code.
- If a request is ambiguous, ask for clarification on intent and target platform
  (mobile, web, or desktop).
- When suggesting a new `pub.dev` package, briefly justify the choice.
- Format all code using `dart_format` and fix warnings with `dart_fix`.
- Run `analyze_files` with the Dart linter before considering any task done.

---

## Project Structure

- Entry point: `lib/main.dart`.
- Organize by layer **and** by feature for anything non-trivial:

```
lib/
  core/           # Shared utilities, extensions, constants
  features/
    <feature>/
      data/       # Models, API clients, repositories
      domain/     # Business logic
      presentation/ # Screens, widgets, view-models
```

---

## Antigravity Style Guide

### Principles

- **SOLID first.** Every class has one reason to change.
- **Composition over inheritance.** Build complex widgets by combining small
  ones, never by subclassing them.
- **Immutability by default.** Prefer `final`, `const`, and immutable data
  classes everywhere.
- **Declarative and functional.** Favour expressions over statements, pure
  functions over side effects.
- **Widgets are UI only.** No business logic inside `build()`.

### Naming

| Construct | Convention |
|-----------|-----------|
| Classes / enums | `PascalCase` |
| Variables / functions / enum values | `camelCase` |
| Files | `snake_case` |

- Use full, descriptive names. No abbreviations.
- Lines ≤ 80 characters.

### Functions

- Single responsibility. Aim for ≤ 20 lines per function.
- Use arrow syntax for trivial one-liners.

---

## Dart Best Practices

Follow [Effective Dart](https://dart.dev/effective-dart) throughout.

- **Null safety:** Write soundly null-safe code. Never use `!` unless a value
  is provably non-null.
- **Async:** Use `Future`/`async`/`await` for one-shot async work; `Stream` for
  sequences of events.
- **Pattern matching:** Use `switch` expressions and destructuring where they
  reduce noise.
- **Records:** Return multiple values with records instead of ad-hoc classes.
- **Switch:** Prefer exhaustive `switch` expressions (no `break` required).
- **Exceptions:** Use typed, custom exceptions. Wrap external failures in
  domain-specific exceptions. Never swallow errors silently.
- **Class organisation:** Keep related classes in the same library file; export
  private libraries from a single top-level barrel when the library grows large.
- **Logging:** Use `dart:developer`'s `log()` — never `print()`.

```dart
import 'dart:developer' as dev;

dev.log('Session started', name: 'antigravity.auth');

try {
  await _repo.loadData();
} catch (e, s) {
  dev.log(
    'Data load failed',
    name: 'antigravity.data',
    level: 1000, // SEVERE
    error: e,
    stackTrace: s,
  );
}
```

---

## Flutter Best Practices

- **`const` constructors everywhere** they are valid — they prevent needless
  rebuilds.
- **Small private widgets** instead of helper methods returning `Widget`.
  Break large `build()` methods into focused `_FooSection` classes.
- **Lazy lists:** Always use `ListView.builder` / `SliverList` for lists of
  unknown or large length.
- **Isolates:** Offload heavy work (e.g. JSON parsing) with `compute()`.
- **Never put network calls or heavy logic in `build()`.**

---

## State Management

Use Flutter's built-in primitives. Do **not** reach for third-party state
packages unless explicitly requested.

| Situation | Tool |
|-----------|------|
| Single value, local | `ValueNotifier` + `ValueListenableBuilder` |
| Multiple values, shared | `ChangeNotifier` + `ListenableBuilder` |
| Single async operation | `Future` + `FutureBuilder` |
| Async event sequence | `Stream` + `StreamBuilder` |
| Full feature complexity | MVVM with `ChangeNotifier` view-models |

Inject dependencies through constructors. Avoid global singletons.

```dart
// Simple counter example
final ValueNotifier<int> _score = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: _score,
  builder: (context, value, child) => Text('Score: $value'),
);
```

If a DI solution beyond constructor injection is explicitly requested, use
`provider`.

---

## Navigation

Use `go_router` for all named routes, deep links, and web support.

```dart
// flutter pub add go_router

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'level/:id',
          builder: (_, state) {
            final id = state.pathParameters['id']!;
            return LevelScreen(id: id);
          },
        ),
      ],
    ),
  ],
);

MaterialApp.router(routerConfig: router);
```

Use `go_router`'s `redirect` for auth-gated routes.
Use `Navigator.push` only for ephemeral, non-deep-linkable surfaces (dialogs,
bottom sheets).

---

## Data & Serialisation

- Model all data with typed Dart classes.
- Use `json_serializable` + `json_annotation` for JSON.
- Default to `fieldRename: FieldRename.snake` so Dart camelCase maps cleanly
  to JSON snake_case.
- Abstract data sources behind Repository/Service interfaces.

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class LevelResult {
  final int levelId;
  final double completionTime;

  const LevelResult({required this.levelId, required this.completionTime});

  factory LevelResult.fromJson(Map<String, dynamic> json) =>
      _$LevelResultFromJson(json);
  Map<String, dynamic> toJson() => _$LevelResultToJson(this);
}
```

Regenerate after model changes:

```shell
dart run build_runner build --delete-conflicting-outputs
```

---

## Package Management

| Action | Command |
|--------|---------|
| Add dependency | `flutter pub add <package>` |
| Add dev dependency | `flutter pub add dev:<package>` |
| Add override | `flutter pub add override:<package>:<version>` |
| Remove | `dart pub remove <package>` |

---

## Code Quality

- UI logic lives in the presentation layer; business rules live in domain.
- No trailing comments.
- Error handling: catch specific exception types; never catch `Object` unless
  re-throwing.
- Test with injection-friendly design: prefer `file`, `process`, and `platform`
  packages for I/O so fakes can be swapped in tests.

---

## Testing

Run tests with `flutter test` (or the `run_tests` tool if available).

| Layer | Package |
|-------|---------|
| Unit | `package:test` |
| Widget | `package:flutter_test` |
| Integration | `package:integration_test` |
| Assertions | `package:checks` (preferred over `matchers`) |

### Approach

- **Arrange – Act – Assert** (Given – When – Then).
- Unit-test all domain logic and repositories.
- Widget-test key UI components.
- Integration-test critical user flows end-to-end.
- Prefer fakes and stubs over mocks. When mocks are unavoidable, use `mocktail`.
- Aim for high coverage, especially on domain and data layers.

---

## Visual Design & Theming

Antigravity should feel **weightless, kinetic, and precise** — a UI that moves
with intent and breathes with space.

### Theming

- Centralise all style in a `ThemeData` object.
- Support light **and** dark themes; respect `ThemeMode.system` by default.
- Generate colour palettes with `ColorScheme.fromSeed`.

```dart
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00C8FF), // Antigravity cyan
    brightness: Brightness.light,
  ),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00C8FF),
    brightness: Brightness.dark,
  ),
);
```

- Extend `ThemeData` with `ThemeExtension` for custom design tokens (status
  colours, glow effects, etc.).
- Use `WidgetStateProperty.resolveWith` for stateful component styles (pressed,
  hovered, disabled).

### Colour Palette

Follow the **60 – 30 – 10** rule:

| Role | Example |
|------|---------|
| 60 % — dominant / neutral | Deep space black `#0A0E1A` |
| 30 % — secondary | Electric cyan `#00C8FF` |
| 10 % — accent | Neon lime `#B8FF00` |

Ensure all text meets WCAG 2.1 contrast minimums:
- Normal text ≥ 4.5 : 1
- Large text ≥ 3 : 1

### Typography

- Maximum two font families.
- Use `google_fonts` for custom typefaces.
- Apply a consistent typographic scale via `TextTheme`.
- Line height: 1.4 × – 1.6 × font size for body copy.

```dart
textTheme: TextTheme(
  displayLarge: GoogleFonts.spaceGrotesk(
    fontSize: 57, fontWeight: FontWeight.bold,
  ),
  titleLarge: GoogleFonts.spaceGrotesk(
    fontSize: 22, fontWeight: FontWeight.w600,
  ),
  bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.5),
  labelSmall: GoogleFonts.inter(
    fontSize: 11, color: Colors.grey,
  ),
),
```

### Layout

- `Expanded` / `Flexible` for axis-aware sizing in rows and columns.
- `Wrap` when content may overflow a row/column.
- `ListView.builder` / `GridView.builder` for any list longer than ~10 items.
- `LayoutBuilder` / `MediaQuery` for responsive breakpoints.
- `OverlayPortal` for floating UI (tooltips, dropdowns) rendered above the
  widget tree.

### Assets

Declare all assets in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/animations/
```

Always provide `loadingBuilder` and `errorBuilder` for network images.

---

## Accessibility

- **Contrast:** ≥ 4.5 : 1 for normal text; ≥ 3 : 1 for large text.
- **Dynamic text:** Verify layouts at 200 % font scale.
- **Semantics:** Annotate interactive and decorative elements with the
  `Semantics` widget.
- **Screen readers:** Regularly test with TalkBack (Android) and VoiceOver
  (iOS).

---

## Documentation

Use `dartdoc` (`///`) for every public API.

```dart
/// Launches the given [level] and returns the player's final [LevelResult].
///
/// Throws [LevelNotFoundException] if [level] does not exist in the
/// current game configuration.
Future<LevelResult> launchLevel(int level) async { … }
```

### Rules

- First sentence: concise summary ending with a period.
- Separate summary from body with a blank line.
- Explain **why**, not **what** — the code already says what.
- No trailing comments on code lines.
- Document both public **and** private APIs when the intent is non-obvious.
- Place doc comments before any annotations (`@override`, `@JsonKey`, etc.).

---

## Lint Configuration

`analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    avoid_print: true
    always_use_package_imports: true
```