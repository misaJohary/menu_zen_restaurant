import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../datasources/models/category_model.dart';
import '../../../domains/entities/category_entity.dart';
import '../../../domains/repositories/categories_repository.dart';

part 'categories_event.dart';

part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepository categoriesRepository;

  CategoriesBloc({required this.categoriesRepository})
    : super(CategoriesState()) {
    on<CategoriesCreated>(_onCategoriesCreated);
    on<CategoriesFetched>(_onCategoriesFetched);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<CategoriesDeleted>(_onCategoriesDeleted);
  }

  // Categories CRUD
  _onCategoriesCreated(
    CategoriesCreated event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await categoriesRepository.addCategory(
      CategoryModel.fromEntity(event.category),
    );
    if (res.isSuccess) {
      final updatedCategories = List<CategoryEntity>.from(state.categories)
        ..add(res.getSuccess!);
      emit(
        state.copyWith(
          editStatus: BlocStatus.loaded,
          categories: updatedCategories,
        ),
      );
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onCategoriesFetched(
    CategoriesFetched event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));

    final res = await categoriesRepository.getCategories();
    if (res.isSuccess) {
      emit(
        state.copyWith(status: BlocStatus.loaded, categories: res.getSuccess),
      );
    } else {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }

  _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await categoriesRepository.updateCategory(
      CategoryModel.fromEntity(event.category),
    );
    if (res.isSuccess) {
      final updatedCategories = state.categories.map((category) {
        return category.id == res.getSuccess!.id ? res.getSuccess! : category;
      }).toList();
      emit(
        state.copyWith(
          editStatus: BlocStatus.loaded,
          categories: updatedCategories,
        ),
      );
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }

  _onCategoriesDeleted(
    CategoriesDeleted event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(editStatus: BlocStatus.loading));

    final res = await categoriesRepository.deleteCategory(event.categoryId);
    if (res.isSuccess) {
      final updatedCategories = state.categories
          .where((category) => category.id != event.categoryId)
          .toList();
      emit(
        state.copyWith(
          editStatus: BlocStatus.loaded,
          categories: updatedCategories,
        ),
      );
    } else {
      emit(state.copyWith(editStatus: BlocStatus.failed));
    }
  }
}