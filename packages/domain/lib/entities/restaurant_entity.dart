import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final String? logo;
  final String? cover;
  final List<String>? pictures;
  final List<String>? socialMedia;
  final String phone;
  final String email;
  final String city;
  final double? lat;
  final double? long;
  final String? type;
  final List<String>? languages;

  const RestaurantEntity({
    this.id,
    required this.name,
    this.description,
    this.logo,
    this.cover,
    this.pictures,
    this.socialMedia,
    required this.phone,
    required this.email,
    required this.city,
    this.lat,
    this.long,
    this.type,
    this.languages,
  });

  ///create copyWith
  RestaurantEntity copyWith({
    int? id,
    String? name,
    String? description,
    String? logo,
    String? cover,
    List<String>? pictures,
    List<String>? socialMedia,
    String? phone,
    String? email,
    String? city,
    double? lat,
    double? long,
    String? type,
    List<String>? languages,
  }) {
    return RestaurantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      cover: cover ?? this.cover,
      pictures: pictures ?? this.pictures,
      socialMedia: socialMedia ?? this.socialMedia,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      type: type ?? this.type,
      languages: languages ?? this.languages,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    logo,
    cover,
    pictures,
    socialMedia,
    phone,
    email,
    city,
    lat,
    long,
    type,
    languages,
  ];
}
