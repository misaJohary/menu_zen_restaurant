import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../datasources/models/table_model.dart';
import '../../../domains/entities/table_entity.dart';
import '../../../domains/repositories/tables_repository.dart';

part 'table_event.dart';
part 'table_state.dart';


class TableBloc extends Bloc<TableEvent, TableState> {
  final TablesRepository tablesRepository;

  TableBloc({required this.tablesRepository}) : super(TableState()) {
    on<TableCreated>(_onTableCreated);
    on<TableFetched>(_onTableFetched);
    on<TableUpdated>(_onTableUpdated);
    on<TableDeleted>(_onTableDeleted);
  }

  //Menus CRUD

  _onTableCreated(TableCreated event, Emitter<TableState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await tablesRepository.add(TableModel.fromEntity(event.table));
    if (res.isSuccess) {
      final updatedMenus = List<TableEntity>.from(state.tables)
        ..add(res.getSuccess!);
      emit(state.copyWith(editStatus: BlocStatus.loaded, tables: updatedMenus));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onTableFetched(TableFetched event, Emitter<TableState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final res = await tablesRepository.getAll();
    if (res.isSuccess) {
      emit(state.copyWith(status: BlocStatus.loaded, tables: res.getSuccess));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onTableUpdated(TableUpdated event, Emitter<TableState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await tablesRepository.update(
      TableModel.fromEntity(event.table),
    );
    if (res.isSuccess) {
      final updatedMenus = state.tables.map((table) {
        return table.id == res.getSuccess!.id ? res.getSuccess! : table;
      }).toList();
      emit(state.copyWith(editStatus: BlocStatus.loaded, tables: updatedMenus));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onTableDeleted(TableDeleted event, Emitter<TableState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await tablesRepository.delete(event.tableId);
    if (res.isSuccess) {
      final updatedMenus = state.tables
          .where((table) => table.id != event.tableId)
          .toList();
      emit(state.copyWith(editStatus: BlocStatus.loaded, tables: updatedMenus));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }
}