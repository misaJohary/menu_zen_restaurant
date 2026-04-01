import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:menu_zen_restaurant/core/extensions/list_extension.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/menus_controller.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/bloc_status.dart';
import '../../domains/entities/menu_entity.dart';
import '../managers/auths/auth_bloc.dart';
import '../managers/languages/languages_bloc.dart';
import '../managers/menus/menus_bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/logo.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: kspacing * 4,
            vertical: kspacing * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuHeader(
                onAddPressed: () {
                  _showAddEditDialog();
                },
              ),
              const SizedBox(height: kspacing * 4),
              Expanded(
                child: BlocBuilder<MenusBloc, MenusState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case BlocStatus.loading:
                        return const LoadingWidget();
                      case BlocStatus.loaded:
                        if (state.menus.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Aucun menu disponible',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: kspacing * 2),
                                ElevatedButton(
                                  onPressed: _showAddEditDialog,
                                  child: const Text(
                                    'Ajouter votre premier menu',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: kspacing * 4,
                                mainAxisSpacing: kspacing * 4,
                              ),
                          itemCount: state.menus.length,
                          itemBuilder: (context, index) {
                            final menu = state.menus[index];
                            return _MenuCard(
                              menu: menu,
                              onEdit: () => _showAddEditDialog(menu: menu),
                              onToggleActive: (value) {
                                controller.addUpdateEvent(
                                  menu.copyWith(active: value),
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
                        return const LoadingWidget();
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

  void _showAddEditDialog({MenuEntity? menu}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _AddEditMenuDialog(controller: controller, menu: menu),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _MenuHeader({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Row(
          children: [
            if (authState.userRestaurant != null)
              Logo(imageUrl: authState.userRestaurant!.restaurant.logo)
            else
              const SizedBox(height: 40),
            const SizedBox(width: kspacing * 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion de menus',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Géré le menu de ton restaurant',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: grey),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('AJOUTER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: kspacing * 2),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String? profileUrl;
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: null,
                  child: const Icon(Icons.person),
                );
              },
            ),
            const SizedBox(width: kspacing * 2),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, color: grey),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: kspacing * 2),
            _LanguageSelector(),
          ],
        );
      },
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguagesBloc, LanguagesState>(
      builder: (context, state) {
        final selectedLang = state.selectedLanguage;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedLang?.code == 'fr')
                const Text('🇫🇷 ', style: TextStyle(fontSize: 16)),
              if (selectedLang?.code == 'en')
                const Text('🇺🇸 ', style: TextStyle(fontSize: 16)),
              if (selectedLang?.code == 'zh')
                const Text('🇨🇳 ', style: TextStyle(fontSize: 16)),
              Text(
                selectedLang?.name ?? 'French',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 14, color: Color(0xFF81C784)),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuCard extends StatelessWidget {
  final MenuEntity menu;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggleActive;

  const _MenuCard({
    required this.menu,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguagesBloc, LanguagesState>(
      builder: (context, langState) {
        final selectedLang = langState.selectedLanguage?.code ?? 'en';
        final name = menu.translations.getField(selectedLang, (t) => t.name);
        final description =
            menu.translations.getOptionalField(
              selectedLang,
              (t) => t.description,
            ) ??
            '';

        return Container(
          padding: const EdgeInsets.all(kspacing * 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit, color: primaryColor, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(color: grey, fontSize: 13, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: kspacing * 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (menu.active ?? false)
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (menu.active ?? false) ? 'Menu actif' : 'Menu non actif',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Activé',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: menu.active ?? false,
                    onChanged: onToggleActive,
                    activeThumbColor: primaryColor,
                    activeTrackColor: primaryColor.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddEditMenuDialog extends StatefulWidget {
  final MenusController controller;
  final MenuEntity? menu;

  const _AddEditMenuDialog({required this.controller, this.menu});

  @override
  State<_AddEditMenuDialog> createState() => _AddEditMenuDialogState();
}

class _AddEditMenuDialogState extends State<_AddEditMenuDialog> {
  final Map<String, Map<String, String>> _translations = {};
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  String _selectedLangCode = 'fr';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      _isActive = widget.menu!.active ?? true;
      for (var t in widget.menu!.translations) {
        _translations[t.languageCode] = {
          'name': t.name,
          'description': t.description ?? '',
        };
        _nameControllers[t.languageCode] = TextEditingController(text: t.name);
        _descriptionControllers[t.languageCode] = TextEditingController(
          text: t.description ?? '',
        );
      }
    }
    context.read<LanguagesBloc>().add(LanguagesFetched());
  }

  @override
  void dispose() {
    for (var c in _nameControllers.values) {
      c.dispose();
    }
    for (var c in _descriptionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getNameController(String langCode) {
    if (!_nameControllers.containsKey(langCode)) {
      _nameControllers[langCode] = TextEditingController(
        text: _translations[langCode]?['name'] ?? '',
      );
    }
    return _nameControllers[langCode]!;
  }

  TextEditingController _getDescriptionController(String langCode) {
    if (!_descriptionControllers.containsKey(langCode)) {
      _descriptionControllers[langCode] = TextEditingController(
        text: _translations[langCode]?['description'] ?? '',
      );
    }
    return _descriptionControllers[langCode]!;
  }

  void _save() {
    // Collect all translations from controllers
    for (var entry in _nameControllers.entries) {
      _translations[entry.key] ??= {};
      _translations[entry.key]!['name'] = entry.value.text;
    }
    for (var entry in _descriptionControllers.entries) {
      _translations[entry.key] ??= {};
      _translations[entry.key]!['description'] = entry.value.text;
    }

    final name = _translations[_selectedLangCode]?['name'] ?? '';
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du menu est requis')),
      );
      return;
    }

    final modelJson = {
      'active': _isActive,
      'translations': _translations.entries
          .map(
            (e) => {
              'language_code': e.key,
              'name': e.value['name'] ?? '',
              'description': e.value['description'] ?? '',
            },
          )
          .toList(),
    };

    if (widget.menu != null) {
      modelJson['id'] = widget.menu!.id!;
      widget.controller.addUpdateEvent(
        widget.controller.createModelFromJson(modelJson),
      );
    } else {
      widget.controller.addCreateEvent(
        widget.controller.createModelFromJson(modelJson),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(kspacing * 4),
        constraints: const BoxConstraints(maxWidth: 550),
        child: BlocBuilder<LanguagesBloc, LanguagesState>(
          builder: (context, langState) {
            final languages = langState.languages;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.menu == null
                          ? 'Ajouter un menu'
                          : 'Modifier un menu',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B61FF), // Purple from image
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Color(0xFF81C784)),
                        iconSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kspacing),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: kspacing * 3),
                const Text(
                  'Traduire :',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: kspacing * 1.5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: languages.map((lang) {
                      final isSelected = _selectedLangCode == lang.code;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedLangCode = lang.code),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang.code == 'fr'
                                      ? '🇫🇷'
                                      : lang.code == 'en'
                                      ? '🇺🇸'
                                      : '🇨🇳',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.black87
                                        : Colors.black54,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Color(0xFF81C784),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: kspacing * 3),
                const Text(
                  'Nom de menu',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _getNameController(_selectedLangCode),
                  decoration: InputDecoration(
                    hintText: 'Tend M',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: kspacing * 2.5),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _getDescriptionController(_selectedLangCode),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Description...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: kspacing * 2.5),
                Row(
                  children: [
                    const Text(
                      'Menu actif',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                      activeThumbColor: primaryColor,
                      activeTrackColor: primaryColor.withOpacity(0.3),
                    ),
                  ],
                ),
                const SizedBox(height: kspacing * 4),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F8E9),
                          foregroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: const Text(
                          'ANNULER',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: kspacing * 3),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, // Solid green
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          widget.menu == null ? 'AJOUTER' : 'MODIFIER',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
