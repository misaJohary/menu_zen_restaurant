part of 'restaurant_bloc.dart';

class RestaurantState extends Equatable {
  const RestaurantState({
    this.restaurantFilled = false,
    this.restaurantMoreInfoFilled = false,
    this.userFilled = false,
    this.userRestaurant,
    this.status = BlocStatus.init,
    this.navigationNonce = 0,
  });

  final UserRestaurantEntity? userRestaurant;
  final BlocStatus status;
  final bool restaurantFilled;
  final bool restaurantMoreInfoFilled;
  final bool userFilled;
  final int navigationNonce;

  RestaurantState copyWith({
    UserRestaurantEntity? userRestaurant,
    BlocStatus? status,
    bool? restaurantFilled,
    bool? restaurantMoreInfoFilled,
    bool? userFilled,
    int? navigationNonce,
  }) {
    return RestaurantState(
      userRestaurant: userRestaurant ?? this.userRestaurant,
      status: status ?? this.status,
      restaurantFilled: restaurantFilled ?? this.restaurantFilled,
      restaurantMoreInfoFilled: restaurantMoreInfoFilled ?? this.restaurantMoreInfoFilled,
      userFilled: userFilled ?? this.userFilled,
      navigationNonce: navigationNonce ?? this.navigationNonce,
    );
  }

  @override
  List<Object?> get props => [
    userRestaurant,
    status,
    restaurantFilled,
    restaurantMoreInfoFilled,
    userFilled,
    navigationNonce,
  ];
}