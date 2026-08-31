enum LoadStatus { idle, loading, success, empty, error }

/// Single representation of an asynchronous value used by every provider so
/// screens render loading, empty and error states consistently.
class LoadState<T> {
  final LoadStatus status;
  final T? data;
  final String message;

  const LoadState._(this.status, {this.data, this.message = ''});

  factory LoadState.idle() => LoadState<T>._(LoadStatus.idle);

  factory LoadState.loading() => LoadState<T>._(LoadStatus.loading);

  factory LoadState.success(T data) =>
      LoadState<T>._(LoadStatus.success, data: data);

  factory LoadState.empty() => LoadState<T>._(LoadStatus.empty);

  factory LoadState.error(String message) =>
      LoadState<T>._(LoadStatus.error, message: message);

  bool get isIdle => status == LoadStatus.idle;

  bool get isLoading => status == LoadStatus.loading;

  bool get isSuccess => status == LoadStatus.success;

  bool get isEmpty => status == LoadStatus.empty;

  bool get hasError => status == LoadStatus.error;
}

/// Collapses an empty list into [LoadStatus.empty] so screens never render an
/// empty scroll view where an empty state belongs.
LoadState<List<T>> listState<T>(List<T> items) => items.isEmpty
    ? LoadState<List<T>>.empty()
    : LoadState<List<T>>.success(items);
