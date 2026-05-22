class CustomerOrderItemCreateParams {
  final int menuItemId;
  final int quantity;
  final String? note;

  const CustomerOrderItemCreateParams({
    required this.menuItemId,
    required this.quantity,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'menu_item_id': menuItemId,
        'quantity': quantity,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}
