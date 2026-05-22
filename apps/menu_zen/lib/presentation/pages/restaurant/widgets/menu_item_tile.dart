import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:domain/entities/menu_item_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/translations.dart';
import '../../../../l10n/generated/app_localizations.dart';

class MenuItemTile extends StatelessWidget {
  final MenuItemEntity item;
  final String? locale;
  final VoidCallback onTap;

  const MenuItemTile({
    super.key,
    required this.item,
    required this.locale,
    required this.onTap,
  });

  static final _priceFormat = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final unavailable = item.active == false;

    final translation = pickTranslation(item.translations, locale);
    final rawName = translation?.name.trim() ?? '';
    final name = rawName.isEmpty ? l10n.menuItemUntitled : rawName;
    final description = translation?.description?.trim();

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Text(
                      l10n.menuItemPrice(
                        _priceFormat.format(item.price.round()),
                      ),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                    if (unavailable) ...[
                      const SizedBox(width: AppSpacing.s),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Text(
                          l10n.menuItemUnavailable,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              width: 88,
              height: 88,
              child: item.picture != null && item.picture!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.picture!,
                      fit: BoxFit.cover,
                      cacheManager: PersistentImageCacheManager.instance,
                      placeholder: (_, __) =>
                          Container(color: AppColors.canvas),
                      errorWidget: (_, __, ___) => _placeholder(scheme),
                    )
                  : _placeholder(scheme),
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: unavailable ? 0.55 : 1,
      child: InkWell(
        onTap: unavailable ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: tile,
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      color: scheme.tertiary.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_menu,
        color: scheme.tertiary,
      ),
    );
  }
}
