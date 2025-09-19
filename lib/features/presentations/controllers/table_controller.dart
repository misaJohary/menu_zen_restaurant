import 'package:flutter_bloc/flutter_bloc.dart';

import '../../datasources/models/table_model.dart';
import '../../domains/entities/table_entity.dart';
import '../managers/tables/table_bloc.dart';
import 'base_controller.dart';

class TablesController extends BaseController<TableBloc, TableModel, TableEntity> {
  TablesController({required super.context});

  @override
  TableBloc get bloc => context.read<TableBloc>();

  @override
  TableModel createModelFromJson(Map<String, dynamic> json) {
    return TableModel.fromJson(json);
  }

  @override
  TableModel createModelFromEntity(TableEntity entity) {
    return TableModel.fromEntity(entity);
  }

  @override
  Map<String, dynamic> modelToJson(TableModel model) {
    return model.toJson();
  }

  @override
  TableModel copyModelWithId(TableModel model, dynamic id) {
    return model.copyWith(id: id);
  }

  @override
  dynamic getModelId(TableModel model) {
    return model.id;
  }


  @override
  void addFetchEvent() {
    bloc.add(TableFetched());
  }

  @override
  void addCreateEvent(TableModel model) {
    bloc.add(TableCreated(model));
  }

  @override
  void addUpdateEvent(TableEntity entity) {
    bloc.add(TableUpdated(entity));
  }

  @override
  void addDeleteEvent(dynamic id) {
    bloc.add(TableDeleted(id));
  }
}