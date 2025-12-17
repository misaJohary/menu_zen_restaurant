import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/order_count_entity.dart';

part 'order_count_model.g.dart';

@JsonSerializable()
class DailyOrderCountModel extends DailyOrderCount {
  const DailyOrderCountModel({required super.date, required super.count});

  factory DailyOrderCountModel.fromJson(Map<String, dynamic> json) =>
      _$DailyOrderCountModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyOrderCountModelToJson(this);
}

@JsonSerializable()
class OrderCountModel extends OrderCountEntity {
  @override
  final List<DailyOrderCountModel> dailyCounts;

  const OrderCountModel({
    required this.dailyCounts,
    required super.totalCount, required super.todayCount, required super.meanCount,
  });

  factory OrderCountModel.fromJson(Map<String, dynamic> json) =>
      _$OrderCountModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderCountModelToJson(this);
}