class RestaurantNotFoundException implements Exception {}

class MenuNotFoundException implements Exception{

}

class ItemNotFoundException implements Exception{
  final String message;
  ItemNotFoundException(this.message);
}