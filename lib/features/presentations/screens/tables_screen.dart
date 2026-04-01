import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/add_item_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../domains/entities/table_entity.dart';
import '../controllers/table_controller.dart';
import '../managers/auths/auth_bloc.dart';
import '../managers/menus/menus_bloc.dart';
import '../managers/tables/table_bloc.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/card_list_tile.dart';
import '../widgets/edit_delete_icon.dart';
import '../widgets/logo.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../widgets/loading_widget.dart';

@RoutePage()
class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  late TablesController controller;

  @override
  void initState() {
    super.initState();
    controller = TablesController(context: context)..addFetchEvent();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(kspacing * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                return Row(
                  children: [
                    if (authState.userRestaurant != null)
                      Logo(imageUrl: authState.userRestaurant!.restaurant.logo)
                    else
                      const SizedBox(height: 40),
                    const SizedBox(width: kspacing * 2),
                    Expanded(
                      child: BoardTitleWidget(
                        title: 'Gestion des Tables',
                        description: 'Gère les tables de ton restaurant',
                        labelButton: 'Ajouter Table',
                        contentPadding: EdgeInsets.zero,
                        onButtonPressed: () async {
                          controller.showField(false);
                          await Future.delayed(resetFieldDuration);
                          controller.showField(true);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocListener<TableBloc, TableState>(
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
                              ? AddTableWidget(
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
                    BlocBuilder<TableBloc, TableState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case BlocStatus.loading:
                            return LoadingWidget();
                          case BlocStatus.loaded:
                            if (state.tables.isEmpty) {
                              return AddTableWidget(
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
                              itemCount: state.tables.length,
                              itemBuilder: (context, index) {
                                final table = state.tables[index];
                                return CardListTile(
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        table.name,
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
                                          value: table.isActive,
                                          onChanged: (bool value) {
                                            controller.addUpdateEvent(
                                              table.copyWith(isActive: value),
                                            );
                                          },
                                        ),
                                      ),
                                      Text(
                                        'Actif',
                                        style: TextStyle(
                                          color: table.isActive
                                              ? Theme.of(context).primaryColor
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: EditDeleteIcon(
                                    onEdit: () async {
                                      controller.showField(false);
                                      await Future.delayed(resetFieldDuration);
                                      controller.showField(true, entity: table);
                                    },
                                    // onDelete: () {
                                    //   _showDeleteConfirmation(table, () {
                                    //     controller.showField(false);
                                    //     final id = table.id;
                                    //     if (id != null) {
                                    //       controller.addDeleteEvent(id);
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
                                'Erreur lors du chargement des tables',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          default:
                            return Center(
                              child: Text(
                                'Aucune table disponible',
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

  void _showDeleteConfirmation(TableEntity table, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la table "${table.name}" ?',
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
      ),
    );
  }
}

class AddTableWidget extends StatefulWidget {
  const AddTableWidget({
    super.key,
    required this.cancelButton,
    required this.controller,
  });

  final Widget cancelButton;
  final TablesController controller;

  @override
  State<AddTableWidget> createState() => _AddTableWidgetState();
}

class _AddTableWidgetState extends State<AddTableWidget> {
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
          ? "Modifier une table"
          : "Ajouter une table",
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
                      ? "Modifier Table"
                      : "Ajouter Table",
                ),
              );
          }
        },
      ),
      formBuilderFields: [
        FormBuilderTextField(
          name: 'name',
          decoration: InputDecoration(label: Text("Nom de la table")),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
        FormBuilderCheckbox(
          name: 'is_active',
          initialValue: true,
          title: Text("Table Actif"),
        ),
      ],
    );
  }
}
