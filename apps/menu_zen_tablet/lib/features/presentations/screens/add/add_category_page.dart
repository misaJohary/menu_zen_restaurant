import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/category_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/categories/categories_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/add_item_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/multilingual_field.dart';

import '../../../../core/constants/constants.dart';
import 'package:domain/entities/category_entity.dart';
import '../../widgets/color_picker_widget.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key, this.category});

  final CategoryEntity? category;

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  late final CategoriesController controller;
  final GlobalKey<State<AddItemWidget>> _addItemWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = CategoriesController(context: context);
    controller.showField(true, entity: widget.category);
    controller.setThemeColor = widget.category?.themeColor;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initEdit();
    });
  }

  Map<String, Map<String, String>>? _getInitialTranslations() {
    final entity = widget.category;
    if (entity == null || entity.translations.isEmpty) return null;
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
    controller.validateWithTranslations(translations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null
              ? 'Ajouter une catégorie'
              : 'Modifier une catégorie',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kspacing * 2),
        child: AddItemWidget(
          key: _addItemWidgetKey,
          formKey: controller.formKey,
          title: widget.category == null
              ? 'Nouvelle Catégorie'
              : 'Éditer Catégorie',
          initialTranslations: _getInitialTranslations(),
          multilingualFields: const [
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
          formBuilderFields: [
            FormBuilderTextField(
              name: 'emoji',
              decoration: const InputDecoration(label: Text("🥣 Emoji")),
            ),
            const SizedBox(height: kspacing * 3),
            const Text("Thème de la Categorie"),
            const SizedBox(height: kspacing),
            SizedBox(
              height: 150,
              child: ColorPickerWidget(
                selectedColor: controller.themeColor,
                onColorSelected: (color) {
                  controller.setThemeColor = color;
                },
              ),
            ),
          ],
          confirmationButton: BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: _onSubmit,
                child: Text(
                  widget.category == null ? 'Ajouter' : 'Mettre à jour',
                ),
              );
            },
          ),
          cancelButton: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ),
      ),
    );
  }
}
