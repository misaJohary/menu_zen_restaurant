import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menus_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/menus/menus_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/add_item_widget.dart';
import 'package:menu_zen_restaurant/features/presentations/widgets/multilingual_field.dart';

import '../../../../core/constants/constants.dart';
import 'package:domain/entities/menu_entity.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({super.key, this.menu});

  final MenuEntity? menu;

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  late final MenusController controller;
  final GlobalKey<State<AddItemWidget>> _addItemWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = MenusController(context: context);
    controller.showField(true, entity: widget.menu);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initEdit();
    });
  }

  Map<String, Map<String, String>>? _getInitialTranslations() {
    final entity = widget.menu;
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
          widget.menu == null ? 'Ajouter un menu' : 'Modifier un menu',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kspacing * 2),
        child: AddItemWidget(
          key: _addItemWidgetKey,
          formKey: controller.formKey,
          title: widget.menu == null ? 'Nouveau Menu' : 'Éditer Menu',
          initialTranslations: _getInitialTranslations(),
          multilingualFields: const [
            MultilingualField(name: 'name', label: 'Nom du Menu', maxLines: 1),
            MultilingualField(
              name: 'description',
              label: 'Description',
              maxLines: 5,
            ),
          ],
          formBuilderFields: const [],
          confirmationButton: BlocBuilder<MenusBloc, MenusState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: _onSubmit,
                child: Text(widget.menu == null ? 'Ajouter' : 'Mettre à jour'),
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
