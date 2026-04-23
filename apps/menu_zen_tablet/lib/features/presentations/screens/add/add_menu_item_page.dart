import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menu_item_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/categories/categories_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/kitchens/kitchens_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/menu_item/menu_item_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/menus/menus_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/add_item_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/multilingual_field.dart';

import '../../../../core/constants/constants.dart';
import 'package:domain/entities/menu_entity.dart';

class AddMenuItemPage extends StatefulWidget {
  const AddMenuItemPage({super.key, this.menuItem});

  final dynamic menuItem; // MenuItemEntity | MenuItemModel

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  late final MenuItemController controller;
  final GlobalKey<State<AddItemWidget>> _addItemWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = MenuItemController(context: context);
    controller.showField(true, entity: widget.menuItem);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initEdit();
      _patchNonMultilingual();
      if (context.read<KitchensBloc>().state.kitchens.isEmpty) {
        context.read<KitchensBloc>().add(const KitchensFetched());
      }
    });
  }

  void _patchNonMultilingual() {
    final currentModel = controller.currentModel;
    final formState = controller.formKey.currentState;
    if (currentModel == null || formState is! FormBuilderState) return;

    void patchWithReferences() {
      final categoriesState = context.read<CategoriesBloc>().state;
      final menusState = context.read<MenusBloc>().state;
      final kitchensState = context.read<KitchensBloc>().state;

      final categoryId = currentModel.category?.id;
      final resolvedCategory = categoryId != null
          ? categoriesState.categories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () =>
                  currentModel.category ?? categoriesState.categories.first,
            )
          : currentModel.category;

      final desiredMenuIds = currentModel.menus
          .map((m) => m.id)
          .whereType<int>()
          .toSet();
      final resolvedMenus = menusState.menus
          .where((m) => desiredMenuIds.contains(m.id))
          .toList();

      final kitchenId = currentModel.kitchenId;
      final resolvedKitchen = kitchenId != null
          ? kitchensState.kitchens.where((k) => k.id == kitchenId).firstOrNull
          : null;

      formState.patchValue({
        'price': currentModel.price.toString(),
        'category': resolvedCategory,
        'menus': resolvedMenus.isNotEmpty ? resolvedMenus : currentModel.menus,
        if (resolvedKitchen != null) 'kitchen': resolvedKitchen,
      });
    }

    final categoriesLoaded = context
        .read<CategoriesBloc>()
        .state
        .categories
        .isNotEmpty;
    final menusLoaded = context.read<MenusBloc>().state.menus.isNotEmpty;
    final kitchensLoaded = context
        .read<KitchensBloc>()
        .state
        .kitchens
        .isNotEmpty;
    if (!categoriesLoaded) {
      context.read<CategoriesBloc>().add(CategoriesFetched());
    }
    if (!menusLoaded) context.read<MenusBloc>().add(MenusFetched());
    if (!kitchensLoaded)
      context.read<KitchensBloc>().add(const KitchensFetched());

    patchWithReferences();
    WidgetsBinding.instance.addPostFrameCallback((_) => patchWithReferences());
  }

  Map<String, Map<String, String>>? _getInitialTranslations() {
    final entity = widget.menuItem;
    if (entity == null ||
        entity.translations == null ||
        entity.translations.isEmpty) {
      return null;
    }
    final Map<String, Map<String, String>> map = {};
    for (var t in entity.translations) {
      map[t.languageCode] = {
        'name': t.name,
        if (t.description != null) 'description': t.description!,
      };
    }
    return map;
  }

  Map<String, Map<String, String>>? get translations =>
      AddItemWidget.getTranslations(_addItemWidgetKey);

  void _onSubmit() {
    final frenchName = translations?['fr']?['name'];
    if (frenchName == null || frenchName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom en français est requis')),
      );
      return;
    }
    controller.validateWithTranslations(translations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.menuItem == null ? 'Ajouter un item' : 'Modifier un item',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kspacing * 2),
        child: ListView(
          children: [
            AddItemWidget(
              key: _addItemWidgetKey,
              formKey: controller.formKey,
              title: widget.menuItem == null ? 'Nouvel Item' : 'Éditer Item',
              initialTranslations: _getInitialTranslations(),
              multilingualFields: const [
                MultilingualField(
                  name: 'name',
                  label: "Nom de l'item",
                  maxLines: 1,
                ),
                MultilingualField(
                  name: 'description',
                  label: 'Description',
                  maxLines: 2,
                ),
              ],
              formBuilderFields: [
                FormBuilderTextField(
                  name: 'price',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(label: Text("Prix (Ar)")),
                  validator: FormBuilderValidators.required(),
                ),
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    return FormBuilderDropdown(
                      name: 'category',
                      hint: const Text("Sélectionner une catégorie"),
                      validator: FormBuilderValidators.required(),
                      items: state.categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category.translations.first.name),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                BlocBuilder<MenusBloc, MenusState>(
                  builder: (context, state) {
                    return FormBuilderFilterChips<MenuEntity>(
                      name: 'menus',
                      spacing: 8,
                      decoration: const InputDecoration(
                        label: Text("Disponible dans les menus"),
                      ),
                      options: state.menus
                          .map(
                            (menu) => FormBuilderChipOption(
                              value: menu,
                              child: Text(menu.translations.first.name),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                BlocBuilder<KitchensBloc, KitchensState>(
                  builder: (context, state) {
                    return FormBuilderDropdown(
                      name: 'kitchen',
                      hint: const Text('Aucune cuisine assignée'),
                      decoration: const InputDecoration(label: Text('Cuisine')),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Aucune'),
                        ),
                        ...state.kitchens.map(
                          (k) =>
                              DropdownMenuItem(value: k, child: Text(k.name)),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: kspacing * 2),
              ],
              confirmationButton: BlocBuilder<MenuItemBloc, MenuItemState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: _onSubmit,
                    child: Text(
                      widget.menuItem == null ? 'Ajouter' : 'Mettre à jour',
                    ),
                  );
                },
              ),
              cancelButton: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picker = ImagePicker();
          final file = await picker.pickImage(source: ImageSource.gallery);
          if (file != null) {
            controller.setFilePicked = file;
          }
        },
        child: const Icon(Icons.image),
      ),
    );
  }
}
