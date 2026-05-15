import '../entities/geo_point_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

enum LocationPermissionStatus { granted, denied, deniedForever, serviceDisabled }

abstract class GeolocationRepository {
  Future<LocationPermissionStatus> permissionStatus();
  Future<LocationPermissionStatus> requestPermission();
  Future<MultiResult<Failure, GeoPointEntity>> currentPosition();
}
