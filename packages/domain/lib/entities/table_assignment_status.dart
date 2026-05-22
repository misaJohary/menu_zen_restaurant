/// Lifecycle of a table binding attached to a reservation.
///
/// API spelling uses `cancelled` (double l), distinct from the reservation
/// request's `canceled` (single l).
enum TableAssignmentStatus {
  active,
  honored,
  cancelled,
  noShow;

  String get apiValue => switch (this) {
        TableAssignmentStatus.active => 'active',
        TableAssignmentStatus.honored => 'honored',
        TableAssignmentStatus.cancelled => 'cancelled',
        TableAssignmentStatus.noShow => 'no_show',
      };

  static TableAssignmentStatus fromString(String? value) {
    switch (value) {
      case 'active':
        return TableAssignmentStatus.active;
      case 'honored':
        return TableAssignmentStatus.honored;
      case 'cancelled':
        return TableAssignmentStatus.cancelled;
      case 'no_show':
        return TableAssignmentStatus.noShow;
      default:
        return TableAssignmentStatus.active;
    }
  }
}
