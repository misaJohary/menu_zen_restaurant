import 'package:menu_zen_restaurant/features/datasources/models/order_count_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/revenues_model.dart';

import '../../../core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';

import '../entities/list_top_menu_item.dart';

abstract class StatsRepository {
  Future<MultiResult<Failure, RevenuesModel>> getRevenue();

  Future<MultiResult<Failure, OrderCountModel>> getTodayOrderCount();

  Future<MultiResult<Failure, ListTopMenuItem>> getTopMenuItems();
}
