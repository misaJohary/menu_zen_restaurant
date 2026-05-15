import 'package:domain/entities/restaurant_search_response.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/restaurant_search_params.dart';
import 'package:domain/repositories/public_restaurants_repository.dart';

import '../datasources/public_restaurants_remote_datasource.dart';
import '../errors/handle_exception.dart';

class PublicRestaurantsRepositoryImpl implements PublicRestaurantsRepository {
  final PublicRestaurantsRemoteDatasource _remote;

  PublicRestaurantsRepositoryImpl(this._remote);

  @override
  Future<MultiResult<Failure, RestaurantSearchResponseEntity>> searchNearby(
    RestaurantSearchParams params,
  ) {
    return executeWithErrorHandling(() => _remote.searchNearby(params));
  }
}
