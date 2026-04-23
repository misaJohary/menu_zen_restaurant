import 'package:json_annotation/json_annotation.dart';

export 'package:design_system/design_system.dart'
    show primaryColor, grey, kspacing, categoryColors;

final resetFieldDuration = const Duration(milliseconds: 500);

enum RestaurantType {
  casual,
  fastfood,
  @JsonValue('fine_dining')
  fineDining;

  String get toName => switch (this) {
    RestaurantType.casual => "casual",
    RestaurantType.fastfood => "fastfood",
    RestaurantType.fineDining => "fine_dining",
  };

  @override
  String toString() => switch (this) {
    RestaurantType.casual => "Simple",
    RestaurantType.fastfood => "Gargotte",
    RestaurantType.fineDining => "Etoilé",
  };
}
