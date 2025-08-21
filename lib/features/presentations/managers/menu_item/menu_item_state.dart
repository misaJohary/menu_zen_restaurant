part of 'menu_item_bloc.dart';

class MenuItemState extends Equatable {
  const MenuItemState({
    this.status = BlocStatus.init,
    this.menuItems = const [],
    this.editStatus = BlocStatus.init,
  });

  final BlocStatus status;
  final BlocStatus editStatus;
  final List<MenuItemEntity> menuItems;

  MenuItemState copyWith({
    BlocStatus? status,
    BlocStatus? editStatus,
    List<MenuItemEntity>? menuItems,
  }) {
    return MenuItemState(
      status: status ?? this.status,
      editStatus: editStatus ?? this.editStatus,
      menuItems: menuItems ?? this.menuItems,
    );
  }

  @override
  List<Object?> get props => [status, menuItems, editStatus];
}