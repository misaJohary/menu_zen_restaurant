class ReviewCreateParams {
  final int restaurantId;
  final int rating;
  final String? comment;

  const ReviewCreateParams({
    required this.restaurantId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    'restaurant_id': restaurantId,
    'rating': rating,
    if (comment != null && comment!.trim().isNotEmpty) 'comment': comment,
  };
}
