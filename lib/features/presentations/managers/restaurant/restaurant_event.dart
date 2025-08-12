part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();
}

class RestaurantCreated extends RestaurantEvent {
  final UserRestaurantEntity userRestaurant;

  const RestaurantCreated(this.userRestaurant);

  @override
  List<Object?> get props => [userRestaurant];
}

class RestaurantInfoFilled extends RestaurantEvent{
  final RestaurantEntity restaurant;

  const RestaurantInfoFilled(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}