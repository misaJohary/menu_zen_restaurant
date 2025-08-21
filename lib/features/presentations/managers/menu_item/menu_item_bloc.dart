import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/menu_item_repository.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../datasources/models/category_model.dart';
import '../../../datasources/models/menu_item_model.dart';
import '../../../datasources/models/menu_model.dart';
import '../../../domains/entities/menu_item_entity.dart';

part 'menu_item_event.dart';

part 'menu_item_state.dart';

class MenuItemBloc extends Bloc<MenuItemEvent, MenuItemState> {
  final MenuItemRepository repo;

  MenuItemBloc({required this.repo}) : super(MenuItemState()) {
    on<MenuItemCreated>(_onMenuItemCreated);
    on<MenuItemFetched>(_onMenuItemFetched);
    on<MenuItemUpdated>(_onMenuItemUpdated);
    on<MenuItemDeleted>(_onMenuItemDeleted);
  }

  //MenuItem CRUD
  _onMenuItemCreated(MenuItemCreated event, Emitter<MenuItemState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await repo.addMenuItem(
      MenuItemModel.fromEntity(
        event.menu,
        CategoryModel.fromEntity(event.menu.category),
          event.menu.menus.map((menu) => MenuModel.fromEntity(menu)).toList()
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
      emit(state.copyWith(status: BlocStatus.loaded, menuItems: res.getSuccess));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onMenuItemUpdated(MenuItemUpdated event, Emitter<MenuItemState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await repo.updateMenuItem(
      MenuItemModel.fromEntity(
        event.menu,
        CategoryModel.fromEntity(event.menu.category),
          event.menu.menus.map((menu) => MenuModel.fromEntity(menu)).toList()
      ),
    );
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
      final updatedMenuItems = state.menuItems
          .where((menuItem) => menuItem.id != event.menuId)
          .toList();
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
}
