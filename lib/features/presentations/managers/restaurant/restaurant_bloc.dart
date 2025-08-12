import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/features/domains/entities/restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/restaurant_repository.dart';

import '../../../../core/enums/bloc_status.dart';

part 'restaurant_event.dart';

part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository restaurant;

  RestaurantBloc({required this.restaurant}) : super(RestaurantState()) {
    on<RestaurantCreated>(_onRestaurantCreated);
    on<RestaurantInfoFilled>(_onRestaurantInfoFilled);
  }

  _onRestaurantInfoFilled(
    RestaurantInfoFilled event,
    Emitter<RestaurantState> emit,
  ) {
    emit(state.copyWith(restaurant: event.restaurant));
    Logger().i(event.restaurant);
  }

  _onRestaurantCreated(
    RestaurantCreated event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await restaurant.createRestaurant(event.userRestaurant);
    if (res.isSuccess) {
      return emit(
        state.copyWith(
          status: BlocStatus.loaded,
          restaurant: res.getSuccess?.restaurant,
        ),
      );
    } else if (res.isFailure) {
      Logger().e('failed: ${res.getError?.message}');
      return emit(
        state.copyWith(
          status: BlocStatus.failed,
          restaurant: res.getSuccess?.restaurant,
        ),
      );
    }
  }
}
