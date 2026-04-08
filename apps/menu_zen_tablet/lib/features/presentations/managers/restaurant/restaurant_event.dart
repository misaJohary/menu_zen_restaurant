part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();
}

class RestaurantCreated extends RestaurantEvent {
  const RestaurantCreated();

  @override
  List<Object?> get props => [];
}

class RestaurantInfoFilled extends RestaurantEvent {
  final RestaurantEntity restaurant;

  const RestaurantInfoFilled(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

class RestaurantMoreInfoFilled extends RestaurantEvent {
  final Map<String, dynamic> datas;

  const RestaurantMoreInfoFilled(this.datas);

  @override
  List<Object?> get props => [datas];
}

class RestaurantUserInfoFilled extends RestaurantEvent {
  final UserEntity user;

  const RestaurantUserInfoFilled(this.user);

  @override
  List<Object?> get props => [user];
}
