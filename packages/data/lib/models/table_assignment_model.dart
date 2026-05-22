import 'package:domain/entities/table_assignment_entity.dart';
import 'package:domain/entities/table_assignment_status.dart';

class TableAssignmentModel {
  static TableAssignmentEntity fromJson(Map<String, dynamic> json) {
    return TableAssignmentEntity(
      id: json['id'] as int,
      tableId: json['table_id'] as int,
      status: TableAssignmentStatus.fromString(json['status'] as String?),
    );
  }
}
