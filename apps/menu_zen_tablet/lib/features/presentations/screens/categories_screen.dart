import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:menu_zen_restaurant/core/enums/bloc_status.dart';
import 'package:domain/entities/category_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/category_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/categories/categories_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/category_card.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/category_dialog.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/loading_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/screen_header_widget.dart';
import 'package:design_system/design_system.dart';

@RoutePage()
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoriesController controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = CategoriesController(context: context)..addFetchEvent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryDialog({CategoryEntity? category}) {
    if (category != null) {
      controller.showField(true, entity: category);
    } else {
      controller.resetThemeColor;
      controller.showField(true);
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          CategoryDialog(controller: controller, category: category),
    ).then((_) {
      // Potentially reset fields if canceled
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF1F8E9,
      ), // Light green background from mockup
      body: BlocListener<CategoriesBloc, CategoriesState>(
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
                title: 'Gestion des catégories',
                description: 'Gérer les catégories de tes plats',
                onAddPressed: _showCategoryDialog,
                searchController: _searchController,
              ),
              const SizedBox(height: kspacing * 6),
              Expanded(
                child: BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.loading:
                        return const LoadingWidget();
                      case BlocStatus.loaded:
                        if (state.categories.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Aucune catégorie trouvée."),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _showCategoryDialog(),
                                  child: const Text("Ajouter une catégorie"),
                                ),
                              ],
                            ),
                          );
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isPortrait = constraints.maxWidth < 600;
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isPortrait ? 2 : 3,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    childAspectRatio: 1.5,
                                  ),
                              itemCount: state.categories.length,
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                return StaggeredFadeIn(
                                  index: index,
                                  child: HoverScaleCard(
                                    child: CategoryCard(
                                      category: category,
                                      onEdit: () => _showCategoryDialog(
                                        category: category,
                                      ),
                                    ),
                                  ),
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
