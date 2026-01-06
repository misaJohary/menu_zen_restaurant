import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_zen_restaurant/core/extensions/double_extension.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menu_item_controller.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../datasources/models/menu_item_update_model.dart';
import '../../domains/entities/menu_entity.dart';
import '../../domains/entities/menu_item_entity.dart';
import '../managers/categories/categories_bloc.dart';
import '../managers/languages/languages_bloc.dart';
import '../managers/menu_item/menu_item_bloc.dart';
import '../managers/menus/menus_bloc.dart';
import '../widgets/add_item_widget.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/card_list_tile.dart';
import '../widgets/category_name_widget.dart';
import '../widgets/edit_delete_icon.dart';
import '../widgets/loading_widget.dart';
import '../widgets/multilingual_field.dart';

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
              title: 'Gestion des items de menu',
              description: 'Gère les items de menu de ton restaurant',
              labelButton: 'Ajouter Item Menu',
              onButtonPressed: () async {
                controller.showField(false);
                await Future.delayed(resetFieldDuration);
                controller.showField(true);
              },
            ),
            //Card(child: Column(children: [Text('Filtrer par catégorie'), ])),
            Expanded(
              child: BlocListener<MenuItemBloc, MenuItemState>(
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
                              ? AddMenuItemWidget(
                                  key: const ValueKey('add_menu_item_form'),
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
                    BlocBuilder<MenuItemBloc, MenuItemState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case BlocStatus.loading:
                            return LoadingWidget();
                          case BlocStatus.loaded:
                            if (state.menuItems.isEmpty) {
                              return AddMenuItemWidget(
                                cancelButton: ElevatedButton(
                                  child: Text("Annuler"),

                                  onPressed: () {
                                    controller.showField(false);
                                  },
                                ),
                                controller: controller,
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.menuItems.length,
                              itemBuilder: (context, index) {
                                final menu = state.menuItems[index];
                                return CardListTile(
                                  leading: menu.picture != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                          child: CachedNetworkImage(
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                            imageUrl: menu.picture!,
                                          ),
                                        )
                                      : const CircleAvatar(
                                          child: Icon(Icons.fastfood),
                                        ),
                                  title: BlocBuilder<LanguagesBloc, LanguagesState>(
                                    builder: (context, langState) {
                                      final selectedLang =
                                          langState.selectedLanguage?.code ??
                                          'en';
                                      final menuName = menu.translations
                                          .getField(
                                            selectedLang,
                                            (t) => t.name,
                                          );
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            menuName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                  fontSize: 27,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            '  ${menu.price.formatMoney} Ar  ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          Transform.scale(
                                            scale: .6,
                                            child: Switch(
                                              value: menu.active ?? true,
                                              onChanged: (bool value) {
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
                                          Text(
                                            'Disponible',
                                            style: TextStyle(
                                              color: menu.active ?? true
                                                  ? Theme.of(
                                                      context,
                                                    ).primaryColor
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  subtitle:
                                      BlocBuilder<
                                        LanguagesBloc,
                                        LanguagesState
                                      >(
                                        builder: (context, langState) {
                                          final selectedLang =
                                              langState
                                                  .selectedLanguage
                                                  ?.code ??
                                              'en';
                                          final menuDescription =
                                              menu.translations
                                                  .getOptionalField(
                                                    selectedLang,
                                                    (t) => t.description,
                                                  ) ??
                                              '';

                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                menuDescription,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color: grey,
                                                      fontSize: 22,
                                                    ),
                                              ),
                                              SizedBox(height: kspacing * 2),
                                              Row(
                                                children: [
                                                  if (menu.category != null)
                                                    CategoryNameWidget(
                                                      menu.category!,
                                                      padding: EdgeInsets.all(
                                                        kspacing,
                                                      ),
                                                      height: 43,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                            color: darken(
                                                              menu
                                                                  .category!
                                                                  .themeColor!,
                                                              .5,
                                                            ),
                                                          ),
                                                    ),
                                                  SizedBox(width: kspacing * 3),
                                                  ...menu.menus.map((
                                                    menuEntity,
                                                  ) {
                                                    final menuName = menuEntity
                                                        .translations
                                                        .getField(
                                                          selectedLang,
                                                          (t) => t.name,
                                                        );
                                                    return Text(
                                                      'Menus: $menuName',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium!
                                                          .copyWith(
                                                            color: grey,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  trailing: EditDeleteIcon(
                                    isVertical: false,
                                    onEdit: () async {
                                      controller.showField(false);
                                      await Future.delayed(resetFieldDuration);
                                      controller.showField(true, entity: menu);
                                    },
                                    // onDelete: () {
                                    //   _showDeleteConfirmation(menu, () {
                                    //     controller.showField(false);
                                    //     final id = menu.id;
                                    //     if (id != null) {
                                    //       controller.addDeleteEvent(id);
                                    //       // context.read<MenusBloc>().add(
                                    //       //   MenusDeleted(id),
                                    //       // );
                                    //     }
                                    //   });
                                    // },
                                  ),
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

  void _showDeleteConfirmation(MenuItemEntity menu, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<LanguagesBloc, LanguagesState>(
        builder: (context, langState) {
          final selectedLang = langState.selectedLanguage?.code ?? 'en';
          final menuName = menu.translations.getField(
            selectedLang,
            (t) => t.name,
          );

          return AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer la menu "$menuName" ?',
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

class AddMenuItemWidget extends StatefulWidget {
  const AddMenuItemWidget({
    super.key,
    required this.cancelButton,
    required this.controller,
  });

  final Widget cancelButton;
  final MenuItemController controller;

  @override
  State<AddMenuItemWidget> createState() => _AddMenuItemWidgetState();
}

class _AddMenuItemWidgetState extends State<AddMenuItemWidget> {
  final GlobalKey<State<AddItemWidget>> _addItemWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initEdit();

      // Patch additional non-multilingual fields when editing
      final currentModel = widget.controller.currentModel;
      if (currentModel != null) {
        void patchWithAvailableReferences() {
          final formState = widget.controller.formKey.currentState;
          if (formState is! FormBuilderState) return;

          // Try to resolve category and menus against current bloc states,
          // so Dropdown/Chips find the exact same instances
          final categoriesState = context.read<CategoriesBloc>().state;
          final menusState = context.read<MenusBloc>().state;

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
          final menusToPatch = resolvedMenus.isNotEmpty
              ? resolvedMenus
              : currentModel.menus;

          formState.patchValue({
            'price': currentModel.price.toString(),
            'category': resolvedCategory,
            'menus': menusToPatch,
          });
        }

        // If blocs already have data, patch immediately; else, trigger fetch and patch later
        final categoriesLoaded = context
            .read<CategoriesBloc>()
            .state
            .categories
            .isNotEmpty;
        final menusLoaded = context.read<MenusBloc>().state.menus.isNotEmpty;
        if (!categoriesLoaded) {
          context.read<CategoriesBloc>().add(CategoriesFetched());
        }
        if (!menusLoaded) {
          context.read<MenusBloc>().add(MenusFetched());
        }

        // First attempt
        patchWithAvailableReferences();
        // Schedule another attempt next frame to catch freshly loaded bloc data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          patchWithAvailableReferences();
        });
      }
    });
  }

  Map<String, Map<String, String>>? get translations {
    return AddItemWidget.getTranslations(_addItemWidgetKey);
  }

  /// Extract translations from MenuItemModel to Map format
  Map<String, Map<String, String>>? _getInitialTranslations() {
    if (!widget.controller.isEditMode ||
        widget.controller.currentModel == null) {
      return null;
    }

    // Get the model - MenuItemModel extends MenuItemEntity and has translations
    final menuItemModel = widget.controller.currentModel!;
    if (menuItemModel.translations.isEmpty) {
      return null;
    }

    // Convert List<MenuItemTranslationModel> to Map<String, Map<String, String>>
    final Map<String, Map<String, String>> translationsMap = {};
    for (var translation in menuItemModel.translations) {
      translationsMap[translation.languageCode] = {
        'name': translation.name,
        if (translation.description != null)
          'description': translation.description!,
      };
    }

    return translationsMap;
  }

  void _handleValidation() {
    final translationsData = translations;
    widget.controller.validateWithTranslations(translationsData);
  }

  @override
  Widget build(BuildContext context) {
    return AddItemWidget(
      key: _addItemWidgetKey,
      formKey: widget.controller.formKey,
      title: widget.controller.isEditMode
          ? "Modifier un menu item"
          : "Ajouter un menu item",
      cancelButton: widget.cancelButton,
      initialTranslations: _getInitialTranslations(),
      multilingualFields: [
        MultilingualField(name: 'name', label: "Nom de l'item", maxLines: 1),
        MultilingualField(
          name: 'description',
          label: 'Description',
          maxLines: 2,
        ),
      ],
      confirmationButton: BlocBuilder<MenuItemBloc, MenuItemState>(
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
                      ? "Modifier Menu"
                      : "Ajouter Menu",
                ),
              );
          }
        },
      ),
      formBuilderFields: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListenableBuilder(
            listenable: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return widget.controller.filePicked != null
                  ? Stack(
                      children: [
                        BlocBuilder<MenuItemBloc, MenuItemState>(
                          builder: (context, state) {
                            switch (state.uploadStatus) {
                              case BlocStatus.init:
                                return SizedBox.shrink();
                              case BlocStatus.loading:
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              case BlocStatus.loaded:
                                return Center(child: Text('goood'));
                              case BlocStatus.failed:
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Erreur lors du téléchargement de l\'image',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      SizedBox(height: kspacing),
                                      ElevatedButton(
                                        onPressed: () {
                                          widget.controller.setFilePicked =
                                              widget.controller.filePicked;
                                        },
                                        child: Text('Réessayer'),
                                      ),
                                    ],
                                  ),
                                );
                            }
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (kIsWeb)
                              ? Image.network(
                                  widget.controller.filePicked!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(widget.controller.filePicked!.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: Icon(Icons.photo_camera),
                      onPressed: () async {
                        showModalBottomSheet<XFile?>(
                          context: context,
                          builder: (context) {
                            final ImagePicker picker = ImagePicker();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: IconButton(
                                    onPressed: () async {
                                      final file = await picker.pickImage(
                                        source: ImageSource.camera,
                                      );
                                      if (file != null) {
                                        widget.controller.setFilePicked = file;
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: Icon(Icons.camera),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    onPressed: () async {
                                      final file = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (file != null) {
                                        widget.controller.setFilePicked = file;
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: Icon(Icons.folder),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
            },
          ),
        ),
        FormBuilderTextField(
          name: 'price',
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.numeric(),
          valueTransformer: (text) {
            return text == null || text.isEmpty ? null : double.tryParse(text);
          },
          decoration: InputDecoration(label: Text("Prix (Ar)")),
        ),
        BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            return BlocBuilder<LanguagesBloc, LanguagesState>(
              builder: (context, langState) {
                final selectedLang = langState.selectedLanguage?.code ?? 'en';
                return FormBuilderDropdown(
                  name: 'category',
                  hint: Text("Sélectionner une catégorie"),
                  items: state.categories.map((category) {
                    final categoryName = category.translations.getField(
                      selectedLang,
                      (t) => t.name,
                    );
                    return DropdownMenuItem(
                      value: category,
                      child: Text(categoryName),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
        BlocBuilder<MenusBloc, MenusState>(
          builder: (context, state) {
            return BlocBuilder<LanguagesBloc, LanguagesState>(
              builder: (context, langState) {
                final selectedLang = langState.selectedLanguage?.code ?? 'en';
                return FormBuilderFilterChips<MenuEntity>(
                  name: 'menus',
                  spacing: 8,
                  decoration: InputDecoration(
                    label: Text("Disponible dans les menus"),
                  ),
                  options: state.menus.map((menu) {
                    final menuName = menu.translations.getField(
                      selectedLang,
                      (t) => t.name,
                    );
                    return FormBuilderChipOption(
                      value: menu,
                      child: Text(menuName),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
        SizedBox(height: kspacing * 3),
      ],
    );
  }
}
