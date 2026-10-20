sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(T value) onSuccess,
    R Function(AppFailure failure) onFailure,
  ) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failed<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);
  final AppFailure failure;
}

final class AppFailure {
  const AppFailure(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
