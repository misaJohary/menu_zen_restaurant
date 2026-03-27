import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/image_repository.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/menu_item_repository.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../datasources/models/menu_item_model.dart';
import '../../../datasources/models/menu_item_update_model.dart';
import '../../../domains/entities/menu_item_entity.dart';

part 'menu_item_event.dart';

part 'menu_item_state.dart';

class MenuItemBloc extends Bloc<MenuItemEvent, MenuItemState> {
  final MenuItemRepository repo;
  final ImageRepository imageRepo;

  MenuItemBloc({required this.repo, required this.imageRepo})
    : super(MenuItemState()) {
    on<MenuItemCreated>(_onMenuItemCreated);
    on<MenuItemFetched>(_onMenuItemFetched);
    on<MenuItemUpdated>(_onMenuItemUpdated);
    on<MenuItemDeleted>(_onMenuItemDeleted);
    on<MenuItemPictureUploaded>(_onMenuItemPictureUploaded);
  }

  //MenuItem CRUD
  _onMenuItemCreated(MenuItemCreated event, Emitter<MenuItemState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));
    final res = await repo.addMenuItem(
      MenuItemModel.fromEntity(
        (event.menu as MenuItemModel).copyWith(
          picture: state.uploadedPictureUrl,
        ),
      ),
      event.file!,
    );
    if (res.isSuccess) {
      final updatedMenuItems = List<MenuItemEntity>.from(state.menuItems)
        ..add(res.getSuccess!);
      emit(
        state.copyWith(
          editStatus: BlocStatus.loaded,
          menuItems: updatedMenuItems,
        ),
      );
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onMenuItemFetched(MenuItemFetched event, Emitter<MenuItemState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final res = await repo.getMenuItems();
    if (res.isSuccess) {
      emit(
        state.copyWith(status: BlocStatus.loaded, menuItems: res.getSuccess),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onMenuItemUpdated(MenuItemUpdated event, Emitter<MenuItemState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await repo.updateMenuItem(event.menu);
    if (res.isSuccess) {
      final updatedMenuItems = state.menuItems.map((menuItem) {
        return menuItem.id == res.getSuccess!.id ? res.getSuccess! : menuItem;
      }).toList();
      emit(
        state.copyWith(
          editStatus: BlocStatus.loaded,
          menuItems: updatedMenuItems,
        ),
      );
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onMenuItemDeleted(MenuItemDeleted event, Emitter<MenuItemState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await repo.deleteMenuItem(event.menuId);
    if (res.isSuccess) {
      Logger().d(event.menuId);
      final updatedMenuItems = state.menuItems.where((menuItem) {
        return menuItem.id != event.menuId;
      }).toList();
      emit(
        state.copyWith(
          editStatus: BlocStatus.loaded,
          menuItems: updatedMenuItems,
        ),
      );
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onMenuItemPictureUploaded(
    MenuItemPictureUploaded event,
    Emitter<MenuItemState> emit,
  ) async {
    try {
      emit(state.copyWith(uploadStatus: BlocStatus.loading));
      Logger().e('begin');
      final res = await imageRepo.uploadImage(event.file);
      Logger().e('end');
      if (res.isSuccess) {
        Logger().e(res.getSuccess);
        emit(
          state.copyWith(
            uploadStatus: BlocStatus.loaded,
            uploadedPictureUrl: res.getSuccess,
          ),
        );
      } else {
        emit(state.copyWith(uploadStatus: BlocStatus.failed));
      }
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
