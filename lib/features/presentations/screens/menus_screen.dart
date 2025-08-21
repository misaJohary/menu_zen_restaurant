import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menus_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/add_item_widget.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../domains/entities/menu_entity.dart';
import '../managers/menus/menus_bloc.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/card_list_tile.dart';
import '../widgets/edit_delete_icon.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

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
                            return Center(child: CircularProgressIndicator());
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
                                return CardListTile(
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        menu.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      Transform.scale(
                                        scale: .6,
                                        child: Switch(
                                          value: menu.isActive!,
                                          onChanged: (bool value) {
                                            controller.addUpdateEvent(
                                              menu.copyWith(isActive: value),
                                            );
                                          },
                                        ),
                                      ),
                                      Text(
                                        'Actif',
                                        style: TextStyle(
                                          color: menu.isActive!
                                              ? Theme.of(context).primaryColor
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(menu.description),
                                  trailing: EditDeleteIcon(
                                    onEdit: () async {
                                      controller.showField(false);
                                      await Future.delayed(
                                          resetFieldDuration
                                      );
                                      controller.showField(true, entity: menu);
                                    },
                                    onDelete: () {
                                      _showDeleteConfirmation(
                                        menu,
                                        () {
                                          controller.showField(false);
                                          final id = menu.id;
                                          if (id != null) {
                                            controller.addDeleteEvent(id);
                                            // context.read<MenusBloc>().add(
                                            //   MenusDeleted(id),
                                            // );
                                          }
                                        },
                                      );
                                    },
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
  void _showDeleteConfirmation(MenuEntity menu, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le menu "${menu.name}" ?'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Supprimer'),
          ),
        ],
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initEdit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AddItemWidget(
      formKey: widget.controller.formKey,
      title: widget.controller.isEditMode
          ? "Modifier un menu"
          : "Ajouter un menu",
      cancelButton: widget.cancelButton,
      confirmationButton: BlocBuilder<MenusBloc, MenusState>(
        builder: (context, state) {
          switch (state.editStatus) {
            case BlocStatus.loading:
              return Center(child: CircularProgressIndicator());
            case BlocStatus.failed:
              return ElevatedButton(
                onPressed: widget.controller.validate,
                child: const Text("Réessayer"),
              );
            default:
              return ElevatedButton(
                onPressed: widget.controller.validate,
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
        FormBuilderTextField(
          name: 'name',
          decoration: InputDecoration(label: Text("Nom du Menu")),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
        FormBuilderTextField(
          name: 'description',
          maxLines: 5,
          decoration: InputDecoration(label: Text("Description")),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
        FormBuilderCheckbox(
          name: 'is_active',
          initialValue: true,
          title: Text("Menu Actif"),
        ),
      ],
    );
  }
}
