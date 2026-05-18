import 'package:domain/entities/review_entity.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/params/review_create_params.dart';
import 'package:domain/params/review_update_params.dart';
import 'package:domain/repositories/customer_reviews_repository.dart';

import '../datasources/customer_reviews_remote_datasource.dart';
import '../errors/handle_exception.dart';

class CustomerReviewsRepositoryImpl implements CustomerReviewsRepository {
  final CustomerReviewsRemoteDatasource _remote;

  CustomerReviewsRepositoryImpl(this._remote);

  @override
  Future<MultiResult<Failure, ReviewEntity>> create(
    ReviewCreateParams params,
  ) {
    return executeWithErrorHandling(() => _remote.create(params));
  }

  @override
  Future<MultiResult<Failure, List<ReviewEntity>>> listMine({
    int limit = 50,
    int offset = 0,
  }) {
    return executeWithErrorHandling(
      () => _remote.listMine(limit: limit, offset: offset),
    );
  }

  @override
  Future<MultiResult<Failure, ReviewEntity>> update(
    int reviewId,
    ReviewUpdateParams params,
  ) {
    return executeWithErrorHandling(() => _remote.update(reviewId, params));
  }

  @override
  Future<MultiResult<Failure, bool>> delete(int reviewId) {
    return executeWithErrorHandling(() async {
      await _remote.delete(reviewId);
      return true;
    });
  }
}