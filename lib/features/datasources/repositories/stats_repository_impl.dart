import 'package:injectable/injectable.dart';
import 'package:menu_zen_restaurant/core/errors/failure.dart';
import 'package:menu_zen_restaurant/core/http_connexion/multi_result.dart';
import 'package:menu_zen_restaurant/features/datasources/models/order_count_model.dart';
import 'package:menu_zen_restaurant/features/datasources/models/revenues_model.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/stats_repository.dart';

import '../../../core/errors/handle_exception.dart';
import '../../../core/http_connexion/rest_client.dart';
import '../../domains/entities/list_top_menu_item.dart';

@LazySingleton(as: StatsRepository)
class StatsRepositoryImpl implements StatsRepository {
  final RestClient rest;

  StatsRepositoryImpl(this.rest);

  @override
  Future<MultiResult<Failure, RevenuesModel>> getRevenue() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getRevenue(days: 5);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, OrderCountModel>> getTodayOrderCount() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getOrderCountToday(days: 5);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, ListTopMenuItem>> getTopMenuItems() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getTopMenuItems();
      return ListTopMenuItem.create(res);
    });
  }
}
