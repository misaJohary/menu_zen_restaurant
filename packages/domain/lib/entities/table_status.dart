enum TableStatus {
  free,
  reserved,
  waiting,
  assigned,
  dirty;

  static TableStatus fromString(String value) => TableStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => TableStatus.free,
  );
}
