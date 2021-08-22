/// A pair of values.
class Pair<E, F> {
  Pair(this.first, this.last);

  final E first;
  final F last;

  @override
  String toString() => '($first, $last)';
}
