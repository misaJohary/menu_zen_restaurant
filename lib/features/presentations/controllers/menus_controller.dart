import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_entity.dart';

import '../../datasources/models/menu_model.dart';
import '../managers/menus/menus_bloc.dart';
import 'base_controller.dart';

class MenusController extends BaseController<MenusBloc, MenuModel, MenuEntity> {
  MenusController({required super.context});

  @override
  MenusBloc get bloc => context.read<MenusBloc>();

  @override
  MenuModel createModelFromJson(Map<String, dynamic> json) {
    return MenuModel.fromJson(json);
  }

  @override
  MenuModel createModelFromEntity(MenuEntity entity) {
    return MenuModel.fromEntity(entity);
  }

  @override
  Map<String, dynamic> modelToJson(MenuModel model) {
    return model.toJson();
  }

  @override
  MenuModel copyModelWithId(MenuModel model, dynamic id) {
    return model.copyWith(id: id);
  }

  @override
  dynamic getModelId(MenuModel model) {
    return model.id;
  }

  @override
  void addFetchEvent() {
    bloc.add(MenusFetched());
  }

  @override
  void addCreateEvent(MenuModel model) {
    bloc.add(MenusCreated(model));
  }

  @override
  void addUpdateEvent(MenuEntity entity) {
    bloc.add(MenusUpdated(entity));
  }

  @override
  void addDeleteEvent(dynamic id) {
    bloc.add(MenusDeleted(id));
  }
}

/*
class MenusController extends ChangeNotifier {
  MenusController({required this.context});

  final formKey = GlobalKey<FormBuilderState>();

  final BuildContext context;
  bool _showField = false;

  bool get isFieldShown => _showField;

  bool _isEditMode = false;

  bool get isEditMode => _isEditMode;
  MenuModel? _menuModel;

  get _menuBloc => context.read<MenusBloc>();

  void showField(bool value, {MenuEntity? menu}) async {
    _showField = value;
    _isEditMode = false;
    _menuModel = null;
    if (menu != null) {
      _isEditMode = true;
      _menuModel = MenuModel.fromEntity(menu);
    }
    notifyListeners();
  }

  void initEdit() {
    if (_menuModel != null) {
      formKey.currentState?.patchValue(_menuModel!.toJson());
    }
  }

  void validate() {
    try {
      final currentState = formKey.currentState;
      if (currentState?.saveAndValidate() ?? false) {
        MenuModel menusModel = MenuModel.fromJson(
          currentState!.fields.map((key, value) => MapEntry(key, value.value)),
        );
        if (_isEditMode && _menuModel != null) {
          menusModel.copyWith(id: _menuModel!.id);
          return updateMenu(menusModel.copyWith(id: _menuModel!.id));
        }
        addMenu(menusModel);
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  void fetchMenus() {
    _menuBloc.add(MenusFetched());
  }

  void addMenu(MenuModel menu) {
    _menuBloc.add(MenusCreated(menu));
  }

  void updateMenu(MenuEntity menu) {
    _menuBloc.add(MenusUpdated(menu));
  }

  void deleteMenu(int id) {
    _menuBloc.add(MenusDeleted(id));
  }
}
*/