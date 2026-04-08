import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:data/extensions/color_extension.dart';

import 'package:data/models/category_model.dart';
import 'package:domain/entities/category_entity.dart';
import '../managers/categories/categories_bloc.dart';
import 'base_controller.dart';

class CategoriesController
    extends BaseController<CategoriesBloc, CategoryModel, CategoryEntity> {
  CategoriesController({required super.context});

  Color? _themeColor;
  Color? get themeColor => _themeColor;

  set setThemeColor(Color? color) {
    _themeColor = color;
    notifyListeners();
  }

  get resetThemeColor {
    _themeColor = null;
    notifyListeners();
  }

  @override
  CategoriesBloc get bloc => context.read<CategoriesBloc>();

  @override
  CategoryModel createModelFromJson(Map<String, dynamic> json) {
    return CategoryModel.fromJson(json);
  }

  @override
  CategoryModel createModelFromEntity(CategoryEntity entity) {
    return CategoryModel.fromEntity(entity);
  }

  @override
  Map<String, dynamic> modelToJson(CategoryModel model) {
    return model.toJson();
  }

  @override
  CategoryModel copyModelWithId(CategoryModel model, dynamic id) {
    return model.copyWith(id: id);
  }

  @override
  dynamic getModelId(CategoryModel model) {
    return model.id;
  }

  @override
  void validate() {
    try {
      final currentState = formKey.currentState;
      if (currentState?.saveAndValidate() ?? false) {
        Logger().e(currentState!.fields);
        final emoji = currentState.fields['emoji']?.value;
        if (emoji != null) {
          currentState.patchValue({
            'name': '$emoji ${currentState.fields['name']?.value ?? ''}',
          });
        }
        final modelJson = currentState.fields.map(
          (key, value) => MapEntry(key, value.value),
        );
        if (_themeColor != null) {
          modelJson['color'] = _themeColor!.toHex;
        }
        final model = createModelFromJson(modelJson);

        if (isEditMode && currentModel != null) {
          final updatedModel = copyModelWithId(
            model,
            getModelId(currentModel!),
          );
          return updateItem(updatedModel);
        }

        addItem(model);
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  @override
  void addFetchEvent() {
    bloc.add(CategoriesFetched());
  }

  @override
  void addCreateEvent(CategoryModel model) {
    bloc.add(CategoriesCreated(model));
  }

  @override
  void addUpdateEvent(CategoryEntity entity) {
    bloc.add(CategoriesUpdated(entity));
  }

  @override
  void addDeleteEvent(dynamic id) {
    bloc.add(CategoriesDeleted(id));
  }

  /// Validate form with multilingual translations
  void validateWithTranslations(
    Map<String, Map<String, String>>? translations,
  ) {
    final currentState = formKey.currentState;
    if (currentState?.saveAndValidate() ?? false) {
      Logger().d('Form fields: ${currentState!.fields}');
      Logger().d('Translations: $translations');

      final rawEmoji = currentState.fields['emoji']?.value as String?;

      Map<String, Map<String, String>>? translationsToPersist = translations;
      if (rawEmoji != null &&
          rawEmoji.trim().isNotEmpty &&
          translations != null &&
          translations.isNotEmpty) {
        final emoji = rawEmoji.trim();
        translationsToPersist = translations.map((languageCode, fieldMap) {
          final name = fieldMap['name'] ?? '';
          final alreadyPrefixed = name.trim().startsWith(
            '$emoji ',
          ); // avoid double prefix
          final updatedName = alreadyPrefixed || name.startsWith(emoji)
              ? name
              : '$emoji ${name.trim()}'.trim();

          return MapEntry(languageCode, {...fieldMap, 'name': updatedName});
        });
      }

      // Build model JSON from form fields (non-multilingual fields only)
      final modelJson = Map<String, dynamic>.fromEntries(
        currentState.fields.entries
            .where(
              (entry) =>
                  !entry.key.startsWith('name_') &&
                  !entry.key.startsWith('description_'),
            )
            .map((entry) => MapEntry(entry.key, entry.value.value)),
      );

      // Add color if set
      if (_themeColor != null) {
        modelJson['color'] = _themeColor!.toHex;
      }

      // Transform translations map to list format expected by model
      if (translationsToPersist != null && translationsToPersist.isNotEmpty) {
        modelJson['translations'] = translationsToPersist.entries.map((entry) {
          return {
            'language_code': entry.key,
            'name': entry.value['name'] ?? '',
            'description': entry.value['description'],
          };
        }).toList();
      }

      Logger().d('Model JSON before creation: $modelJson');

      final model = createModelFromJson(modelJson);

      if (isEditMode && currentModel != null) {
        final updatedModel = copyModelWithId(model, getModelId(currentModel!));
        return updateItem(updatedModel);
      }

      addItem(model);
    }
  }
}
