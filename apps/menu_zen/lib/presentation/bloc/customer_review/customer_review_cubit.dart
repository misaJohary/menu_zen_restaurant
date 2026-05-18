import 'package:domain/entities/review_entity.dart';
import 'package:domain/params/review_create_params.dart';
import 'package:domain/params/review_update_params.dart';
import 'package:domain/repositories/customer_reviews_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'customer_review_state.dart';

class CustomerReviewCubit extends Cubit<CustomerReviewState> {
  final CustomerReviewsRepository _reviews;

  CustomerReviewCubit(this._reviews) : super(const CustomerReviewIdle());

  Future<void> submit({
    required int restaurantId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      emit(const CustomerReviewError('Pick a rating from 1 to 5.'));
      return;
    }
    emit(const CustomerReviewSubmitting());
    final result = await _reviews.create(
      ReviewCreateParams(
        restaurantId: restaurantId,
        rating: rating,
        comment: comment,
      ),
    );
    if (result.isSuccess && result.getSuccess != null) {
      emit(CustomerReviewSubmitted(result.getSuccess!));
    } else {
      emit(
        CustomerReviewError(
          result.getError?.message ?? 'Could not save your review.',
        ),
      );
    }
  }

  Future<void> update({
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      emit(const CustomerReviewError('Pick a rating from 1 to 5.'));
      return;
    }
    emit(const CustomerReviewSubmitting());
    final result = await _reviews.update(
      reviewId,
      ReviewUpdateParams(rating: rating, comment: comment),
    );
    if (result.isSuccess && result.getSuccess != null) {
      emit(CustomerReviewSubmitted(result.getSuccess!));
    } else {
      emit(
        CustomerReviewError(
          result.getError?.message ?? 'Could not update your review.',
        ),
      );
    }
  }

  Future<void> delete(int reviewId) async {
    emit(const CustomerReviewSubmitting());
    final result = await _reviews.delete(reviewId);
    if (result.isSuccess) {
      emit(CustomerReviewDeleted(reviewId));
    } else {
      emit(
        CustomerReviewError(
          result.getError?.message ?? 'Could not delete your review.',
        ),
      );
    }
  }

  void reset() => emit(const CustomerReviewIdle());
}
