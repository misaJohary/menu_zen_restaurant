import '../entities/list_top_menu_item.dart';
import '../entities/order_count_entity.dart';
import '../entities/revenues_entity.dart';
import '../errors/failure.dart';
import '../errors/multi_result.dart';

abstract class StatsRepository {
  Future<MultiResult<Failure, RevenuesEntity>> getRevenue();
  Future<MultiResult<Failure, OrderCountEntity>> getTodayOrderCount();
  Future<MultiResult<Failure, ListTopMenuItem>> getTopMenuItems();
}
