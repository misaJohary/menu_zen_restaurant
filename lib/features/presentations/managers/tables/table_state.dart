part of 'table_bloc.dart';

class TableState extends Equatable {
  const TableState({
    this.status = BlocStatus.init,
    this.tables = const [],
    this.editStatus = BlocStatus.init,
  });

  final BlocStatus status;
  final BlocStatus editStatus;
  final List<TableEntity> tables;

  TableState copyWith({
    BlocStatus? status,
    BlocStatus? editStatus,
    List<TableEntity>? tables,
  }) {
    return TableState(
      status: status ?? this.status,
      editStatus: editStatus ?? this.editStatus,
      tables: tables ?? this.tables,
    );
  }

  @override
  List<Object?> get props => [status, tables, editStatus];
}
