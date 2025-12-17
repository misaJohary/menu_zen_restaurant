import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menus_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/add_item_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../domains/entities/menu_entity.dart';
import '../managers/languages/languages_bloc.dart';
import '../managers/menus/menus_bloc.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/card_list_tile.dart';
import '../widgets/edit_delete_icon.dart';
import '../widgets/loading_widget.dart';
import '../widgets/multilingual_field.dart';

@RoutePage()
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late MenusController controller;

  @override
  void initState() {
    super.initState();
    controller = MenusController(context: context)..addFetchEvent();
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
              title: 'Gestion de Menus',
              description: 'Gère les menus de ton restaurant',
              labelButton: 'Ajouter Menu',
              onButtonPressed: () async {
                controller.showField(false);
                await Future.delayed(resetFieldDuration);
                controller.showField(true);
              },
            ),
            Expanded(
              child: BlocListener<MenusBloc, MenusState>(
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
                              ? AddMenuWidget(
                                  key: const ValueKey('add_menu_form'),
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
                    BlocBuilder<MenusBloc, MenusState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case BlocStatus.loading:
                            return LoadingWidget();
                          case BlocStatus.loaded:
                            if (state.menus.isEmpty) {
                              return AddMenuWidget(
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
                              itemCount: state.menus.length,
                              itemBuilder: (context, index) {
                                final menu = state.menus[index];
                                return BlocBuilder<
                                  LanguagesBloc,
                                  LanguagesState
                                >(
                                  builder: (context, langState) {
                                    final selectedLang =
                                        langState.selectedLanguage?.code ??
                                        'en';
                                    final menuName = menu.translations.getField(
                                      selectedLang,
                                      (t) => t.name,
                                    );
                                    final menuDescription =
                                        menu.translations.getOptionalField(
                                          selectedLang,
                                          (t) => t.description,
                                        ) ??
                                        '';

                                    return CardListTile(
                                      title: Row(
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
                                          Transform.scale(
                                            scale: .6,
                                            child: Switch(
                                              value: menu.active!,
                                              onChanged: (bool value) {
                                                controller.addUpdateEvent(
                                                  menu.copyWith(
                                                    active: value,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Text(
                                            'Actif',
                                            style: TextStyle(
                                              color: menu.active!
                                                  ? Theme.of(
                                                      context,
                                                    ).primaryColor
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        menuDescription,
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
                                          await Future.delayed(
                                            resetFieldDuration,
                                          );
                                          controller.showField(
                                            true,
                                            entity: menu,
                                          );
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

  void _showDeleteConfirmation(MenuEntity menu, VoidCallback onConfirm) {
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
              'Êtes-vous sûr de vouloir supprimer le menu "$menuName" ?',
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

class AddMenuWidget extends StatefulWidget {
  const AddMenuWidget({
    super.key,
    required this.cancelButton,
    required this.controller,
  });

  final Widget cancelButton;
  final MenusController controller;

  @override
  State<AddMenuWidget> createState() => _AddMenuWidgetState();
}

class _AddMenuWidgetState extends State<AddMenuWidget> {
  final GlobalKey<State<AddItemWidget>> _addItemWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initEdit();

      final currentModel = widget.controller.currentModel;
      if (currentModel != null) {
        final formState = widget.controller.formKey.currentState;
        if (formState is FormBuilderState) {
          formState.patchValue({
            'is_active': currentModel.active ?? true,
          });
        }
      }
    });
  }

  Map<String, Map<String, String>>? get translations {
    return AddItemWidget.getTranslations(_addItemWidgetKey);
  }

  /// Extract translations from MenuModel to Map format
  Map<String, Map<String, String>>? _getInitialTranslations() {
    if (!widget.controller.isEditMode || widget.controller.currentModel == null) {
      return null;
    }
    
    // Get the model - MenuModel extends MenuEntity and has translations
    final menuModel = widget.controller.currentModel!;
    if (menuModel.translations.isEmpty) {
      return null;
    }
    
    // Convert List<MenuTranslationModel> to Map<String, Map<String, String>>
    final Map<String, Map<String, String>> translationsMap = {};
    for (var translation in menuModel.translations) {
      translationsMap[translation.languageCode] = {
        'name': translation.name,
        if (translation.description != null) 'description': translation.description!,
      };
    }
    
    return translationsMap;
  }

  void _handleValidation() {
    final translationsData = translations;

    // Debug: Print translations
    print('Translations collected: $translationsData');

    // Call the new validateWithTranslations method
    widget.controller.validateWithTranslations(translationsData);
  }

  @override
  Widget build(BuildContext context) {
    return AddItemWidget(
      key: _addItemWidgetKey,
      formKey: widget.controller.formKey,
      title: widget.controller.isEditMode
          ? "Modifier un menu"
          : "Ajouter un menu",
      cancelButton: widget.cancelButton,
      initialTranslations: _getInitialTranslations(),
      multilingualFields: [
        MultilingualField(name: 'name', label: 'Nom du Menu', maxLines: 1),
        MultilingualField(
          name: 'description',
          label: 'Description',
          maxLines: 5,
        ),
      ],
      confirmationButton: BlocBuilder<MenusBloc, MenusState>(
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
        FormBuilderCheckbox(
          name: 'is_active',
          initialValue: true,
          title: Text("Menu Actif"),
        ),
      ],
    );
  }
}
