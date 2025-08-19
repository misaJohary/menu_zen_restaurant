import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/core/extensions/color_extension.dart';

import '../../datasources/models/category_model.dart';
import '../../domains/entities/category_entity.dart';
import '../managers/categories/categories_bloc.dart';
import 'base_controller.dart';

class CategoriesController extends BaseController<CategoriesBloc, CategoryModel, CategoryEntity> {
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
        if(emoji != null) {
          currentState.patchValue({
            'name': '$emoji ${currentState.fields['name']?.value ?? ''}',
          });
        }
        final modelJson = currentState.fields.map((key, value) => MapEntry(key, value.value));
        if(_themeColor != null){
          modelJson['color'] = _themeColor!.toHex;
        }
        final model = createModelFromJson(
            modelJson
        );

        if (isEditMode && currentModel != null) {
          final updatedModel = copyModelWithId(model, getModelId(currentModel!));
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
}