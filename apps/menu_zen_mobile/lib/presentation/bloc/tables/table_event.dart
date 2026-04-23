part of 'table_bloc.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();
}

class TableFetched extends TableEvent {
  const TableFetched();
  @override
  List<Object?> get props => [];
}

class TableCreated extends TableEvent {
  final TableEntity table;
  const TableCreated(this.table);
  @override
  List<Object?> get props => [table];
}

class TableUpdated extends TableEvent {
  final TableEntity table;
  const TableUpdated(this.table);
  @override
  List<Object?> get props => [table];
}

class TableDeleted extends TableEvent {
  final int tableId;
  const TableDeleted(this.tableId);
  @override
  List<Object?> get props => [tableId];
}
