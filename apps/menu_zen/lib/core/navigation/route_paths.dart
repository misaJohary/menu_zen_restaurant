class RoutePaths {
  RoutePaths._();

  static const String discover = '/discover';
  static const String search = '/search';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  static const String restaurant = '/restaurant';

  static String restaurantDetail(int id) => '$restaurant/$id';
}
