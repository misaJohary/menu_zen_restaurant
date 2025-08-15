import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/restaurant_entity.dart';

part 'restaurant_model.g.dart';

@JsonSerializable()
class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
    super.id,
    required super.name,
    super.description,
    super.logo,
    super.cover,
    super.pictures,
    super.socialMedia,
    required super.phone,
    required super.email,
    required super.city,
    super.lat,
    super.long,
  });

  /// Constructor from RestaurantEntity
  RestaurantModel.fromEntity(RestaurantEntity entity)
      : super(
    id: entity.id,
    name: entity.name,
    description: entity.description,
    logo: entity.logo,
    cover: entity.cover,
    pictures: entity.pictures,
    socialMedia: entity.socialMedia,
    phone: entity.phone,
    email: entity.email,
    city: entity.city,
    lat: entity.lat,
    long: entity.long,
  );

  /// Copywith constructor
  RestaurantModel copyWith({
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
  }) {
    return RestaurantModel(
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
    );
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);
}