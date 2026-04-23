import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:menu_zen_restaurant/core/constants/constants.dart';
import 'package:domain/entities/category_entity.dart';
import 'package:menu_zen_restaurant/features/presentations/controllers/category_controller.dart';

class CategoryDialog extends StatefulWidget {
  final CategoriesController controller;
  final CategoryEntity? category;

  const CategoryDialog({super.key, required this.controller, this.category});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late final GlobalKey<FormBuilderState> _formKey;
  final Map<String, Map<String, String>> _translations = {};
  String _selectedLanguage = 'fr';
  Color? _selectedColor;
  String _emoji = '🍕';

  final List<Map<String, String>> _languages = [
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ch', 'name': 'Chinese', 'flag': '🇨🇳'},
  ];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _formKey = widget.controller.formKey;
    _selectedColor = widget.category?.themeColor ?? _availableColors.first;

    // Initialize all supported languages with empty values
    for (var lang in _languages) {
      _translations[lang['code']!] = {'name': '', 'description': ''};
    }

    if (widget.category != null) {
      final regex = RegExp(
        r'^(\p{Emoji_Presentation}|\p{Emoji}\uFE0F)\s*',
        unicode: true,
      );

      for (var translation in widget.category!.translations) {
        String name = translation.name;
        final match = regex.firstMatch(name);
        if (match != null) {
          _emoji = match.group(1)!;
          name = name.substring(match.end).trim();
        }

        _translations[translation.languageCode] = {
          'name': name,
          'description': translation.description ?? '',
        };
      }
    }
  }

  void _saveTranslations() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.save();
      final name = _formKey.currentState!.fields['name']?.value ?? '';
      final description =
          _formKey.currentState!.fields['description']?.value ?? '';
      _translations[_selectedLanguage] = {
        'name': name,
        'description': description,
      };
    }
  }

  void _save() {
    _saveTranslations();

    widget.controller.setThemeColor = _selectedColor;

    // Ensure the emoji field in the controller's form has the current emoji
    // The controller prepends the emoji to the names during validation
    _formKey.currentState?.fields['emoji']?.didChange(_emoji);

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
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                      widget.category == null
                          ? "Ajouter une catégorie"
                          : "Modifier une catégorie",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(
                              0xFF7B5CAB,
                            ), // Purple from mockup
                          ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: primaryColor, size: 20),
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
                          _formKey.currentState?.fields['description']?.didChange(
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
                                ? primaryColor
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
                              Icon(Icons.check, color: primaryColor, size: 16),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Nom de la catégorie",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'name',
                  initialValue: _translations[_selectedLanguage]?['name'] ?? '',
                  decoration: InputDecoration(
                    hintText: "ex: Boisson", // match mockup hint
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

                Row(
                  children: [
                    const Text(
                      "Ajouter une imoji",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        // Emoji list to cycle through
                        final List<String> emojis = [
                          '🍕',
                          '🍔',
                          '🥗',
                          '🍝',
                          '🍣',
                          '🍰',
                          '☕',
                        ];
                        final currentIndex = emojis.indexOf(_emoji);
                        final nextIndex = (currentIndex + 1) % emojis.length;
                        setState(() {
                          _emoji = emojis[nextIndex];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                // Emoji hidden field for the controller
                FormBuilderField<String>(
                  name: 'emoji',
                  initialValue: _emoji,
                  builder: (FormFieldState<String?> field) =>
                      const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Thème de la catégorie :",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableColors.map((color) {
                    final isSelected = _selectedColor?.value == color.value;
                    final colorName = switch (color) {
                      Colors.red => "Red",
                      Colors.blue => "Blue",
                      Colors.green => "Green",
                      Colors.orange => "Yellow",
                      Colors.purple => "Purple",
                      Colors.pink => "Pink",
                      Colors.indigo => "Indigo",
                      Colors.grey => "Grey",
                      _ => "Color",
                    };
                    return InkWell(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 110,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              colorName,
                              style: TextStyle(
                                color: isSelected ? color : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF7E3),
                          foregroundColor: primaryColor,
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
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          widget.category == null ? "AJOUTER" : "MODIFIER",
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
}
