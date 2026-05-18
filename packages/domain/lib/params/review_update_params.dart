class ReviewUpdateParams {
  final int? rating;
  final String? comment;

  const ReviewUpdateParams({this.rating, this.comment});

  Map<String, dynamic> toJson() => {
    if (rating != null) 'rating': rating,
    if (comment != null) 'comment': comment,
  };
}