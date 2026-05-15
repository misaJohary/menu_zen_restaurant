import 'package:equatable/equatable.dart';

class OpeningHoursSlotEntity extends Equatable {
  final String open;
  final String close;

  const OpeningHoursSlotEntity({required this.open, required this.close});

  @override
  List<Object?> get props => [open, close];
}

class OpeningHoursEntity extends Equatable {
  final String? timezone;
  final Map<int, List<OpeningHoursSlotEntity>> periods;

  const OpeningHoursEntity({this.timezone, this.periods = const {}});

  @override
  List<Object?> get props => [timezone, periods];
}
