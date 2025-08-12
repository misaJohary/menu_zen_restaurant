import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

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
  });

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
  ];
}