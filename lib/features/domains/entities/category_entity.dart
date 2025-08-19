import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class CategoryEntity extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final Color? themeColor;

  const CategoryEntity({
    this.id,
    required this.name,
    this.description,
    this.themeColor,
  });

  @override
  List<Object?> get props => [id, name, description, themeColor];
}