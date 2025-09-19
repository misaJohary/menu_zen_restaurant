import 'package:equatable/equatable.dart';

class TableEntity extends Equatable {
  final int? id;
  final String name;
  final bool isActive;

  const TableEntity({this.id, required this.name, this.isActive = true});

  ///copyWith
  TableEntity copyWith({int? id, String? name, bool? isActive}) {
    return TableEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}
