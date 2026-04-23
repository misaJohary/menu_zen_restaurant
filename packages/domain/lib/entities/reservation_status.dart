enum ReservationStatus {
  active,
  cancelled,
  completed;

  static ReservationStatus fromString(String value) =>
      ReservationStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => ReservationStatus.active,
      );
}
