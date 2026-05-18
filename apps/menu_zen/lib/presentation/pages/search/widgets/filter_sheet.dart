import 'package:design_system/design_system.dart';
import 'package:domain/entities/discovery_filters.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class FilterSheet extends StatefulWidget {
  final DiscoveryFilters initial;
  const FilterSheet({super.key, required this.initial});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late DiscoveryFilters _filters = widget.initial;

  static const _cuisineTypes = <RestaurantType>[
    RestaurantType.fastfood,
    RestaurantType.casual,
    RestaurantType.fineDining,
  ];

  // Backend filters are matched by their canonical key (stable across
  // locales). The label is purely a display concern.
  // TODO(api): backend doesn't expose capabilities/dietary yet — these are
  // applied client-side at render time (see SearchPage._applyClient).
  static const _capabilityKeys = <String>['Reservations', 'Delivers', 'Takeaway'];
  static const _dietaryKeys = <String>['Veg', 'Vegan', 'Halal', 'Gluten-free'];

  String _cuisineLabel(AppLocalizations l10n, RestaurantType type) {
    switch (type) {
      case RestaurantType.fastfood:
        return l10n.cuisineFastFood;
      case RestaurantType.casual:
        return l10n.cuisineCasual;
      case RestaurantType.fineDining:
        return l10n.cuisineFineDining;
    }
  }

  String _capabilityLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'Reservations':
        return l10n.capabilityReservations;
      case 'Delivers':
        return l10n.capabilityDelivers;
      case 'Takeaway':
        return l10n.capabilityTakeaway;
      default:
        return key;
    }
  }

  String _dietaryLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'Veg':
        return l10n.dietaryVeg;
      case 'Vegan':
        return l10n.dietaryVegan;
      case 'Halal':
        return l10n.dietaryHalal;
      case 'Gluten-free':
        return l10n.dietaryGlutenFree;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filtersTitle, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.filtersCuisine, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final type in _cuisineTypes)
                  MoodChip(
                    label: _cuisineLabel(l10n, type),
                    selected: _filters.type == type,
                    onTap: () => setState(() {
                      _filters = _filters.type == type
                          ? _filters.copyWith(clearType: true)
                          : _filters.copyWith(type: type);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Text(l10n.filtersDistance, style: textTheme.titleMedium),
                const Spacer(),
                Text(
                  _filters.radiusKm == null
                      ? l10n.filtersDistanceAny
                      : l10n.filtersDistanceKm(
                          _filters.radiusKm!.toStringAsFixed(1),
                        ),
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            Slider(
              min: 0.2,
              max: 10,
              divisions: 49,
              value: _filters.radiusKm ?? 10,
              label: l10n.filtersDistanceKm(
                (_filters.radiusKm ?? 10).toStringAsFixed(1),
              ),
              onChanged: (v) => setState(() {
                _filters = _filters.copyWith(radiusKm: v);
              }),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(l10n.filtersCapabilities, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final key in _capabilityKeys)
                  MoodChip(
                    label: _capabilityLabel(l10n, key),
                    selected: _filters.capabilities.contains(key),
                    onTap: () => setState(() {
                      final next = Set<String>.from(_filters.capabilities);
                      next.contains(key) ? next.remove(key) : next.add(key);
                      _filters = _filters.copyWith(capabilities: next);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Text(l10n.filtersDietary, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final key in _dietaryKeys)
                  MoodChip(
                    label: _dietaryLabel(l10n, key),
                    selected: _filters.dietary.contains(key),
                    onTap: () => setState(() {
                      final next = Set<String>.from(_filters.dietary);
                      next.contains(key) ? next.remove(key) : next.add(key);
                      _filters = _filters.copyWith(dietary: next);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _filters = const DiscoveryFilters();
                    }),
                    child: Text(l10n.commonReset),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_filters),
                    child: Text(l10n.commonApply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
