import 'package:json_annotation/json_annotation.dart';

import '../../domains/entities/table_entity.dart';

part 'table_model.g.dart';

@JsonSerializable()
class TableModel extends TableEntity {
  const TableModel({super.id, required super.name, super.isActive});

  factory TableModel.fromJson(Map<String, dynamic> json) =>
      _$TableModelFromJson(json);

  Map<String, dynamic> toJson() => _$TableModelToJson(this);

  ///fromEntity

  factory TableModel.fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
    );
  }

  ///copyWith
  @override
  TableModel copyWith({int? id, String? name, bool? isActive}) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
