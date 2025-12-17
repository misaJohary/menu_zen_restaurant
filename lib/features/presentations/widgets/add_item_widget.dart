import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../core/constants/constants.dart';
import '../../domains/entities/language_entity.dart';
import '../managers/languages/languages_bloc.dart';
import 'multilingual_field.dart';

class AddItemWidget extends StatefulWidget {
  const AddItemWidget({
    super.key,
    required this.title,
    required this.formBuilderFields,
    required this.formKey,
    this.confirmationButton,
    this.cancelButton,
    this.multilingualFields = const [],
    this.initialTranslations,
  });

  final String title;
  final List<Widget> formBuilderFields;
  final GlobalKey formKey;
  final Widget? confirmationButton;
  final Widget? cancelButton;
  final List<MultilingualField> multilingualFields;
  final Map<String, Map<String, String>>? initialTranslations;

  @override
  State<AddItemWidget> createState() => AddItemWidgetState();

  /// Static helper method to get translations from a widget's state
  static Map<String, Map<String, String>>? getTranslations(
    GlobalKey<State<AddItemWidget>> key,
  ) {
    final state = key.currentState;
    if (state is AddItemWidgetState) {
      return state.translations;
    }
    return null;
  }
}

/// Public state class to allow external access to translations
class AddItemWidgetState extends State<AddItemWidget> {
  final Map<String, Map<String, String>> _translations = {};
  LanguageEntity? selectedLanguage;

  /// Get all translations entered by the user
  /// Returns a map of language code to field values
  Map<String, Map<String, String>> get translations => _translations;

  /// Get translation for a specific language and field
  String? getTranslation(String languageCode, String fieldName) {
    return _translations[languageCode]?[fieldName];
  }

  /// Check if all multilingual fields have been filled for all languages
  bool areAllTranslationsComplete(List<LanguageEntity> languages) {
    if (widget.multilingualFields.isEmpty) return true;

    for (var language in languages) {
      for (var field in widget.multilingualFields) {
        final value = _translations[language.code]?[field.name];
        if (value == null || value.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize translations from initialTranslations if provided
    if (widget.initialTranslations != null) {
      _translations.addAll(widget.initialTranslations!);
    }
    
    // Fetch languages when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguagesBloc>().add(LanguagesFetched());
      
      // Patch FormBuilder values for multilingual fields if initialTranslations exist
      if (widget.initialTranslations != null) {
        final formState = widget.formKey.currentState;
        if (formState is FormBuilderState) {
          final Map<String, dynamic> patchValues = {};
          for (var langEntry in widget.initialTranslations!.entries) {
            for (var fieldEntry in langEntry.value.entries) {
              patchValues['${fieldEntry.key}_${langEntry.key}'] = fieldEntry.value;
            }
          }
          formState.patchValue(patchValues);
        }
      }
    });
  }

  @override
  void didUpdateWidget(AddItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update translations when initialTranslations change (e.g., switching to edit mode)
    if (widget.initialTranslations != null && 
        widget.initialTranslations != oldWidget.initialTranslations) {
      setState(() {
        _translations.clear();
        _translations.addAll(widget.initialTranslations!);
      });
      
      // Also patch FormBuilder values for multilingual fields
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final formState = widget.formKey.currentState;
        if (formState is FormBuilderState && widget.initialTranslations != null) {
          final Map<String, dynamic> patchValues = {};
          for (var langEntry in widget.initialTranslations!.entries) {
            for (var fieldEntry in langEntry.value.entries) {
              patchValues['${fieldEntry.key}_${langEntry.key}'] = fieldEntry.value;
            }
          }
          formState.patchValue(patchValues);
        }
      });
    } else if (widget.initialTranslations == null && 
               oldWidget.initialTranslations != null) {
      // Clear translations when switching from edit to create mode
      setState(() {
        _translations.clear();
      });
      
      // Clear FormBuilder values for multilingual fields
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final formState = widget.formKey.currentState;
        if (formState is FormBuilderState && oldWidget.initialTranslations != null) {
          final Map<String, dynamic> patchValues = {};
          for (var langEntry in oldWidget.initialTranslations!.entries) {
            for (var fieldEntry in langEntry.value.entries) {
              patchValues['${fieldEntry.key}_${langEntry.key}'] = '';
            }
          }
          formState.patchValue(patchValues);
        }
      });
    }
  }

  void _onLanguageChanged(LanguageEntity language) {
    setState(() {
      selectedLanguage = language;
      print('Language switched to: ${language.code} (${language.name})');
      print('Current translations: $_translations');
    });
    context.read<LanguagesBloc>().add(LanguageSelected(language));
  }

  void _updateTranslation(String fieldName, String value, String languageCode) {
    setState(() {
      if (!_translations.containsKey(languageCode)) {
        _translations[languageCode] = {};
      }
      _translations[languageCode]![fieldName] = value;

      // Debug: Print when translation is updated
      print('Translation updated: $languageCode.$fieldName = "$value"');
      print('All translations now: $_translations');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kspacing * 2),
        child: FormBuilder(
          key: widget.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),

              // Multilingual fields in tabs
              if (widget.multilingualFields.isNotEmpty)
                BlocBuilder<LanguagesBloc, LanguagesState>(
                  builder: (context, state) {
                    if (state.languages.isEmpty) {
                      return SizedBox.shrink();
                    }

                    if (selectedLanguage == null &&
                        state.selectedLanguage != null) {
                      selectedLanguage = state.selectedLanguage;
                    }

                    return DefaultTabController(
                      length: state.languages.length,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: kspacing * 2),
                          Text(
                            'Translations',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: kspacing),
                          TabBar(
                            isScrollable: true,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Theme.of(context).primaryColor,
                            onTap: (index) {
                              _onLanguageChanged(state.languages[index]);
                            },
                            tabs: state.languages.map((language) {
                              return Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(language.name),
                                    SizedBox(width: 4),
                                    // Show indicator if this language has translations
                                    if (_translations.containsKey(
                                          language.code,
                                        ) &&
                                        _translations[language.code]!
                                            .isNotEmpty)
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Container(
                            height: 200,
                            padding: EdgeInsets.all(kspacing * 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: TabBarView(
                              children: state.languages.map((language) {
                                return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: widget.multilingualFields.map((
                                      field,
                                    ) {
                                      final currentValue =
                                          _translations[language.code]?[field
                                              .name] ??
                                          '';
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: kspacing,
                                        ),
                                        child: FormBuilderTextField(
                                          name:
                                              '${field.name}_${language.code}',
                                          decoration: InputDecoration(
                                            labelText: field.label,
                                            border: OutlineInputBorder(),
                                            hintText:
                                                'Enter ${field.label.toLowerCase()} in ${language.name}',
                                          ),
                                          initialValue: currentValue,
                                          maxLines: field.maxLines,
                                          onChanged: (value) {
                                            _updateTranslation(
                                              field.name,
                                              value ?? '',
                                              language.code,
                                            );
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              SizedBox(height: kspacing * 2),

              // Regular non-multilingual fields
              ...widget.formBuilderFields,

              Row(
                children: [
                  ...widget.confirmationButton != null
                      ? [
                          widget.confirmationButton!,
                          SizedBox(width: kspacing * 2),
                        ]
                      : [],
                  ...widget.cancelButton != null ? [widget.cancelButton!] : [],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
