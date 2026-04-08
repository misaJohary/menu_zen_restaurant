import 'package:injectable/injectable.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/errors/multi_result.dart';
import 'package:domain/entities/order_count_entity.dart';
import 'package:domain/entities/revenues_entity.dart';
import 'package:domain/repositories/stats_repository.dart';

import 'package:data/errors/handle_exception.dart';
import 'package:data/http/rest_client.dart';
import 'package:domain/entities/list_top_menu_item.dart';

@LazySingleton(as: StatsRepository)
class StatsRepositoryImpl implements StatsRepository {
  final RestClient rest;

  StatsRepositoryImpl(this.rest);

  @override
  Future<MultiResult<Failure, RevenuesEntity>> getRevenue() async {
    return executeWithErrorHandling(() async {
      final res = await rest.getRevenue(days: 5);
      return res;
    });
  }

  @override
  Future<MultiResult<Failure, OrderCountEntity>> getTodayOrderCount() async {
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
