import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../l10n/generated/app_localizations.dart';

class Mood {
  final String id;
  final String label;
  final IconData icon;
  final String query;

  const Mood({
    required this.id,
    required this.label,
    required this.icon,
    required this.query,
  });
}

List<Mood> moodsFor(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return [
    Mood(
      id: 'cozy',
      label: l10n.moodCozy,
      icon: PhosphorIconsDuotone.coffee,
      query: 'cozy',
    ),
    Mood(
      id: 'quick',
      label: l10n.moodQuickBite,
      icon: PhosphorIconsDuotone.hamburger,
      query: 'quick',
    ),
    Mood(
      id: 'date',
      label: l10n.moodDateNight,
      icon: PhosphorIconsDuotone.wine,
      query: 'date',
    ),
    Mood(
      id: 'family',
      label: l10n.moodFamily,
      icon: PhosphorIconsDuotone.usersThree,
      query: 'family',
    ),
    Mood(
      id: 'outdoor',
      label: l10n.moodOutdoor,
      icon: PhosphorIconsDuotone.tree,
      query: 'outdoor',
    ),
    Mood(
      id: 'veg',
      label: l10n.moodVegetarian,
      icon: PhosphorIconsDuotone.plant,
      query: 'vegetarian',
    ),
  ];
}
