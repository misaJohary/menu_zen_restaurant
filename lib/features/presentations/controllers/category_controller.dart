// import 'base_controller.dart';
//
// class CategoriesController extends BaseController<CategoriesBloc, CategoryModel, CategoryEntity> {
//   CategoriesController({required super.context});
//
//   @override
//   CategoriesBloc get bloc => context.read<CategoriesBloc>();
//
//   @override
//   CategoryModel createModelFromJson(Map<String, dynamic> json) {
//     return CategoryModel.fromJson(json);
//   }
//
//   @override
//   CategoryModel createModelFromEntity(CategoryEntity entity) {
//     return CategoryModel.fromEntity(entity);
//   }
//
//   @override
//   Map<String, dynamic> modelToJson(CategoryModel model) {
//     return model.toJson();
//   }
//
//   @override
//   CategoryModel copyModelWithId(CategoryModel model, dynamic id) {
//     return model.copyWith(id: id);
//   }
//
//   @override
//   dynamic getModelId(CategoryModel model) {
//     return model.id;
//   }
//
//   @override
//   void addFetchEvent() {
//     bloc.add(CategoriesFetched());
//   }
//
//   @override
//   void addCreateEvent(CategoryModel model) {
//     bloc.add(CategoriesCreated(model));
//   }
//
//   @override
//   void addUpdateEvent(CategoryEntity entity) {
//     bloc.add(CategoriesUpdated(entity));
//   }
//
//   @override
//   void addDeleteEvent(dynamic id) {
//     bloc.add(CategoriesDeleted(id));
//   }
// }