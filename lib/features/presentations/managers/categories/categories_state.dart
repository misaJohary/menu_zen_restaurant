part of 'categories_bloc.dart';

class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = BlocStatus.init,
    this.categories = const [],
    this.editStatus = BlocStatus.init,
  });

  final BlocStatus status;
  final BlocStatus editStatus;
  final List<CategoryEntity> categories;

  @override
  List<Object?> get props => [status, editStatus, categories];

  CategoriesState copyWith({
    BlocStatus? status,
    BlocStatus? editStatus,
    List<CategoryEntity>? categories,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      editStatus: editStatus ?? this.editStatus,
      categories: categories ?? this.categories,
    );
  }
}