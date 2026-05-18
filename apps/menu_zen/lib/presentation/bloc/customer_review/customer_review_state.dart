part of 'customer_review_cubit.dart';

@immutable
sealed class CustomerReviewState {
  const CustomerReviewState();
}

class CustomerReviewIdle extends CustomerReviewState {
  const CustomerReviewIdle();
}

class CustomerReviewSubmitting extends CustomerReviewState {
  const CustomerReviewSubmitting();
}

class CustomerReviewSubmitted extends CustomerReviewState {
  final ReviewEntity review;
  const CustomerReviewSubmitted(this.review);
}

class CustomerReviewDeleted extends CustomerReviewState {
  final int reviewId;
  const CustomerReviewDeleted(this.reviewId);
}

class CustomerReviewError extends CustomerReviewState {
  final String message;
  const CustomerReviewError(this.message);
}
