part of 'kitchens_bloc.dart';

class KitchensState extends Equatable {
  final List<KitchenEntity> kitchens;
  final BlocStatus status;
  final Failure? failure;

  const KitchensState({
    this.kitchens = const [],
    this.status = BlocStatus.init,
    this.failure,
  });

  KitchensState copyWith({
    List<KitchenEntity>? kitchens,
    BlocStatus? status,
    Failure? failure,
  }) {
    return KitchensState(
      kitchens: kitchens ?? this.kitchens,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [kitchens, status, failure];
}
