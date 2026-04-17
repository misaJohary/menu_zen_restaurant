import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:data/models/menu_item_update_model.dart';
import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menu_item_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/categories/categories_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/kitchens/kitchens_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/languages/languages_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/menu_item/menu_item_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/loading_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/menu_item_card_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/menu_item_dialog.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/screen_header_widget.dart';
import 'package:design_system/design_system.dart';

@RoutePage()
class MenuItemScreen extends StatefulWidget {
  const MenuItemScreen({super.key});

  @override
  State<MenuItemScreen> createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends State<MenuItemScreen> {
  late MenuItemController controller;

  @override
  void initState() {
    super.initState();
    controller = MenuItemController(context: context)..addFetchEvent();
    if (context.read<CategoriesBloc>().state.categories.isEmpty) {
      context.read<CategoriesBloc>().add(CategoriesFetched());
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _showMenuItemDialog({MenuItemEntity? menuItem}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          MenuItemDialog(controller: controller, menuItem: menuItem),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: BlocListener<MenuItemBloc, MenuItemState>(
        listenWhen: (previous, current) =>
            previous.editStatus != current.editStatus,
        listener: (context, state) {
          if (state.editStatus == BlocStatus.loaded) {
            controller.addFetchEvent();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(kspacing * 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Gestion des items de menus',
                description: 'Géré les items de menu de ton restaurant',
                onAddPressed: _showMenuItemDialog,
                searchController: controller.searchController,
              ),
              const SizedBox(height: kspacing * 4),
              _CategoryFilterBar(controller: controller),
              const SizedBox(height: kspacing * 4),
              Expanded(
                child: BlocBuilder<MenuItemBloc, MenuItemState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.loading:
                        return const LoadingWidget();
                      case BlocStatus.loaded:
                        if (state.menuItems.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Aucun item de menu trouvé."),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _showMenuItemDialog(),
                                  child: const Text("Ajouter un item"),
                                ),
                              ],
                            ),
                          );
                        }
                        return BlocBuilder<LanguagesBloc, LanguagesState>(
                          builder: (context, langState) {
                            final selectedLang =
                                langState.selectedLanguage?.code ?? 'fr';
                            return ListenableBuilder(
                              listenable: Listenable.merge([
                                controller,
                                controller.searchController,
                              ]),
                              builder: (context, child) {
                                final query = controller.searchController.text
                                    .toLowerCase()
                                    .trim();
                                final selected =
                                    controller.selectedCategory;
                                final filtered = state.menuItems.where(
                                  (menu) {
                                    final matchesCategory =
                                        selected == null ||
                                        menu.category?.id == selected.id;
                                    final matchesSearch = query.isEmpty ||
                                        menu.translations.any(
                                          (t) => t.name
                                              .toLowerCase()
                                              .contains(query),
                                        );
                                    return matchesCategory && matchesSearch;
                                  },
                                ).toList();

                                if (filtered.isEmpty) {
                                  return const Center(
                                    child: Text('Aucun item trouvé'),
                                  );
                                }

                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isPortrait =
                                        constraints.maxWidth < 600;
                                    return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                isPortrait ? 2 : 3,
                                            crossAxisSpacing: 24,
                                            mainAxisSpacing: 24,
                                            childAspectRatio: 1.15,
                                          ),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final menu = filtered[index];
                                        final kitchenName =
                                            menu.kitchenId != null
                                            ? context
                                                  .read<KitchensBloc>()
                                                  .state
                                                  .kitchens
                                                  .where(
                                                    (k) =>
                                                        k.id == menu.kitchenId,
                                                  )
                                                  .firstOrNull
                                                  ?.name
                                            : null;
                                        return StaggeredFadeIn(
                                          index: index,
                                          child: HoverScaleCard(
                                            borderRadius: 24,
                                            child: MenuItemCardWidget(
                                              menuItem: menu,
                                              selectedLanguage: selectedLang,
                                              kitchenName: kitchenName,
                                              onEdit: () =>
                                                  _showMenuItemDialog(
                                                    menuItem: menu,
                                                  ),
                                              onStatusChanged: (bool value) {
                                                if (menu.active != value) {
                                                  context
                                                      .read<MenuItemBloc>()
                                                      .add(
                                                        MenuItemUpdated(
                                                          MenuItemUpdateModel(
                                                            id: menu.id!,
                                                            active: value,
                                                          ),
                                                        ),
                                                      );
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      case BlocStatus.failed:
                        return const Center(
                          child: Text("Erreur de chargement"),
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.controller});

  final MenuItemController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories,
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();
        return BlocBuilder<LanguagesBloc, LanguagesState>(
          builder: (context, langState) {
            final selectedLang = langState.selectedLanguage?.code ?? 'fr';
            return ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CustomChipChoice<String>(
                        label: 'Tout',
                        item: 'Tout',
                        selected: controller.selectedCategory == null,
                        onSelected: (_) => controller.selectCategory(null),
                      ),
                      ...state.categories.map((category) {
                        final name = category.translations.getField(
                          selectedLang,
                          (t) => t.name,
                        );
                        return CustomChipChoice<CategoryEntity>(
                          label: name,
                          item: category,
                          selected:
                              controller.selectedCategory?.id == category.id,
                          onSelected: controller.selectCategory,
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
