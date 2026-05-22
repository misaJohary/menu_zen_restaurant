/// Lifecycle of a customer reservation REQUEST.
///
/// Distinct from [TableAssignmentStatus]: the request and the eventual table
/// binding are tracked independently. Spelling matters — the API uses
/// `canceled` (single l) for requests, but `cancelled` (double l) for table
/// bindings.
enum ReservationRequestStatus {
  waiting,
  accepted,
  refused,
  canceled;

  String get apiValue => name;

  static ReservationRequestStatus fromString(String? value) {
    if (value == null) return ReservationRequestStatus.waiting;
    return ReservationRequestStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ReservationRequestStatus.waiting,
    );
  }

  bool get isTerminal =>
      this == ReservationRequestStatus.refused ||
      this == ReservationRequestStatus.canceled;

  bool get canCancel =>
      this == ReservationRequestStatus.waiting ||
      this == ReservationRequestStatus.accepted;
}
