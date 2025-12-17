# Multilingual Data Collection - Solution

## The Problem

When using `AddItemWidget` with multilingual fields, the translations were being stored internally but **NOT accessible through FormBuilder's `currentState.fields`**.

### Why This Happens

FormBuilder only tracks fields that are **currently in the widget tree**. When you switch languages:

1. **Fill French**: `name_fr`, `description_fr` exist in widget tree
2. **Switch to English**: French fields **removed**, `name_en`, `description_en` created  
3. **Switch to Chinese**: English fields **removed**, Chinese fields created
4. **Validate**: Only Chinese fields exist in `formKey.currentState.fields`

### Example of the Issue

```dart
// What you saw in currentState.fields:
{
  "emoji": "_FormBuilderTextFieldState#0aeb4",
  "name_en": "_FormBuilderTextFieldState#61199",    // Only current language!
  "description_en": "_FormBuilderTextFieldState#d4a6d"
  // name_fr, name_ch, description_fr, description_ch are MISSING!
}
```

## The Solution

The translations ARE being stored in `AddItemWidget`'s internal `_translations` map. We just need to access them separately from the FormBuilder fields.

### Step 1: Understanding the Data Flow

```
User Input → AddItemWidget._translations map (ALL languages stored)
           ↓
User Input → FormBuilder fields (ONLY current language)
```

**For multilingual fields**: Get data from `_translations` map  
**For regular fields**: Get data from FormBuilder

### Step 2: How to Access Translations

The updated `AddItemWidget` now provides:

```dart
// Static helper method
AddItemWidget.getTranslations(yourGlobalKey)

// Returns:
{
  'fr': {
    'name': 'Menu du Soir',
    'description': 'Notre menu spécial'
  },
  'en': {
    'name': 'Evening Menu',
    'description': 'Our special evening menu'
  },
  'es': {
    'name': 'Menú de la Noche',
    'description': 'Nuestro menú especial'
  }
}
```

### Step 3: Implementation (Already Done)

Both `AddMenuWidget` and `AddCategoryWidget` now have:

1. **GlobalKey** to access AddItemWidget state
2. **translations getter** to retrieve all translations
3. **_handleValidation()** method that collects translations

```dart
class _AddMenuWidgetState extends State<AddMenuWidget> {
  final GlobalKey<State<AddItemWidget>> _addItemWidgetKey = GlobalKey();

  Map<String, Map<String, String>>? get translations {
    return AddItemWidget.getTranslations(_addItemWidgetKey);
  }

  void _handleValidation() {
    final translationsData = translations;
    print('Translations collected: $translationsData');
    
    // TODO: Pass translations to controller
    widget.controller.validate();
  }

  @override
  Widget build(BuildContext context) {
    return AddItemWidget(
      key: _addItemWidgetKey,  // ← Important!
      // ... rest of widget
    );
  }
}
```

## Testing the Fix

### Test with Categories

1. Open Categories screen
2. Click "Ajouter une Categorie"
3. Select **French** language
4. Enter:
   - Name: "Plats Principaux"
   - Description: "Nos délicieux plats"
5. Select **English** language
6. Enter:
   - Name: "Main Courses"
   - Description: "Our delicious dishes"
7. Select **Spanish** language
8. Enter:
   - Name: "Platos Principales"
   - Description: "Nuestros deliciosos platos"
9. Fill emoji: "🍽️"
10. Pick a color
11. Click "Ajouter une Categorie"
12. **Check the console/debug output**

You should see:
```dart
Translations collected: {
  fr: {name: Plats Principaux, description: Nos délicieux plats},
  en: {name: Main Courses, description: Our delicious dishes},
  es: {name: Platos Principales, description: Nuestros deliciosos platos}
}
```

## Next Steps: Updating Controllers

The translations are now accessible, but you need to update your controllers to properly handle them.

### Option 1: Extend BaseController (Recommended)

Create a method in `BaseController` to accept translations:

```dart
abstract class BaseController<TBloc extends BlocBase, TModel, TEntity>
    extends ChangeNotifier {
  
  // Existing code...

  // Add this method
  void validateWithTranslations(Map<String, Map<String, String>>? translations) {
    try {
      if (currentState?.saveAndValidate() ?? false) {
        // Get regular form fields
        final formData = currentState!.fields.map(
          (key, value) => MapEntry(key, value.value)
        );
        
        // Merge with translations
        if (translations != null && translations.isNotEmpty) {
          formData['translations'] = translations;
        }
        
        TModel model = createModelFromJson(formData);

        if (_isEditMode && _currentModel != null) {
          final updatedModel = copyModelWithId(model, getModelId(_currentModel!));
          return updateItem(updatedModel as TEntity);
        }

        addItem(model);
      }
    } catch (e) {
      Logger().e(e);
    }
  }
}
```

### Option 2: Custom Validation per Controller

Update each controller individually:

**For `CategoriesController`:**

```dart
class CategoriesController extends BaseController<...> {
  
  // Add this method
  void validateWithTranslations(Map<String, Map<String, String>>? translations) {
    try {
      if (currentState?.saveAndValidate() ?? false) {
        final formValues = currentState!.fields.map(
          (key, value) => MapEntry(key, value.value)
        );
        
        // Create model with translations
        CategoryModel model = CategoryModel(
          emoji: formValues['emoji'],
          themeColor: themeColor, // from controller
          translations: translations != null 
            ? _buildTranslationsList(translations)
            : [],
        );

        if (isEditMode && currentModel != null) {
          model = model.copyWith(id: currentModel!.id);
          return updateItem(model);
        }

        addItem(model);
      }
    } catch (e) {
      Logger().e(e);
    }
  }
  
  List<CategoryTranslation> _buildTranslationsList(
    Map<String, Map<String, String>> translations
  ) {
    return translations.entries.map((entry) {
      return CategoryTranslation(
        languageCode: entry.key,
        name: entry.value['name'] ?? '',
        description: entry.value['description'],
      );
    }).toList();
  }
}
```

