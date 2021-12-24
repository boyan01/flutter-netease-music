extension IterableExtension2<T> on Iterable<T> {
  Iterable<T> separated(T toInsert) sync* {
    var i = 0;
    for (final item in this) {
      if (i != 0) {
        yield toInsert;
      }
      yield item;
      i++;
    }
  }
}
