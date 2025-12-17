import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../domains/entities/category_entity.dart';
import '../controllers/category_controller.dart';
import '../managers/categories/categories_bloc.dart';
import '../managers/languages/languages_bloc.dart';
import '../widgets/add_item_widget.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/card_list_tile.dart';
import '../widgets/category_name_widget.dart';
import '../widgets/color_picker_widget.dart';
import '../widgets/edit_delete_icon.dart';
import '../widgets/loading_widget.dart';
import '../widgets/multilingual_field.dart';

@RoutePage()
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoriesController controller;

  @override
  void initState() {
    super.initState();
    controller = CategoriesController(context: context)..addFetchEvent();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(kspacing * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoardTitleWidget(
              title: 'Gestion des Catégories',
              description: 'Gèrer les categories de tes plats',
              labelButton: 'Ajouter une Categorie',
              onButtonPressed: () async {
                controller.showField(false);
                await Future.delayed(resetFieldDuration);
                controller
                  ..showField(true)
                  ..resetThemeColor;
              },
            ),
            Expanded(
              child: BlocListener<CategoriesBloc, CategoriesState>(
                listenWhen: (previous, current) =>
                    previous.editStatus != current.editStatus,
                listener: (context, state) {
                  if (state.editStatus == BlocStatus.loaded) {
                    controller
                      ..showField(false)
                      ..addFetchEvent();
                  }
                },
                child: ListView(
                  children: [
                    ListenableBuilder(
                      listenable: controller,
                      builder: (context, child) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: controller.isFieldShown
                              ? AddCategoryWidget(
                                  key: const ValueKey('add_category_form'),
                                  controller: controller,
                                  cancelButton: ElevatedButton(
                                    child: Text("Annuler"),
                                    onPressed: () {
                                      controller.showField(false);
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      },
                    ),
                    BlocBuilder<CategoriesBloc, CategoriesState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case BlocStatus.loading:
                            return LoadingWidget();
                          case BlocStatus.loaded:
                            if (state.categories.isEmpty) {
                              return AddCategoryWidget(
                                cancelButton: ElevatedButton(
                                  child: Text("Annuler"),
                                  onPressed: () {
                                    controller.showField(false);
                                  },
                                ),
                                controller: controller,
                              );
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // 4 items per row
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio:
                                        1.8, // makes them look like rectangles
                                  ),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.categories.length,
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                return BlocBuilder<
                                  LanguagesBloc,
                                  LanguagesState
                                >(
                                  builder: (context, langState) {
                                    final selectedLang =
                                        langState.selectedLanguage?.code ??
                                        'en';
                                    final categoryDescription =
                                        category.translations.getOptionalField(
                                          selectedLang,
                                          (t) => t.description,
                                        ) ??
                                        '';

                                    return CardListTile(
                                      title: CategoryNameWidget(category),
                                      subtitle: Text(
                                        categoryDescription,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: grey,
                                              fontSize: 22,
                                            ),
                                      ),
                                      trailing: EditDeleteIcon(
                                        onEdit: () async {
                                          controller.showField(false);
                                          controller.setThemeColor =
                                              category.themeColor;
                                          await Future.delayed(
                                            resetFieldDuration,
                                          );
                                          controller.showField(
                                            true,
                                            entity: category,
                                          );
                                        },
                                        // onDelete: () {
                                        //   _showDeleteConfirmation(category, () {
                                        //     controller.showField(false);
                                        //     final id = category.id;
                                        //     if (id != null) {
                                        //       controller.addDeleteEvent(id);
                                        //     }
                                        //   });
                                        // },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          case BlocStatus.failed:
                            return Center(
                              child: Text(
                                'Erreur lors du chargement des menus',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          default:
                            return Center(
                              child: Text(
                                'Aucun menu disponible',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CategoryEntity menu, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<LanguagesBloc, LanguagesState>(
        builder: (context, langState) {
          final selectedLang = langState.selectedLanguage?.code ?? 'en';
          final categoryName = menu.translations.getField(
            selectedLang,
            (t) => t.name,
          );

          return AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer la catégorie "$categoryName" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddCategoryWidget extends StatefulWidget {
  const AddCategoryWidget({
    super.key,
    required this.cancelButton,
    required this.controller,
  });

  final Widget cancelButton;
  final CategoriesController controller;

  @override
  State<AddCategoryWidget> createState() => _AddMenuWidgetState();
}

class _AddMenuWidgetState extends State<AddCategoryWidget> {
  final GlobalKey<State<AddItemWidget>> _addItemWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initEdit();
    });
  }

  Map<String, Map<String, String>>? get translations {
    return AddItemWidget.getTranslations(_addItemWidgetKey);
  }

  /// Extract translations from CategoryModel to Map format
  Map<String, Map<String, String>>? _getInitialTranslations() {
    if (!widget.controller.isEditMode || widget.controller.currentModel == null) {
      return null;
    }
    
    // Get the model - CategoryModel extends CategoryEntity and has translations
    final categoryModel = widget.controller.currentModel!;
    if (categoryModel.translations.isEmpty) {
      return null;
    }
    
    // Convert List<CategoryTranslationModel> to Map<String, Map<String, String>>
    final Map<String, Map<String, String>> translationsMap = {};
    for (var translation in categoryModel.translations) {
      translationsMap[translation.languageCode] = {
        'name': translation.name,
        if (translation.description != null) 'description': translation.description!,
      };
    }
    
    return translationsMap;
  }

  void _handleValidation() {
    print('=== VALIDATION STARTED ===');
    print('Widget key current state: ${_addItemWidgetKey.currentState}');
    print('State type: ${_addItemWidgetKey.currentState.runtimeType}');

    final translationsData = translations;

    print('Translations retrieved via getter: $translationsData');

    // Also try direct access
    final state = _addItemWidgetKey.currentState;
    if (state is AddItemWidgetState) {
      print('Direct access to translations: ${state.translations}');
    } else {
      print('ERROR: State is not AddItemWidgetState!');
    }

    // Call the new validateWithTranslations method
    widget.controller.validateWithTranslations(translationsData);
  }

  @override
  Widget build(BuildContext context) {
    return AddItemWidget(
      key: _addItemWidgetKey,
      formKey: widget.controller.formKey,
      title: widget.controller.isEditMode
          ? "Modifier une categorie"
          : "Ajouter une categorie",
      cancelButton: widget.cancelButton,
      initialTranslations: _getInitialTranslations(),
      multilingualFields: [
        MultilingualField(
          name: 'name',
          label: 'Nom de la Categorie',
          maxLines: 1,
        ),
        MultilingualField(
          name: 'description',
          label: 'Description',
          maxLines: 3,
        ),
      ],
      confirmationButton: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          switch (state.editStatus) {
            case BlocStatus.loading:
              return Center(child: CircularProgressIndicator());
            case BlocStatus.failed:
              return ElevatedButton(
                onPressed: () {
                  _handleValidation();
                },
                child: const Text("Réessayer"),
              );
            default:
              return ElevatedButton(
                onPressed: () {
                  _handleValidation();
                },
                child: Text(
                  widget.controller.isEditMode
                      ? "Modifier la Categorie"
                      : "Ajouter une Categorie",
                ),
              );
          }
        },
      ),
      formBuilderFields: [
        FormBuilderTextField(
          name: 'emoji',
          decoration: InputDecoration(label: Text("🥣 Emoji")),
        ),
        SizedBox(height: kspacing * 3),
        Text("Thème de la Categorie"),
        SizedBox(height: kspacing),
        SizedBox(
          height: 150,
          child: ColorPickerWidget(
            selectedColor: widget.controller.themeColor,
            onColorSelected: (color) {
              widget.controller.setThemeColor = color;
            },
          ),
        ),
        SizedBox(height: kspacing * 2),
      ],
    );
  }
}
