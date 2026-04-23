part of 'menu_item_bloc.dart';

abstract class MenuItemEvent extends Equatable {
  const MenuItemEvent();
}

class MenuItemFetched extends MenuItemEvent {
  const MenuItemFetched();

  @override
  List<Object?> get props => [];
}

class MenuItemCreated extends MenuItemEvent {
  final MenuItemEntity menu;
  final File? file;

  const MenuItemCreated(this.menu, {this.file});

  @override
  List<Object?> get props => [menu, file];
}

class MenuItemUpdated extends MenuItemEvent {
  final MenuItemUpdateModel menu;

  const MenuItemUpdated(this.menu);

  @override
  List<Object?> get props => [menu];
}

class MenuItemDeleted extends MenuItemEvent {
  final int menuId;

  const MenuItemDeleted(this.menuId);

  @override
  List<Object?> get props => [menuId];
}

class MenuItemPictureUploaded extends MenuItemEvent {
  final XFile file;

  const MenuItemPictureUploaded(this.file);

  @override
  List<Object?> get props => [file];
}
