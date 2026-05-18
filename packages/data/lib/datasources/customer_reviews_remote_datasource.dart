import 'package:dio/dio.dart';
import 'package:domain/entities/review_entity.dart';
import 'package:domain/params/review_create_params.dart';
import 'package:domain/params/review_update_params.dart';

import '../models/review_model.dart';

/// Talks to `/customers/me/reviews/*`. Expects a customer-scoped Dio that
/// already attaches the `Authorization: Bearer ...` header.
class CustomerReviewsRemoteDatasource {
  final Dio _dio;

  CustomerReviewsRemoteDatasource(this._dio);

  Future<ReviewEntity> create(ReviewCreateParams params) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/me/reviews',
      data: params.toJson(),
    );
    return ReviewModel.fromJson(response.data ?? const {});
  }

  Future<List<ReviewEntity>> listMine({int limit = 50, int offset = 0}) async {
    final response = await _dio.get<List<dynamic>>(
      '/customers/me/reviews',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ReviewModel.fromJson)
        .toList();
  }

  Future<ReviewEntity> update(int reviewId, ReviewUpdateParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/customers/me/reviews/$reviewId',
      data: params.toJson(),
    );
    return ReviewModel.fromJson(response.data ?? const {});
  }

  Future<void> delete(int reviewId) async {
    await _dio.delete<void>('/customers/me/reviews/$reviewId');
  }
}
