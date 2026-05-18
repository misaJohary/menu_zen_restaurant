import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:domain/entities/category_entity.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/utils/translations.dart';
import '../widgets/menu_category_rail.dart';
import '../widgets/menu_item_sheet.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/menu_language_picker.dart';

class MenuTab extends StatefulWidget {
  final Map<CategoryEntity, List<MenuItemEntity>> menuByCategory;
  final List<String> availableLanguages;

  const MenuTab({
    super.key,
    required this.menuByCategory,
    this.availableLanguages = const [],
  });

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];
  int _activeIndex = 0;
  bool _suppressScrollSync = false;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    _selectedLanguage = _pickInitialLanguage(widget.availableLanguages);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant MenuTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.menuByCategory.length != widget.menuByCategory.length) {
      _syncKeys();
      _activeIndex = 0;
    }
    if (oldWidget.availableLanguages != widget.availableLanguages) {
      _selectedLanguage = _pickInitialLanguage(widget.availableLanguages);
    }
  }

  String? _pickInitialLanguage(List<String> languages) {
    if (languages.isEmpty) return null;
    final deviceCode = ui.PlatformDispatcher.instance.locale.languageCode;
    for (final code in languages) {
      if (code.toLowerCase() == deviceCode.toLowerCase()) return code;
    }
    return languages.first;
  }

  void _syncKeys() {
    _sectionKeys
      ..clear()
      ..addAll(List.generate(widget.menuByCategory.length, (_) => GlobalKey()));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_suppressScrollSync) return;
    for (int i = _sectionKeys.length - 1; i >= 0; i--) {
      final context = _sectionKeys[i].currentContext;
      if (context == null) continue;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= _activationThreshold) {
        if (_activeIndex != i) setState(() => _activeIndex = i);
        return;
      }
    }
    if (_activeIndex != 0) setState(() => _activeIndex = 0);
  }

  double get _activationThreshold {
    // Section is "active" once its header crosses just below the rail.
    final media = MediaQuery.of(context);
    return media.padding.top + kToolbarHeight + 120;
  }

  Future<void> _scrollToSection(int index) async {
    final context = _sectionKeys[index].currentContext;
    if (context == null) return;
    setState(() {
      _activeIndex = index;
      _suppressScrollSync = true;
    });
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
    _suppressScrollSync = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menuByCategory.isEmpty) {
      return const EmptyState(
        icon: PhosphorIconsDuotone.forkKnife,
        title: 'Menu coming soon',
        body: "We haven't published anything to taste yet.",
      );
    }

    final locale = _selectedLanguage ??
        ui.PlatformDispatcher.instance.locale.languageCode;
    final entries = widget.menuByCategory.entries.toList();
    final railEntries = [
      for (var i = 0; i < entries.length; i++)
        MenuCategoryEntry(
          label: _categoryTitle(entries[i].key, locale, fallbackIndex: i),
          count: entries[i].value.length,
        ),
    ];

    final showLanguagePicker = widget.availableLanguages.length > 1 &&
        _selectedLanguage != null;

    return Column(
      children: [
        if (showLanguagePicker)
          MenuLanguagePicker(
            languages: widget.availableLanguages,
            selected: _selectedLanguage!,
            onSelected: (code) => setState(() => _selectedLanguage = code),
          ),
        MenuCategoryRail(
          entries: railEntries,
          activeIndex: _activeIndex,
          onSelected: _scrollToSection,
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.xxxl,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final items = entry.value;
              return _CategorySection(
                key: _sectionKeys[index],
                isFirst: index == 0,
                items: items,
                locale: locale,
                onItemTap: (item) => _openSheet(context, item, locale),
              );
            },
          ),
        ),
      ],
    );
  }

  String _categoryTitle(
    CategoryEntity category,
    String? locale, {
    required int fallbackIndex,
  }) {
    if (category.id == -1) return 'Other';
    final t = pickTranslation(category.translations, locale);
    final name = t?.name.trim() ?? '';
    if (name.isNotEmpty) return name;
    return 'Section ${fallbackIndex + 1}';
  }

  void _openSheet(BuildContext context, MenuItemEntity item, String? locale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuItemSheet(item: item, locale: locale),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final bool isFirst;
  final List<MenuItemEntity> items;
  final String? locale;
  final ValueChanged<MenuItemEntity> onItemTap;

  const _CategorySection({
    super.key,
    required this.isFirst,
    required this.items,
    required this.locale,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            child: Divider(
              height: 1,
              thickness: 1,
              color: scheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
        ...List.generate(items.length, (index) {
          return Column(
            children: [
              MenuItemTile(
                item: items[index],
                locale: locale,
                onTap: () => onItemTap(items[index]),
              ),
              if (index != items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.onSurface.withValues(alpha: 0.06),
                ),
            ],
          );
        }),
      ],
    );
  }
}