/// How the customer wants to receive the order.
///
/// `delivery` requires `deliveryAddress` and `contactPhone` on creation
/// (API §6.1). `dineIn` requires a `restaurantTableId`. `pickup` ignores
/// both.
enum CustomerOrderType {
  dineIn,
  pickup,
  delivery;

  String get apiValue => switch (this) {
        CustomerOrderType.dineIn => 'dine_in',
        CustomerOrderType.pickup => 'pickup',
        CustomerOrderType.delivery => 'delivery',
      };

  static CustomerOrderType fromString(String? value) {
    return switch (value) {
      'dine_in' => CustomerOrderType.dineIn,
      'pickup' => CustomerOrderType.pickup,
      'delivery' => CustomerOrderType.delivery,
      _ => CustomerOrderType.delivery,
    };
  }
}
