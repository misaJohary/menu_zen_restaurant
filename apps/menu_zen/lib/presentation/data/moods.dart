import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

const List<Mood> kMoods = [
  Mood(
    id: 'cozy',
    label: 'Cozy',
    icon: PhosphorIconsDuotone.coffee,
    query: 'cozy',
  ),
  Mood(
    id: 'quick',
    label: 'Quick bite',
    icon: PhosphorIconsDuotone.hamburger,
    query: 'quick',
  ),
  Mood(
    id: 'date',
    label: 'Date night',
    icon: PhosphorIconsDuotone.wine,
    query: 'date',
  ),
  Mood(
    id: 'family',
    label: 'Family',
    icon: PhosphorIconsDuotone.usersThree,
    query: 'family',
  ),
  Mood(
    id: 'outdoor',
    label: 'Outdoor',
    icon: PhosphorIconsDuotone.tree,
    query: 'outdoor',
  ),
  Mood(
    id: 'veg',
    label: 'Vegetarian',
    icon: PhosphorIconsDuotone.plant,
    query: 'vegetarian',
  ),
];
