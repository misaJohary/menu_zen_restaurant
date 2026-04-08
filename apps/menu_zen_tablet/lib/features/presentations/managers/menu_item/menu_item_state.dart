part of 'menu_item_bloc.dart';

class MenuItemState extends Equatable {
  const MenuItemState({
    this.status = BlocStatus.init,
    this.menuItems = const [],
    this.editStatus = BlocStatus.init,
    this.uploadStatus = BlocStatus.init,
    this.uploadedPictureUrl = '',
  });

  final BlocStatus status;
  final BlocStatus editStatus;
  final BlocStatus uploadStatus;
  final String uploadedPictureUrl;
  final List<MenuItemEntity> menuItems;

  MenuItemState copyWith({
    BlocStatus? status,
    BlocStatus? editStatus,
    BlocStatus? uploadStatus,
    List<MenuItemEntity>? menuItems,
    String? uploadedPictureUrl,
  }) {
    return MenuItemState(
      status: status ?? this.status,
      editStatus: editStatus ?? this.editStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      menuItems: menuItems ?? this.menuItems,
      uploadedPictureUrl: uploadedPictureUrl ?? this.uploadedPictureUrl,
    );
  }

  @override
  List<Object?> get props => [status, menuItems, editStatus, uploadStatus];
}