**For `MenusController`:**

```dart
class MenusController extends BaseController<...> {
  
  void validateWithTranslations(Map<String, Map<String, String>>? translations) {
    try {
      if (currentState?.saveAndValidate() ?? false) {
        final formValues = currentState!.fields.map(
          (key, value) => MapEntry(key, value.value)
        );
        
        MenuModel model = MenuModel(
          isActive: formValues['is_active'] ?? true,
          translations: translations != null 
            ? _buildTranslationsList(translations)
            : [],
        );

        if (isEditMode && currentModel != null) {
          model = model.copyWith(id: currentModel!.id);
          return updateItem(model);
        }

        addItem(model);
      }
    } catch (e) {
      Logger().e(e);
    }
  }
  
  List<MenuTranslation> _buildTranslationsList(
    Map<String, Map<String, String>> translations
  ) {
    return translations.entries.map((entry) {
      return MenuTranslation(
        languageCode: entry.key,
        name: entry.value['name'] ?? '',
        description: entry.value['description'],
      );
    }).toList();
  }
}
```

### Option 3: Update Widget State to Call Controller

Update the `_handleValidation()` method in widget states to pass translations:

**In `_AddMenuWidgetState` and `_AddCategoryWidgetState`:**

```dart
void _handleValidation() {
  final translationsData = translations;
  
  // If controller has validateWithTranslations method
  if (widget.controller is MenusController) {
    (widget.controller as MenusController).validateWithTranslations(translationsData);
  } else {
    // Fallback to regular validate
    widget.controller.validate();
  }
}
```

## Data Models Update

Ensure your models support the translation format:

### CategoryModel

```dart
@JsonSerializable()
class CategoryModel {
  final int? id;
  final String? emoji;
  final Color? themeColor;
  final List<CategoryTranslationModel> translations;

  CategoryModel({
    this.id,
    this.emoji,
    this.themeColor,
    required this.translations,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Handle both flat translations map and structured translations list
    if (json['translations'] is Map) {
      final translationsMap = json['translations'] as Map<String, Map<String, String>>;
      json['translations'] = translationsMap.entries.map((e) => {
        'language_code': e.key,
        'name': e.value['name'],
        'description': e.value['description'],
      }).toList();
    }
    return _$CategoryModelFromJson(json);
  }
  
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
```

### MenuModel

```dart
@JsonSerializable()
class MenuModel {
  final int? id;
  final bool isActive;
  final List<MenuTranslationModel> translations;

  MenuModel({
    this.id,
    required this.isActive,
    required this.translations,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    if (json['translations'] is Map) {
      final translationsMap = json['translations'] as Map<String, Map<String, String>>;
      json['translations'] = translationsMap.entries.map((e) => {
        'language_code': e.key,
        'name': e.value['name'],
        'description': e.value['description'],
      }).toList();
    }
    return _$MenuModelFromJson(json);
  }
  
  Map<String, dynamic> toJson() => _$MenuModelToJson(this);
}
```

## Complete Example Flow

### Creating a Category with Translations

1. **User fills form** in multiple languages
2. **User clicks save**
3. **_handleValidation() called**:
   ```dart
   Translations collected: {
     fr: {name: Plats Principaux, description: ...},
     en: {name: Main Courses, description: ...}
   }
   ```
4. **Controller receives translations**:
   ```dart
   controller.validateWithTranslations(translationsData)
   ```
5. **Controller builds model**:
   ```dart
   CategoryModel(
     emoji: "🍽️",
     themeColor: Color(0xFFFF5733),
     translations: [
       CategoryTranslation(languageCode: 'fr', name: 'Plats Principaux', ...),
       CategoryTranslation(languageCode: 'en', name: 'Main Courses', ...),
     ]
   )
   ```
6. **Model sent to API**:
   ```json
   {
     "emoji": "🍽️",
     "theme_color": "#FF5733",
     "translations": [
       {"language_code": "fr", "name": "Plats Principaux", "description": "..."},
       {"language_code": "en", "name": "Main Courses", "description": "..."}
     ]
   }
   ```

## Summary of Changes Made

✅ **AddItemWidget**: Made state class public, added static helper method  
✅ **AddMenuWidget**: Added GlobalKey, translations getter, _handleValidation()  
✅ **AddCategoryWidget**: Added GlobalKey, translations getter, _handleValidation()  

## What You Need to Do

1. ✅ Test the current implementation (translations should print in console)
2. ⬜ Choose a controller update approach (Option 1, 2, or 3)
3. ⬜ Implement translation handling in controllers
4. ⬜ Update models to support translation format
5. ⬜ Test end-to-end: form → controller → API → database

## Debugging Tips

### Print translations at each step:

```dart
// In widget state
void _handleValidation() {
  final trans = translations;
  print('1. Widget collected: $trans');
  widget.controller.validateWithTranslations(trans);
}

// In controller
void validateWithTranslations(Map<String, Map<String, String>>? translations) {
  print('2. Controller received: $translations');
  // ... build model
  print('3. Model created: ${model.toJson()}');
  addItem(model);
}

// In BLoC
_onCategoryCreated(...) {
  print('4. BLoC creating with model: ${event.category}');
  final res = await repository.addCategory(model);
  print('5. API response: $res');
}
```

---

**Status**: ✅ Data collection fixed - translations are now accessible  
**Next**: Update controllers to use the translations

**Date**: October 30, 2025




