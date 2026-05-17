import 'failures.dart';

class Result<T> {
  final T? _data;
  final Failure? _failure;

  const Result.success(this._data) : _failure = null;
  const Result.failure(this._failure) : _data = null;

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  T get data {
    if (isFailure) {
      throw StateError('Cannot get data from a failed Result');
    }
    return _data as T;
  }

  Failure get failure {
    if (isSuccess) {
      throw StateError('Cannot get failure from a successful Result');
    }
    return _failure!;
  }

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    if (isFailure) {
      return onFailure(_failure!);
    } else {
      return onSuccess(_data as T);
    }
  }
}
