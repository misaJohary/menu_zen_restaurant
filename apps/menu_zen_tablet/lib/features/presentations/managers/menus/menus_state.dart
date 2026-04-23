part of 'menus_bloc.dart';

class MenusState extends Equatable {
  const MenusState({
    this.status = BlocStatus.init,
    this.menus = const [],
    this.editStatus = BlocStatus.init,
  });

  final BlocStatus status;
  final BlocStatus editStatus;
  final List<MenuEntity> menus;

  MenusState copyWith({
    BlocStatus? status,
    BlocStatus? editStatus,
    List<MenuEntity>? menus,
  }) {
    return MenusState(
      status: status ?? this.status,
      editStatus: editStatus ?? this.editStatus,
      menus: menus ?? this.menus,
    );
  }

  @override
  List<Object?> get props => [status, menus, editStatus];
}
