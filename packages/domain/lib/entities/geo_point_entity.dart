import 'package:equatable/equatable.dart';

class GeoPointEntity extends Equatable {
  final double lat;
  final double long;

  const GeoPointEntity({required this.lat, required this.long});

  @override
  List<Object?> get props => [lat, long];
}
