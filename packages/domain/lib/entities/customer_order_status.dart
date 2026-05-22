/// Lifecycle of a customer-placed order, as reported by the backend.
///
/// API values are snake_case (e.g. `in_preparation`). Use [apiValue] when
/// sending to the API and [fromString] when parsing responses.
enum CustomerOrderStatus {
  created,
  inPreparation,
  ready,
  served,
  cancelled;

  String get apiValue => switch (this) {
        CustomerOrderStatus.created => 'created',
        CustomerOrderStatus.inPreparation => 'in_preparation',
        CustomerOrderStatus.ready => 'ready',
        CustomerOrderStatus.served => 'served',
        CustomerOrderStatus.cancelled => 'cancelled',
      };

  static CustomerOrderStatus fromString(String? value) {
    return switch (value) {
      'created' => CustomerOrderStatus.created,
      'in_preparation' => CustomerOrderStatus.inPreparation,
      'ready' => CustomerOrderStatus.ready,
      'served' => CustomerOrderStatus.served,
      'cancelled' => CustomerOrderStatus.cancelled,
      _ => CustomerOrderStatus.created,
    };
  }

  bool get isTerminal =>
      this == CustomerOrderStatus.served ||
      this == CustomerOrderStatus.cancelled;

  /// Per API §6.4: cancel is only allowed while the order is still `created`.
  bool get canCancel => this == CustomerOrderStatus.created;
}
