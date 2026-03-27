import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/menu_item_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menu_item_controller.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/categories/categories_bloc.dart';
import 'package:menu_zen_restaurant/features/presentations/managers/menus/menus_bloc.dart';

import '../../domains/entities/category_entity.dart';

class MenuItemDialog extends StatefulWidget {
  const MenuItemDialog({super.key, required this.controller, this.menuItem});

  final MenuItemController controller;
  final MenuItemEntity? menuItem;

  @override
  State<MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends State<MenuItemDialog> {
  late final GlobalKey<FormBuilderState> _formKey;
  final Map<String, Map<String, String>> _translations = {};
  String _selectedLanguage = 'fr';

  final List<Map<String, String>> _languages = [
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ch', 'name': 'Chinese', 'flag': '🇨🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _formKey = widget.controller.formKey;

    // Initialize translations
    for (var lang in _languages) {
      _translations[lang['code']!] = {'name': '', 'description': ''};
    }

    if (widget.menuItem != null) {
      for (var translation in widget.menuItem!.translations) {
        _translations[translation.languageCode] = {
          'name': translation.name,
          'description': translation.description ?? '',
        };
      }

      // Initialize controller with editing data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.showField(true, entity: widget.menuItem);
        // Note: we don't call widget.controller.initEdit() because it would
        // use JSON maps which doesn't work well with entities in dropdowns/chips
        _patchNonMultilingualFields();
      });
    } else {
      widget.controller.showField(true);
      widget.controller.initEdit(); // Reset
    }
  }

  void _patchNonMultilingualFields() {
    if (widget.menuItem == null) return;
    final currentState = _formKey.currentState;
    if (currentState == null) return;

    final categoriesState = context.read<CategoriesBloc>().state;
    final categoryId = widget.menuItem?.category?.id;
    final resolvedCategory = categoryId != null
        ? categoriesState.categories.cast<CategoryEntity?>().firstWhere(
              (c) => c?.id == categoryId,
              orElse: () => null,
            )
        : null;

    final menusState = context
        .read<MenusBloc>()
        .state;
    final desiredMenuIds =
        widget.menuItem?.menus.map((m) => m.id).toSet() ?? {};
    final resolvedMenus = menusState.menus
        .where((m) => desiredMenuIds.contains(m.id))
        .toList();

    _formKey.currentState?.patchValue({
      'price': widget.menuItem!.price.toString(),
      'category': resolvedCategory,
      'menus': resolvedMenus,
    });
  }

  void _saveTranslations() {
    final currentState = _formKey.currentState;
    if (currentState != null) {
      currentState.save();
      final name = currentState.fields['name']?.value ?? '';
      final description = currentState.fields['description']?.value ?? '';
      _translations[_selectedLanguage] = {
        'name': name,
        'description': description,
      };
    }
  }

  void _save() {
    _saveTranslations();
    widget.controller.validateWithTranslations(_translations);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 650,
        constraints: BoxConstraints(
          maxHeight: MediaQuery
              .of(context)
              .size
              .height * 0.9,
        ),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.menuItem == null
                          ? "Ajouter une item de menu"
                          : "Modifier une item de menu",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF7B5CAB), // Purple from mockup
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF91C14F).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF91C14F),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 24),

                const Text(
                  "Traduire :",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _languages.map((lang) {
                    final isSelected = _selectedLanguage == lang['code'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _saveTranslations();
                          _selectedLanguage = lang['code']!;
                          _formKey.currentState?.fields['name']?.didChange(
                            _translations[_selectedLanguage]?['name'] ?? '',
                          );
                          _formKey.currentState?.fields['description']
                              ?.didChange(
                            _translations[_selectedLanguage]?['description'] ??
                                '',
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF91C14F)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              lang['flag']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(lang['name']!),
                            if (isSelected) const SizedBox(width: 8),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: Color(0xFF91C14F),
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Nom de l'item",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'name',
                  initialValue: _translations[_selectedLanguage]?['name'] ?? '',
                  decoration: InputDecoration(
                    hintText: "ex: Pizza Royale",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'description',
                  initialValue:
                  _translations[_selectedLanguage]?['description'] ?? '',
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Description....",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Image Picker with dashed border
                ListenableBuilder(
                  listenable: widget.controller,
                  builder: (context, _) {
                    final hasImage =
                        widget.controller.filePicked != null ||
                            widget.menuItem?.picture != null;
                    return DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                           radius: const Radius.circular(12),
                      dashPattern: const [6, 4],
                      color: Colors.grey.shade400,),

                    child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                    onTap: _pickImage,
                    child: Stack(
                    alignment: Alignment.center,
                    children: [
                    if (widget.controller.filePicked != null)
                    ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                    ? Image.network(
                    widget.controller.filePicked!.path,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    )
                        : Image.file(
                    File(
                    widget.controller.filePicked!.path,
                    ),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    ),
                    )
                    else if (widget.menuItem?.picture != null)
                    ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                    widget.menuItem!.picture!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    ),
                    ),
                    Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    if (!hasImage)
                    const Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.grey,
                    ),
                    if (!hasImage) const SizedBox(height: 12),
                    if (!hasImage)
                    const Text(
                    "Veuillez choisir une image en JPG, \nJPEG ou PNG, Max 5 Mo",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    ),
                    ),
                    if (!hasImage) const SizedBox(height: 16),
                    Container(
                    padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                    ),
                    decoration: BoxDecoration(
                    border: Border.all(
                    color: const Color(0xFF91C14F),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                    "Ajouter",
                    style: TextStyle(
                    color: Color(0xFF91C14F),
                    fontWeight: FontWeight.w600,
                    ),
                    ),
                    ),
                    ],
                    ),
                    ],
                    ),
                    ),
                    ),
                    );
                    },
                ),
                const SizedBox(height: 24),

                const Text(
                  "Prix (Ar)",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'price',
                  initialValue: widget.menuItem?.price.toString(),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.required(),
                  decoration: InputDecoration(
                    hintText: "ex: 15000",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Catégorie",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, categoriesState) {
                    return FormBuilderDropdown<dynamic>(
                      name: 'category',
                      decoration: InputDecoration(
                        hintText: "Sélectionner une catégorie",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: categoriesState.categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category.translations.getField(
                              _selectedLanguage,
                                  (t) => t.name,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                const Text(
                  "Disponible dans les menus",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                BlocBuilder<MenusBloc, MenusState>(
                  builder: (context, menusState) {
                    return FormBuilderFilterChips<MenuEntity>(
                      name: 'menus',
                      spacing: 8,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      options: menusState.menus.map((menu) {
                        return FormBuilderChipOption(
                          value: menu,
                          child: Text(
                            menu.translations.getField(
                              _selectedLanguage,
                                  (t) => t.name,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF7E3),
                          foregroundColor: const Color(0xFF91C14F),
                          elevation: 0,
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          "ANNULER",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF91C14F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          widget.menuItem == null ? "AJOUTER" : "MODIFIER",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) =>
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Appareil photo"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Galerie"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
    );

    if (source != null) {
      final file = await picker.pickImage(source: source);
      if (file != null) {
        widget.controller.setFilePicked = file;
      }
    }
  }
}
