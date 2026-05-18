import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MenuCategoryEntry {
  final String label;
  final int count;

  const MenuCategoryEntry({required this.label, required this.count});
}

class MenuCategoryRail extends StatefulWidget {
  final List<MenuCategoryEntry> entries;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  const MenuCategoryRail({
    super.key,
    required this.entries,
    required this.activeIndex,
    required this.onSelected,
  });

  @override
  State<MenuCategoryRail> createState() => _MenuCategoryRailState();
}

class _MenuCategoryRailState extends State<MenuCategoryRail> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _chipKeys = [];

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(covariant MenuCategoryRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries.length != widget.entries.length) {
      _syncKeys();
    }
    if (oldWidget.activeIndex != widget.activeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
    }
  }

  void _syncKeys() {
    _chipKeys
      ..clear()
      ..addAll(List.generate(widget.entries.length, (_) => GlobalKey()));
  }

  void _ensureVisible() {
    if (widget.activeIndex < 0 ||
        widget.activeIndex >= _chipKeys.length ||
        !_scrollController.hasClients) {
      return;
    }
    final context = _chipKeys[widget.activeIndex].currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      alignment: 0.1,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          itemCount: widget.entries.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.s),
          itemBuilder: (context, index) {
            final entry = widget.entries[index];
            final selected = index == widget.activeIndex;
            return _CategoryChip(
              key: _chipKeys[index],
              label: entry.label,
              count: entry.count,
              selected: selected,
              onTap: () => widget.onSelected(index),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final background =
        selected ? scheme.primary : scheme.surfaceContainerHighest;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.onPrimary.withValues(alpha: 0.18)
                      : scheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '$count',
                  style: textTheme.labelSmall?.copyWith(
                    color: foreground.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
