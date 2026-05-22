import 'package:equatable/equatable.dart';

import 'table_assignment_status.dart';

class TableAssignmentEntity extends Equatable {
  final int id;
  final int tableId;
  final TableAssignmentStatus status;

  const TableAssignmentEntity({
    required this.id,
    required this.tableId,
    required this.status,
  });

  @override
  List<Object?> get props => [id, tableId, status];
}
