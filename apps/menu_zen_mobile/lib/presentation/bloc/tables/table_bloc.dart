import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data/models/table_model.dart';
import 'package:domain/entities/table_entity.dart';
import 'package:domain/repositories/tables_repository.dart';

import '../../../core/enums/bloc_status.dart';

part 'table_event.dart';
part 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TablesRepository tablesRepository;

  TableBloc({required this.tablesRepository}) : super(const TableState()) {
    on<TableFetched>(_onFetched);
    on<TableCreated>(_onCreated);
    on<TableUpdated>(_onUpdated);
    on<TableDeleted>(_onDeleted);
  }

  Future<void> _onFetched(
    TableFetched event,
    Emitter<TableState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await tablesRepository.getAll();
    if (res.isSuccess) {
      emit(state.copyWith(status: BlocStatus.loaded, tables: res.getSuccess));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  Future<void> _onCreated(
    TableCreated event,
    Emitter<TableState> emit,
  ) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));
    final res = await tablesRepository.add(TableModel.fromEntity(event.table));
    if (res.isSuccess) {
      emit(state.copyWith(
        editStatus: BlocStatus.loaded,
        tables: [...state.tables, res.getSuccess!],
      ));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  Future<void> _onUpdated(
    TableUpdated event,
    Emitter<TableState> emit,
  ) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));
    final res =
        await tablesRepository.update(TableModel.fromEntity(event.table));
    if (res.isSuccess) {
      final updated = state.tables
          .map((t) => t.id == res.getSuccess!.id ? res.getSuccess! : t)
          .toList();
      emit(state.copyWith(editStatus: BlocStatus.loaded, tables: updated));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  Future<void> _onDeleted(
    TableDeleted event,
    Emitter<TableState> emit,
  ) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));
    final res = await tablesRepository.delete(event.tableId);
    if (res.isSuccess) {
      emit(state.copyWith(
        editStatus: BlocStatus.loaded,
        tables: state.tables.where((t) => t.id != event.tableId).toList(),
      ));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }
}
