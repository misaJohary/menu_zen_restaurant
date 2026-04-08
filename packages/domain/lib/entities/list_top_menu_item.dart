import 'package:equatable/equatable.dart';
import 'top_menu_item_entity.dart';

class ListTopMenuItem extends Equatable {
  final List<TopMenuItemEntity> values;
  final int totalQuantity;

  const ListTopMenuItem({required this.values, required this.totalQuantity});

  factory ListTopMenuItem.create(List<TopMenuItemEntity> menuItems) =>
      ListTopMenuItem(
        values: menuItems,
        totalQuantity: menuItems.fold(
          0,
          (sum, item) => sum + item.totalQuantity,
        ),
      );

  @override
  List<Object?> get props => [values, totalQuantity];
}
