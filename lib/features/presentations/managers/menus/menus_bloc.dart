import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:menu_zen_restaurant/features/datasources/models/menu_model.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/menus_repository.dart';

import '../../../domains/entities/menu_entity.dart';

part 'menus_event.dart';

part 'menus_state.dart';

class MenusBloc extends Bloc<MenusEvent, MenusState> {
  final MenusRepository menusRepository;

  MenusBloc({required this.menusRepository}) : super(MenusState()) {
    on<MenusCreated>(_onMenusCreated);
    on<MenusFetched>(_onMenusFetched);
    on<MenusUpdated>(_onMenusUpdated);
    on<MenusDeleted>(_onMenusDeleted);
  }

  //Menus CRUD

  _onMenusCreated(MenusCreated event, Emitter<MenusState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await menusRepository.addMenu(MenuModel.fromEntity(event.menu));
    if (res.isSuccess) {
      final updatedMenus = List<MenuEntity>.from(state.menus)
        ..add(res.getSuccess!);
      emit(state.copyWith(editStatus: BlocStatus.loaded, menus: updatedMenus));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onMenusFetched(MenusFetched event, Emitter<MenusState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final res = await menusRepository.getMenus();
    if (res.isSuccess) {
      emit(state.copyWith(status: BlocStatus.loaded, menus: res.getSuccess));
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onMenusUpdated(MenusUpdated event, Emitter<MenusState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await menusRepository.updateMenu(
      MenuModel.fromEntity(event.menu),
    );
    if (res.isSuccess) {
      final updatedMenus = state.menus.map((menu) {
        return menu.id == res.getSuccess!.id ? res.getSuccess! : menu;
      }).toList();
      emit(state.copyWith(editStatus: BlocStatus.loaded, menus: updatedMenus));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onMenusDeleted(MenusDeleted event, Emitter<MenusState> emit) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await menusRepository.deleteMenu(event.menuId);
    if (res.isSuccess) {
      final updatedMenus = state.menus
          .where((menu) => menu.id != event.menuId)
          .toList();
      emit(state.copyWith(editStatus: BlocStatus.loaded, menus: updatedMenus));
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }
}