
import '../errors/failure.dart';

abstract class MultiResult<T extends Failure, E> {
  bool get isSuccess;
  bool get isFailure;

  T? get getError;
  E? get getSuccess;
}

class SuccessResult<T extends Failure, E> extends MultiResult<T, E> {
  final E data;

  SuccessResult(this.data);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T? get getError => null;

  @override
  E? get getSuccess => data;
}

class FailureResult<T extends Failure, E> extends MultiResult<T, E> {
  final T failure;

  FailureResult(this.failure);

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T? get getError => failure;

  @override
  E? get getSuccess => null;
}
