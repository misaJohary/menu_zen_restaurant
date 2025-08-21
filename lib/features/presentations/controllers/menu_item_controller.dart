import 'dart:io';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_entity.dart';

import '../../datasources/models/category_model.dart';
import '../../datasources/models/menu_item_model.dart';
import '../../datasources/models/menu_model.dart';
import '../../domains/entities/menu_item_entity.dart';
import '../managers/menu_item/menu_item_bloc.dart';
import 'base_controller.dart';

class MenuItemController extends BaseController<MenuItemBloc, MenuItemModel, MenuItemEntity> {
  MenuItemController({required super.context});

  Color? _themeColor;
  Color? get themeColor => _themeColor;

  XFile? _filePicked;
  XFile? get filePicked => _filePicked;

  set setFilePicked(XFile? file) {
    _filePicked = file;
    notifyListeners();
  }

  set setThemeColor(Color? color) {
    _themeColor = color;
    notifyListeners();
  }

  get resetThemeColor {
    _themeColor = null;
    notifyListeners();
  }

  @override
  void validate() {
    print(formKey.currentState!.fields);

    Map<String, dynamic> formData = formKey.currentState!.fields.map((key, value) => MapEntry(key, value.value));
    final price = double.tryParse(formData['price']);
    final category = (formData['category'] as CategoryModel?)!.toJson();
    final menus = (formData['menus'] as List<MenuEntity>?)?.map((menu) => MenuModel.fromEntity(menu).toJson()).toList() ?? [];
    formData.addAll({
      'picture': filePicked,
      'price': price ?? 0.0,
      'category': category,
      'menus': menus,
    });

    Logger().e('Form Data: $formData');
    try {
      final currentState = formKey.currentState;
      if (currentState?.saveAndValidate() ?? false) {
        final model = createModelFromJson(
            formData
        );

        if (isEditMode && currentModel != null) {
          final updatedModel = copyModelWithId(model, getModelId(currentModel!));
          return updateItem(updatedModel);
        }
        addCreateEvent(model, file: File(filePicked!.path));
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  @override
  MenuItemBloc get bloc => context.read<MenuItemBloc>();

  @override
  MenuItemModel createModelFromJson(Map<String, dynamic> json) {
    return MenuItemModel.fromJson(json);
  }

  @override
  MenuItemModel createModelFromEntity(MenuItemEntity entity) {
    return MenuItemModel.fromEntity(entity, CategoryModel.fromEntity(entity.category), entity.menus.map((menu) => MenuModel.fromEntity(menu)).toList());
  }

  @override
  Map<String, dynamic> modelToJson(MenuItemModel model) {
    return model.toJson();
  }

  @override
  MenuItemModel copyModelWithId(MenuItemModel model, dynamic id) {
    return model.copyWith(id: id);
  }

  @override
  dynamic getModelId(MenuItemModel model) {
    return model.id;
  }


  @override
  void addFetchEvent() {
    bloc.add(MenuItemFetched());
  }

  @override
  void addCreateEvent(MenuItemModel model, {File? file}) {
    bloc.add(MenuItemCreated(model, file: file));
  }

  @override
  void addUpdateEvent(MenuItemEntity entity) {
    bloc.add(MenuItemUpdated(entity));
  }

  @override
  void addDeleteEvent(dynamic id) {
    bloc.add(MenuItemDeleted(id));
  }
}