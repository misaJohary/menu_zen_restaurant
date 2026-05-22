class CustomerReservationCreateParams {
  final int restaurantId;
  final DateTime reservedAt;
  final String phone;
  final int partySize;
  final String? note;

  const CustomerReservationCreateParams({
    required this.restaurantId,
    required this.reservedAt,
    required this.phone,
    required this.partySize,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'restaurant_id': restaurantId,
        'reserved_at': reservedAt.toUtc().toIso8601String(),
        'phone': phone,
        'party_size': partySize,
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}
