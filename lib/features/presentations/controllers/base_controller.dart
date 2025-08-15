import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:logger/logger.dart';

abstract class BaseController<TBloc extends BlocBase, TModel, TEntity>
    extends ChangeNotifier {

  BaseController({required this.context});

  final formKey = GlobalKey<FormBuilderState>();
  final BuildContext context;

  bool _showField = false;
  bool get isFieldShown => _showField;

  bool _isEditMode = false;
  bool get isEditMode => _isEditMode;

  TModel? _currentModel;
  TModel? get currentModel => _currentModel;

  // Abstract getter that child classes must implement to provide their specific bloc
  TBloc get bloc;

  // Abstract methods that child classes must implement
  TModel createModelFromJson(Map<String, dynamic> json);
  TModel createModelFromEntity(TEntity entity);
  Map<String, dynamic> modelToJson(TModel model);
  TModel copyModelWithId(TModel model, dynamic id);
  dynamic getModelId(TModel model);

  // Abstract methods for bloc events - child classes implement these
  void addFetchEvent();
  void addCreateEvent(TModel model);
  void addUpdateEvent(TEntity entity);
  void addDeleteEvent(dynamic id);

  void showField(bool value, {TEntity? entity}) async {
    _showField = value;
    _isEditMode = false;
    _currentModel = null;

    if (entity != null) {
      _isEditMode = true;
      _currentModel = createModelFromEntity(entity);
    }

    notifyListeners();
  }

  void initEdit() {
    if (_currentModel != null) {
      formKey.currentState?.patchValue(modelToJson(_currentModel!));
    }
  }

  void validate() {
    try {
      final currentState = formKey.currentState;
      if (currentState?.saveAndValidate() ?? false) {
        TModel model = createModelFromJson(
          currentState!.fields.map((key, value) => MapEntry(key, value.value)),
        );

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

  void fetchItems() {
    addFetchEvent();
  }

  void addItem(TModel model) {
    addCreateEvent(model);
  }

  void updateItem(TEntity entity) {
    addUpdateEvent(entity);
  }

  void deleteItem(dynamic id) {
    addDeleteEvent(id);
  }
}