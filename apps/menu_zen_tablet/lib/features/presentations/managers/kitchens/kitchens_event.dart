part of 'kitchens_bloc.dart';

abstract class KitchensEvent extends Equatable {
  const KitchensEvent();

  @override
  List<Object?> get props => [];
}

class KitchensFetched extends KitchensEvent {
  const KitchensFetched();
}

class KitchenCreated extends KitchensEvent {
  final KitchenEntity kitchen;
  const KitchenCreated(this.kitchen);

  @override
  List<Object?> get props => [kitchen];
}

class KitchenUpdated extends KitchensEvent {
  final KitchenEntity kitchen;
  const KitchenUpdated(this.kitchen);

  @override
  List<Object?> get props => [kitchen];
}

class KitchenDeleted extends KitchensEvent {
  final int kitchenId;
  const KitchenDeleted(this.kitchenId);

  @override
  List<Object?> get props => [kitchenId];
}

class KitchenCookAssigned extends KitchensEvent {
  final int kitchenId;
  final int userId;
  const KitchenCookAssigned({required this.kitchenId, required this.userId});

  @override
  List<Object?> get props => [kitchenId, userId];
}

class KitchenCookRemoved extends KitchensEvent {
  final int kitchenId;
  final int userId;
  const KitchenCookRemoved({required this.kitchenId, required this.userId});

  @override
  List<Object?> get props => [kitchenId, userId];
}
