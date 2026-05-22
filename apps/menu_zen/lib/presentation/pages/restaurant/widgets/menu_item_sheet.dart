import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/utils/translations.dart';
import '../../../../l10n/generated/app_localizations.dart';

class MenuItemSheet extends StatefulWidget {
  final MenuItemEntity item;
  final String? locale;

  const MenuItemSheet({super.key, required this.item, this.locale});

  @override
  State<MenuItemSheet> createState() => _MenuItemSheetState();
}

class _MenuItemSheetState extends State<MenuItemSheet> {
  int _quantity = 1;
  static final _priceFormat = NumberFormat.decimalPattern();

  void _increment() => setState(() => _quantity = (_quantity + 1).clamp(1, 99));
  void _decrement() => setState(() => _quantity = (_quantity - 1).clamp(1, 99));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final translation =
        pickTranslation(widget.item.translations, widget.locale);
    final rawName = translation?.name.trim() ?? '';
    final name = rawName.isEmpty ? l10n.menuItemUntitled : rawName;
    final description = translation?.description?.trim();
    final total = (widget.item.price * _quantity).round();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  children: [
                    if (widget.item.picture != null &&
                        widget.item.picture!.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: CachedNetworkImage(
                          imageUrl: widget.item.picture!,
                          fit: BoxFit.cover,
                          cacheManager:
                              PersistentImageCacheManager.instance,
                          placeholder: (_, __) =>
                              Container(color: AppColors.canvas),
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.canvas),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: textTheme.headlineSmall),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            l10n.menuItemPrice(
                              _priceFormat.format(widget.item.price.round()),
                            ),
                            style: textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (description != null &&
                              description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.m),
                            Text(
                              description,
                              style: textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                                color: scheme.onSurface.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m,
                    AppSpacing.s,
                    AppSpacing.m,
                    AppSpacing.m,
                  ),
                  child: Row(
                    children: [
                      _QuantityStepper(
                        quantity: _quantity,
                        onDecrement: _decrement,
                        onIncrement: _increment,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            l10n.menuItemAddToCart(_priceFormat.format(total)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 ? onDecrement : null,
            icon: const Icon(PhosphorIconsRegular.minus),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(PhosphorIconsRegular.plus),
          ),
        ],
      ),
    );
  }
}
