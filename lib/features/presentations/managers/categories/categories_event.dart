part of 'categories_bloc.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();
}

class CategoriesFetched extends CategoriesEvent {
  const CategoriesFetched();

  @override
  List<Object?> get props => [];
}

class CategoriesCreated extends CategoriesEvent {
  final CategoryEntity category;

  const CategoriesCreated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoriesUpdated extends CategoriesEvent {
  final CategoryEntity category;

  const CategoriesUpdated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoriesDeleted extends CategoriesEvent {
  final int categoryId;

  const CategoriesDeleted(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}