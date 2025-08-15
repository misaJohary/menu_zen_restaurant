part of 'menus_bloc.dart';

abstract class MenusEvent extends Equatable {
  const MenusEvent();
}

class MenusFetched extends MenusEvent {
  const MenusFetched();

  @override
  List<Object?> get props => [];
}

class MenusCreated extends MenusEvent {
  final MenuEntity menu;

  const MenusCreated(this.menu);

  @override
  List<Object?> get props => [menu];
}

class MenusUpdated extends MenusEvent {
  final MenuEntity menu;

  const MenusUpdated(this.menu);

  @override
  List<Object?> get props => [menu];
}

class MenusDeleted extends MenusEvent{
  final int menuId;

  const MenusDeleted(this.menuId);

  @override
  List<Object?> get props => [menuId];
}