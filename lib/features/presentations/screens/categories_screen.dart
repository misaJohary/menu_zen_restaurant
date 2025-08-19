import 'package:auto_route/annotations.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../domains/entities/category_entity.dart';
import '../controllers/category_controller.dart';
import '../managers/categories/categories_bloc.dart';
import '../widgets/add_item_widget.dart';
import '../widgets/board_title_widget.dart';
import '../widgets/card_list_tile.dart';
import '../widgets/color_picker_widget.dart';
import '../widgets/edit_delete_icon.dart';
import '../widgets/emoji_keyboard_textfield.dart';

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
              title: 'Gestion de la Categorie des plats',
              description: 'Gère les categories des plats de ton restaurant',
              labelButton: 'Ajouter une Categorie',
              onButtonPressed: () async {
                controller.showField(false);
                await Future.delayed(resetFieldDuration);
                controller..showField(true)..resetThemeColor;
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
                            return Center(child: CircularProgressIndicator());
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
                                    crossAxisCount: 3, // 4 items per row
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio:
                                        2, // makes them look like rectangles
                                  ),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.categories.length,
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                return CardListTile(
                                  title: Container(
                                    padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: category.themeColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      category.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  ),
                                  subtitle: Text(category.description ?? ''),
                                  trailing: EditDeleteIcon(
                                    onEdit: () async {
                                      controller.showField(false);
                                      controller.setThemeColor =
                                          category.themeColor;
                                      await Future.delayed(resetFieldDuration);
                                      controller.showField(
                                        true,
                                        entity: category,
                                      );
                                    },
                                    onDelete: () {
                                      _showDeleteConfirmation(category, () {
                                        controller.showField(false);
                                        final id = category.id;
                                        if (id != null) {
                                          controller.addDeleteEvent(id);
                                        }
                                      });
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

  void _showDeleteConfirmation(CategoryEntity menu, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le menu "${menu.name}" ?',
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
          ? "Modifier une categorie"
          : "Ajouter une categorie",
      cancelButton: widget.cancelButton,
      confirmationButton: BlocBuilder<CategoriesBloc, CategoriesState>(
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
                      ? "Modifier la Categorie"
                      : "Ajouter une Categorie",
                ),
              );
          }
        },
      ),
      formBuilderFields: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: FormBuilderTextField(
                name: 'emoji',
                decoration: InputDecoration(label: Text("🥣 Emoji")),
              ),
            ),
            SizedBox(width: kspacing * 3),
            Expanded(
              flex: 5,
              child: FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(label: Text("Nom de la Categorie")),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
            ),
          ],
        ),
        FormBuilderTextField(
          name: 'description',
          decoration: InputDecoration(label: Text("Description")),
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
