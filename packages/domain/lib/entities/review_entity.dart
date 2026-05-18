import 'package:equatable/equatable.dart';

class ReviewCustomerEntity extends Equatable {
  final int id;
  final String displayName;
  final String? avatar;

  const ReviewCustomerEntity({
    required this.id,
    required this.displayName,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, displayName, avatar];
}

class ReviewEntity extends Equatable {
  final int id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final ReviewCustomerEntity customer;

  const ReviewEntity({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.customer,
  });

  @override
  List<Object?> get props => [id, rating, comment, createdAt, customer];
}
