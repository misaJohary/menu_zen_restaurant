import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:domain/entities/kitchen_entity.dart';
import 'package:domain/errors/failure.dart';
import 'package:domain/repositories/kitchen_repository.dart';
import '../../../../core/enums/bloc_status.dart';

part 'kitchens_event.dart';
part 'kitchens_state.dart';

@injectable
class KitchensBloc extends Bloc<KitchensEvent, KitchensState> {
  final KitchenRepository repo;

  KitchensBloc(this.repo) : super(const KitchensState()) {
    on<KitchensFetched>(_onFetched);
    on<KitchenCreated>(_onCreated);
    on<KitchenUpdated>(_onUpdated);
    on<KitchenDeleted>(_onDeleted);
    on<KitchenCookAssigned>(_onCookAssigned);
    on<KitchenCookRemoved>(_onCookRemoved);
  }

  Future<void> _onFetched(
    KitchensFetched event,
    Emitter<KitchensState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.getKitchens();
    if (res.isSuccess) {
      emit(state.copyWith(status: BlocStatus.loaded, kitchens: res.getSuccess));
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onCreated(
    KitchenCreated event,
    Emitter<KitchensState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.createKitchen(event.kitchen);
    if (res.isSuccess) {
      add(const KitchensFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onUpdated(
    KitchenUpdated event,
    Emitter<KitchensState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.updateKitchen(event.kitchen);
    if (res.isSuccess) {
      add(const KitchensFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onDeleted(
    KitchenDeleted event,
    Emitter<KitchensState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.deleteKitchen(event.kitchenId);
    if (res.isSuccess) {
      add(const KitchensFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onCookAssigned(
    KitchenCookAssigned event,
    Emitter<KitchensState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.assignCook(event.kitchenId, event.userId);
    if (res.isSuccess) {
      add(const KitchensFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }

  Future<void> _onCookRemoved(
    KitchenCookRemoved event,
    Emitter<KitchensState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    final res = await repo.removeCook(event.kitchenId, event.userId);
    if (res.isSuccess) {
      add(const KitchensFetched());
    } else {
      emit(state.copyWith(status: BlocStatus.failed, failure: res.getError));
    }
  }
}
