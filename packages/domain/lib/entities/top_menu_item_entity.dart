import 'package:equatable/equatable.dart';

class TopMenuItemEntity extends Equatable {
  final int id;
  final String name;
  final String picture;
  final String category;
  final int timesOrdered;
  final int totalQuantity;
  final double totalRevenue;

  const TopMenuItemEntity({
    required this.id,
    required this.name,
    required this.picture,
    required this.category,
    required this.timesOrdered,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    picture,
    category,
    timesOrdered,
    totalQuantity,
    totalRevenue,
  ];
}
