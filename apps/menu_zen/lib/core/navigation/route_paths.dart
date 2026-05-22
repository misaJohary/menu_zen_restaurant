class RoutePaths {
  RoutePaths._();

  static const String discover = '/discover';
  static const String search = '/search';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String restaurant = '/restaurant';
  static const String reservations = '/reservations';
  static const String orders = '/orders';

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';

  static String restaurantDetail(int id) => '$restaurant/$id';
  static String restaurantReserve(int id) => '$restaurant/$id/reserve';
  static String restaurantOrder(int id) => '$restaurant/$id/order';
  static String reservationDetail(int id) => '$reservations/$id';
  static String orderDetail(int id) => '$orders/$id';
}
