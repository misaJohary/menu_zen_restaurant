import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

// Data models for the API response
class PhotonGeometry {
  final String type;
  final List<double> coordinates;

  PhotonGeometry({required this.type, required this.coordinates});

  factory PhotonGeometry.fromJson(Map<String, dynamic> json) {
    return PhotonGeometry(
      type: json['type'] ?? '',
      coordinates: List<double>.from(
        json['coordinates']?.map((x) => x.toDouble()) ?? [],
      ),
    );
  }

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;

  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
}

class PhotonProperties {
  final String? city;
  final String? country;
  final String? name;
  final String? postcode;
  final String? state;
  final String? district;
  final String? street;
  final String? housenumber;

  PhotonProperties({
    this.city,
    this.country,
    this.name,
    this.postcode,
    this.state,
    this.district,
    this.street,
    this.housenumber,
  });

  factory PhotonProperties.fromJson(Map<String, dynamic> json) {
    return PhotonProperties(
      city: json['city'],
      country: json['country'],
      name: json['name'],
      postcode: json['postcode'],
      state: json['state'],
      district: json['district'],
      street: json['street'],
      housenumber: json['housenumber'],
    );
  }
}

class PhotonFeature {
  final String type;
  final PhotonGeometry geometry;
  final PhotonProperties properties;

  PhotonFeature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory PhotonFeature.fromJson(Map<String, dynamic> json) {
    return PhotonFeature(
      type: json['type'] ?? '',
      geometry: PhotonGeometry.fromJson(json['geometry'] ?? {}),
      properties: PhotonProperties.fromJson(json['properties'] ?? {}),
    );
  }
}

class PhotonResponse {
  final String type;
  final List<PhotonFeature> features;

  PhotonResponse({required this.type, required this.features});

  factory PhotonResponse.fromJson(Map<String, dynamic> json) {
    final List<PhotonFeature> featuresMg = [];
    final _ = (json['features'] as List<dynamic>?)?.map((x) {
      if(x['properties']['countrycode'] == "MG") {
        featuresMg.add(PhotonFeature.fromJson(x));
        return PhotonFeature.fromJson(x);
      }
    }).toList() ??
        [];
    return PhotonResponse(
      type: json['type'] ?? '',
      features:
      featuresMg,
    );
  }
}

// Exception classes for error handling
class PhotonException implements Exception {
  final String message;
  final int? statusCode;

  PhotonException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'PhotonException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

// Main service class
@lazySingleton
class PhotonGeocodingService {

  final Dio dio;
  static const String _baseUrl = 'https://photon.komoot.io';


  final Duration _timeout = Duration(seconds: 10);


  PhotonGeocodingService(
      @Named("noInterceptor")
      this.dio);

  /// Search for locations by query string
  ///
  /// [query] - Search term (e.g., "Berlin")
  /// [lat] - Optional latitude for geo-prioritized search
  /// [lon] - Optional longitude for geo-prioritized search
  /// [limit] - Maximum number of results (default: 10)
  /// [lang] - Preferred language code (e.g., "de", "en")
  Future<PhotonResponse> search(
    String query, {
    double? lat,
    double? lon,
    int limit = 10,
    String? lang,
  }) async {
    if (query.trim().isEmpty) {
      throw PhotonException('Query cannot be empty');
    }

    final params = <String, String>{
      'q': query.trim(),
      'limit': limit.toString(),
    };

    if (lat != null && lon != null) {
      params['lat'] = lat.toString();
      params['lon'] = lon.toString();
    }

    if (lang != null && lang.isNotEmpty) {
      params['lang'] = lang;
    }

    final uri = Uri.https('photon.komoot.io', '/api/', params);

    try {
      final response = await dio
          .get('$_baseUrl/api/', queryParameters: params)
          .timeout(_timeout);
      Logger().e(response);
      return _handleResponse(response);
    } catch (e) {
      if (e is PhotonException) rethrow;
      throw PhotonException('Network error: $e');
    }
  }

  /// Reverse geocoding - get location details from coordinates
  ///
  /// [lat] - Latitude
  /// [lon] - Longitude
  /// [lang] - Optional preferred language code
  Future<PhotonResponse> reverse(double lat, double lon, {String? lang}) async {
    final params = <String, String>{
      'lat': lat.toString(),
      'lon': lon.toString(),
    };

    if (lang != null && lang.isNotEmpty) {
      params['lang'] = lang;
    }

    final uri = Uri.https('photon.komoot.io', '/reverse', params);

    try {
      final response = await dio
          .get('$_baseUrl/reverse', queryParameters: params)
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e is PhotonException) rethrow;
      throw PhotonException('Network error: $e');
    }
  }

  /// Search with additional filtering options
  ///
  /// [query] - Search term
  /// [bbox] - Bounding box as [minLon, minLat, maxLon, maxLat]
  /// [osm_tag] - Filter by OpenStreetMap tags (e.g., "place:city")
  /// [lat] - Optional latitude for geo-prioritized search
  /// [lon] - Optional longitude for geo-prioritized search
  /// [limit] - Maximum number of results
  /// [lang] - Preferred language code
  Future<PhotonResponse> searchAdvanced(
    String query, {
    List<double>? bbox,
    String? osmTag,
    double? lat,
    double? lon,
    int limit = 10,
    String? lang,
  }) async {
    if (query.trim().isEmpty) {
      throw PhotonException('Query cannot be empty');
    }

    final params = <String, String>{
      'q': query.trim(),
      'limit': limit.toString(),
    };

    if (lat != null && lon != null) {
      params['lat'] = lat.toString();
      params['lon'] = lon.toString();
    }

    if (lang != null && lang.isNotEmpty) {
      params['lang'] = lang;
    }

    if (bbox != null && bbox.length == 4) {
      params['bbox'] = bbox.join(',');
    }

    if (osmTag != null && osmTag.isNotEmpty) {
      params['osm_tag'] = osmTag;
    }

    try {
      final response = await dio
          .get('$_baseUrl/api/', queryParameters: params)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is PhotonException) rethrow;
      throw PhotonException('Network error: $e');
    }
  }

  PhotonResponse _handleResponse(Response response) {
    if (response.statusCode == 200) {
      try {
        Logger().e('fucking here');
        Logger().e('and here');
        return PhotonResponse.fromJson(response.data);
      } catch (e) {
        throw PhotonException('Failed to parse response: $e');
      }
    } else {
      throw PhotonException(
        'API request failed: ${response.statusMessage ?? 'Unknown error'}',
        response.statusCode,
      );
    }
  }

  /// Dispose of the HTTP client
  void dispose() {
    dio.close();
  }
}

// Usage example and helper methods
extension PhotonServiceHelpers on PhotonGeocodingService {
  /// Quick search for a single best result
  Future<PhotonFeature?> searchSingle(
    String query, {
    double? lat,
    double? lon,
  }) async {
    final response = await search(query, lat: lat, lon: lon, limit: 1);
    return response.features.isNotEmpty ? response.features.first : null;
  }

  /// Get formatted address string from a feature
  String formatAddress(PhotonFeature feature) {
    final parts = <String>[];
    final props = feature.properties;

    if (props.name != null) parts.add(props.name!);
    if (props.street != null) parts.add(props.street!);
    if (props.housenumber != null) parts.add(props.housenumber!);
    if (props.city != null) parts.add(props.city!);
    if (props.postcode != null) parts.add(props.postcode!);
    if (props.country != null) parts.add(props.country!);

    return parts.join(', ');
  }
}
