import 'package:design_system/design_system.dart';
import 'package:domain/entities/discovery_filters.dart';
import 'package:domain/entities/restaurant_public_entity.dart';
import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final DiscoveryFilters initial;
  const FilterSheet({super.key, required this.initial});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late DiscoveryFilters _filters = widget.initial;

  static const _cuisineTypes = <(RestaurantType, String)>[
    (RestaurantType.fastfood, 'Fast food'),
    (RestaurantType.casual, 'Casual'),
    (RestaurantType.fineDining, 'Fine dining'),
  ];

  // TODO(api): backend doesn't expose capabilities/dietary yet — these
  // are applied client-side at render time (see SearchPage._applyClient).
  static const _capabilities = <String>['Reservations', 'Delivers', 'Takeaway'];
  static const _dietary = <String>['Veg', 'Vegan', 'Halal', 'Gluten-free'];

  @override
  Widget build(BuildContext context) {
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
            Text('Filters', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.l),
            Text('Cuisine', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final (type, label) in _cuisineTypes)
                  MoodChip(
                    label: label,
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
                Text('Distance', style: textTheme.titleMedium),
                const Spacer(),
                Text(
                  _filters.radiusKm == null
                      ? 'Any'
                      : '${_filters.radiusKm!.toStringAsFixed(1)} km',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
            Slider(
              min: 0.2,
              max: 10,
              divisions: 49,
              value: _filters.radiusKm ?? 10,
              label: '${(_filters.radiusKm ?? 10).toStringAsFixed(1)} km',
              onChanged: (v) => setState(() {
                _filters = _filters.copyWith(radiusKm: v);
              }),
            ),
            const SizedBox(height: AppSpacing.s),
            Text('Capabilities', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final cap in _capabilities)
                  MoodChip(
                    label: cap,
                    selected: _filters.capabilities.contains(cap),
                    onTap: () => setState(() {
                      final next = Set<String>.from(_filters.capabilities);
                      next.contains(cap) ? next.remove(cap) : next.add(cap);
                      _filters = _filters.copyWith(capabilities: next);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Text('Dietary', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final d in _dietary)
                  MoodChip(
                    label: d,
                    selected: _filters.dietary.contains(d),
                    onTap: () => setState(() {
                      final next = Set<String>.from(_filters.dietary);
                      next.contains(d) ? next.remove(d) : next.add(d);
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
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_filters),
                    child: const Text('Apply'),
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
