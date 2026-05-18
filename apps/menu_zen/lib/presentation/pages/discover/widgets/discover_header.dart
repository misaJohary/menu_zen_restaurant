import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../l10n/generated/app_localizations.dart';

class DiscoverHeader extends StatelessWidget {
  final String city;
  final bool locationDenied;
  final VoidCallback? onSearchTap;

  const DiscoverHeader({
    super.key,
    required this.city,
    required this.locationDenied,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                locationDenied
                    ? PhosphorIconsRegular.mapPin
                    : PhosphorIconsFill.mapPin,
                size: 16,
                color: muted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                locationDenied ? l10n.discoverBrowsingCity(city) : city,
                style: textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.discoverGreeting,
            style: textTheme.displayMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          GestureDetector(
            onTap: onSearchTap,
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon:
                      const Icon(PhosphorIconsRegular.magnifyingGlass),
                  hintText: l10n.discoverSearchHint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
