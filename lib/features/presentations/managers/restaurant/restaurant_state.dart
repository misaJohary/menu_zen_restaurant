part of 'restaurant_bloc.dart';

class RestaurantState extends Equatable {
  const RestaurantState({this.restaurant, this.status = BlocStatus.init});

  final RestaurantEntity? restaurant;
  final BlocStatus status;

  RestaurantState copyWith({RestaurantEntity? restaurant, BlocStatus? status}) {
    return RestaurantState(
      restaurant: restaurant ?? this.restaurant,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [restaurant, status];
}
