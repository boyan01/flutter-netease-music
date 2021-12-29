class SearchResult<T> {
  SearchResult({
    required this.result,
    required this.hasMore,
    required this.totalCount,
  });

  final T result;

  final bool hasMore;

  final int totalCount;

}
