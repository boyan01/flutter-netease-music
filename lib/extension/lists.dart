extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? get lastOrNull => isEmpty ? null : last;

  T? firstWhereOrNull(bool Function(T) test) =>
      cast<T?>().firstWhere((e) => test(e as T), orElse: () => null);
}
