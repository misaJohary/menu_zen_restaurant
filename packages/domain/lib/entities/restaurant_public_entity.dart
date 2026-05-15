import 'package:equatable/equatable.dart';

import 'opening_hours_entity.dart';

enum RestaurantType { fastfood, casual, fineDining }

class RestaurantPublicEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final RestaurantType? type;
  final List<String> languages;
  final String? logo;
  final String? cover;
  final List<String> pictures;
  final List<String> socialMedia;
  final OpeningHoursEntity? openingHours;
  final String phone;
  final String email;
  final String city;
  final double? lat;
  final double? long;
  final bool disabled;
  final double? distanceKm;

  const RestaurantPublicEntity({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.languages = const [],
    this.logo,
    this.cover,
    this.pictures = const [],
    this.socialMedia = const [],
    this.openingHours,
    required this.phone,
    required this.email,
    required this.city,
    this.lat,
    this.long,
    this.disabled = false,
    this.distanceKm,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    languages,
    logo,
    cover,
    pictures,
    socialMedia,
    openingHours,
    phone,
    email,
    city,
    lat,
    long,
    disabled,
    distanceKm,
  ];
}
