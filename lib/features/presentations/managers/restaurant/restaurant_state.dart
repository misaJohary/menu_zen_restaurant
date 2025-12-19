part of 'restaurant_bloc.dart';

class RestaurantState extends Equatable {
  const RestaurantState({
    this.restaurantFilled = false,
    this.restaurantMoreInfoFilled = false,
    this.userFilled = false,
    this.userRestaurant,
    this.status = BlocStatus.init,
  });

  final UserRestaurantEntity? userRestaurant;
  final BlocStatus status;
  final bool restaurantFilled;
  final bool restaurantMoreInfoFilled;
  final bool userFilled;

  RestaurantState copyWith({
    UserRestaurantEntity? userRestaurant,
    BlocStatus? status,
    bool? restaurantFilled,
    bool? restaurantMoreInfoFilled,
    bool? userFilled,
  }) {
    return RestaurantState(
      userRestaurant: userRestaurant ?? this.userRestaurant,
      status: status ?? this.status,
      restaurantFilled: restaurantFilled ?? this.restaurantFilled,
      restaurantMoreInfoFilled: restaurantMoreInfoFilled ?? this.restaurantMoreInfoFilled,
      userFilled: userFilled ?? this.userFilled,
    );
  }

  @override
  List<Object?> get props => [
    userRestaurant,
    status,
    restaurantFilled,
    restaurantMoreInfoFilled,
    userFilled,
  ];
}