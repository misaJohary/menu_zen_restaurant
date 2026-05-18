import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/generated/app_localizations.dart';

class MenuLanguagePicker extends StatelessWidget {
  final List<String> languages;
  final String selected;
  final ValueChanged<String> onSelected;

  const MenuLanguagePicker({
    super.key,
    required this.languages,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
        AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.translate,
            size: 18,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            l10n.menuLanguage,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          if (languages.length <= 3)
            _SegmentedPicker(
              languages: languages,
              selected: selected,
              onSelected: onSelected,
            )
          else
            _DropdownPicker(
              languages: languages,
              selected: selected,
              onSelected: onSelected,
            ),
        ],
      ),
    );
  }
}

class _SegmentedPicker extends StatelessWidget {
  final List<String> languages;
  final String selected;
  final ValueChanged<String> onSelected;

  const _SegmentedPicker({
    required this.languages,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in languages)
            _SegmentButton(
              label: _displayLabel(code),
              selected: code == selected,
              onTap: () => onSelected(code),
              textStyle: textTheme.labelMedium,
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = selected ? scheme.primary : Colors.transparent;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            label,
            style: textStyle?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownPicker extends StatelessWidget {
  final List<String> languages;
  final String selected;
  final ValueChanged<String> onSelected;

  const _DropdownPicker({
    required this.languages,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return PopupMenuButton<String>(
      initialValue: selected,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final code in languages)
          PopupMenuItem<String>(
            value: code,
            child: Row(
              children: [
                Text(_displayLabel(code)),
                const Spacer(),
                Text(
                  _displayName(context, code),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _displayLabel(selected),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              PhosphorIconsRegular.caretDown,
              size: 14,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

String _displayLabel(String code) => code.toUpperCase();

String _displayName(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  switch (code.toLowerCase()) {
    case 'en':
      return l10n.languageEnglish;
    case 'fr':
      return l10n.languageFrench;
    case 'mg':
      return l10n.languageMalagasy;
    case 'es':
      return l10n.languageSpanish;
    case 'de':
      return l10n.languageGerman;
    case 'it':
      return l10n.languageItalian;
    case 'pt':
      return l10n.languagePortuguese;
    case 'zh':
      return l10n.languageChinese;
    case 'ja':
      return l10n.languageJapanese;
    case 'ar':
      return l10n.languageArabic;
    default:
      return code.toUpperCase();
  }
}
