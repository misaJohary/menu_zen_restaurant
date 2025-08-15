import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';
import 'package:menu_zen_restaurant/features/domains/entities/restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/entities/user_restaurant_entity.dart';
import 'package:menu_zen_restaurant/features/domains/repositories/restaurant_repository.dart';

import '../../../../core/enums/bloc_status.dart';
import '../../../domains/entities/user_entity.dart';

part 'restaurant_event.dart';

part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository restaurant;
  late RestaurantEntity _restaurantEntity;
  late UserEntity _userEntity;

  RestaurantBloc({required this.restaurant}) : super(RestaurantState()) {
    on<RestaurantCreated>(_onRestaurantCreated);
    on<RestaurantInfoFilled>(_onRestaurantInfoFilled);
    on<RestaurantUserInfoFilled>(_onRestaurantUserInfoFilled);
  }

  _onRestaurantUserInfoFilled(
    RestaurantUserInfoFilled event,
    Emitter<RestaurantState> emit,
  ) {
    _userEntity = event.user;
    emit(state.copyWith(userFilled: true));
  }

  _onRestaurantInfoFilled(
    RestaurantInfoFilled event,
    Emitter<RestaurantState> emit,
  ) {
    _restaurantEntity = event.restaurant;
    emit(state.copyWith(restaurantFilled: true));
  }

  _onRestaurantCreated(
    RestaurantCreated event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final userRestaurant = UserRestaurantEntity(
      user: _userEntity,
      restaurant: _restaurantEntity,
    );
    final res = await restaurant.createRestaurant(userRestaurant);
    if (res.isSuccess) {
      return emit(
        state.copyWith(
          status: BlocStatus.loaded,
          userRestaurant: res.getSuccess,
        ),
      );
    } else if (res.isFailure) {
      Logger().e('failed: ${res.getError?.message}');
      return emit(
        state.copyWith(
          status: BlocStatus.failed,
          //restaurant: res.getSuccess?.restaurant,
        ),
      );
    }
  }
}
