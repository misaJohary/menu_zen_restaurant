import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_params.g.dart';

@JsonSerializable(includeIfNull: false)
class OrderParams extends Equatable {
  final int? page;
  final int? limit;
  final bool todayOnly;

  const OrderParams({this.page, this.limit, this.todayOnly = true});

  @override
  List<Object?> get props => [page, limit, todayOnly];

  factory OrderParams.fromJson(Map<String, dynamic> json) =>
      _$OrderParamsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderParamsToJson(this);
}
