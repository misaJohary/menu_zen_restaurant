import 'package:json_annotation/json_annotation.dart';
import 'package:menu_zen_restaurant/features/domains/entities/revenues_entity.dart';

part 'revenues_model.g.dart';

@JsonSerializable()
class DailyRevenueModel extends DailyRevenue {
  const DailyRevenueModel({required super.date, required super.revenue});

  factory DailyRevenueModel.fromJson(Map<String, dynamic> json) =>
      _$DailyRevenueModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRevenueModelToJson(this);
}

@JsonSerializable()
class RevenuesModel extends RevenuesEntity {
  @override
  final List<DailyRevenueModel> dailyRevenues;

  const RevenuesModel({
    required super.todayRevenue,
    required this.dailyRevenues,
    required super.totalRevenue,
    required super.diffPercentage,
  });

  factory RevenuesModel.fromJson(Map<String, dynamic> json) =>
      _$RevenuesModelFromJson(json);

  Map<String, dynamic> toJson() => _$RevenuesModelToJson(this);
}
