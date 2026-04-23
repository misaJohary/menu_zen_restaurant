# Multilingual Implementation Guide

## Overview
This document describes the multilingual implementation added to the Menu Zen Restaurant application. The implementation allows users to manage content in multiple languages and select their preferred language when making orders.

## New Components Added

### 1. Backend Integration

#### REST Client (`lib/core/http_connexion/rest_client.dart`)
- Added `GET /languages` endpoint to fetch available languages
- Returns: `List<LanguageModel>`

### 2. Domain Layer

#### Language Repository Interface (`lib/features/domains/repositories/languages_repository.dart`)
- Defines the contract for language-related operations
- Method: `getLanguages()` - Returns list of available languages

### 3. Data Layer

#### Language Repository Implementation (`lib/features/datasources/repositories/languages_repository_impl.dart`)
- Implements `LanguagesRepository` interface
- Fetches languages from the REST API
- Uses dependency injection with `@LazySingleton` annotation

### 4. Presentation Layer

#### Languages BLoC (`lib/features/presentations/managers/languages/`)
- **languages_bloc.dart**: Main BLoC for managing language state
- **languages_event.dart**: Events:
  - `LanguagesFetched`: Fetch all available languages
  - `LanguageSelected`: Select a specific language
- **languages_state.dart**: State containing:
  - `languages`: List of available languages
  - `selectedLanguage`: Currently selected language
  - `status`: Loading status

#### Updated Widgets

##### AddItemWidget (`lib/features/presentations/widgets/add_item_widget.dart`)
Now supports multilingual fields through:
- **New Parameter**: `multilingualFields` - List of fields that need translation
- **Language Selection**: Displays chips for each available language
- **Dynamic Fields**: Shows name/description fields for the selected language
- **Translation Storage**: Maintains translations in a map structure `{languageCode: {fieldName: value}}`

**Usage Example:**
```dart
AddItemWidget(
  title: 'Add Menu Item',
  formKey: formKey,
  multilingualFields: [
    MultilingualField(
      name: 'name',
      label: 'Item Name',
      maxLines: 1,
    ),
    MultilingualField(
      name: 'description',
      label: 'Description',
      maxLines: 3,
    ),
  ],
  formBuilderFields: [
    // Other non-multilingual fields
    FormBuilderTextField(
      name: 'price',
      decoration: InputDecoration(labelText: 'Price'),
    ),
  ],
  confirmationButton: ElevatedButton(
    onPressed: () => controller.validate(),
    child: Text('Save'),
  ),
)
```

##### OrderHeader (`lib/features/presentations/widgets/make_orders/order_header.dart`)
- **Added**: Horizontal scrollable list of language chips
- **Feature**: Users can select their preferred language for viewing menu items
- **Integration**: Connected to `LanguagesBloc` for state management

##### MakeOrderScreen (`lib/features/presentations/screens/make_orders_screen.dart`)
- No changes needed - the OrderHeader component handles language selection

### 5. Dependency Injection

The `LanguagesBloc` is registered in `lib/app.dart`:
```dart
BlocProvider(create: (context) => getIt<LanguagesBloc>()),
```

## Data Flow

1. **Initialization**:
   - Widget initializes and triggers `LanguagesFetched` event
   - BLoC calls repository to fetch languages from API
   - State updates with available languages
   - First language is automatically selected

2. **Language Selection**:
   - User taps on a language chip
   - `LanguageSelected` event is triggered
   - BLoC updates `selectedLanguage` in state
   - UI rebuilds to show fields for the selected language

3. **Multilingual Input** (AddItemWidget):
   - User selects a language
   - Fills in name/description for that language
   - Switches to another language
   - Fills in name/description for that language
   - Translations are stored in the widget state: `Map<String, Map<String, String>>`
   - Example: `{'en': {'name': 'Pizza', 'description': 'Delicious pizza'}, 'fr': {'name': 'Pizza', 'description': 'Pizza délicieuse'}}`

4. **Order Language Selection** (MakeOrderScreen):
   - User sees a scrollable list of languages in the header
   - Selects preferred language
   - Menu items should display in the selected language (requires backend integration)

## Next Steps

### Required: Code Generation
Due to Dart VM issues during this implementation, you'll need to run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `rest_client.g.dart` - REST client implementation with the new `/languages` endpoint
- `dependencies_injection.config.dart` - Dependency injection configuration for new repositories and BLoCs
- `language_model.g.dart` - JSON serialization for LanguageModel (should already exist)

### Integration Tasks

1. **Update Forms to Use Multilingual Fields**:
   - Menu Item creation/editing forms
   - Category creation/editing forms
   - Any other forms with name/description fields

2. **Backend Integration**:
   - Ensure the `GET /languages` endpoint returns the correct format:
     ```json
     [
       {"name": "English", "code": "en"},
       {"name": "Français", "code": "fr"}
     ]
     ```

3. **Display Logic**:
   - Update menu item display widgets to show content in the selected language
   - Add fallback logic when translation is not available

4. **Persistence**:
   - Update form validation to collect all translations
   - Send translations to the backend in the correct format
   - Update entity models to include translations

## File Structure

```
lib/
├── core/
│   └── http_connexion/
│       └── rest_client.dart (updated)
├── features/
│   ├── datasources/
│   │   ├── models/
│   │   │   └── language_model.dart (existing)
│   │   └── repositories/
│   │       └── languages_repository_impl.dart (new)
│   ├── domains/
│   │   ├── entities/
│   │   │   └── language_entity.dart (existing)
│   │   └── repositories/
│   │       └── languages_repository.dart (new)
│   └── presentations/
│       ├── managers/
│       │   └── languages/ (new)
│       │       ├── languages_bloc.dart
│       │       ├── languages_event.dart
│       │       └── languages_state.dart
│       ├── screens/
│       │   └── make_orders_screen.dart (no changes)
│       └── widgets/
│           ├── add_item_widget.dart (updated)
│           ├── multilingual_field.dart (new)
│           └── make_orders/
│               └── order_header.dart (updated)
└── app.dart (updated)
```

## Testing Checklist

- [ ] Run code generation successfully
- [ ] Verify `/languages` API endpoint is accessible
- [ ] Test language selection in make orders screen
- [ ] Test multilingual field input in forms
- [ ] Verify translations are stored correctly
- [ ] Test language switching maintains entered data
- [ ] Verify form submission includes all translations
- [ ] Test with no languages available from API
- [ ] Test with single language
- [ ] Test with multiple languages (3+)

## Known Issues

- Dart VM crash during code generation on macOS (workaround: upgrade Dart SDK or use different machine)
- AddItemWidget needs manual collection of translation data before form submission

## Future Enhancements

- Add language management (CRUD operations for languages)
- Add default language setting in user preferences
- Add translation completion indicators
- Add bulk translation features
- Add translation import/export functionality





