import '../entities/review_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';
import '../params/review_create_params.dart';
import '../params/review_update_params.dart';

abstract class CustomerReviewsRepository {
  Future<MultiResult<Failure, ReviewEntity>> create(ReviewCreateParams params);

  Future<MultiResult<Failure, List<ReviewEntity>>> listMine({
    int limit = 50,
    int offset = 0,
  });

  Future<MultiResult<Failure, ReviewEntity>> update(
    int reviewId,
    ReviewUpdateParams params,
  );

  Future<MultiResult<Failure, bool>> delete(int reviewId);
}
