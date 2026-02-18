class PaginationResponse<Item> {
  final List<Item> _items;
  final String _nextCursor;
  final int _limit;

  PaginationResponse({
    List<Item> items = const [],
    String nextCursor = '',
    int limit = 0,
  }) : _items = items,
       _nextCursor = nextCursor,
       _limit = limit;

  List<Item> get items => _items;

  String get nextCursor => _nextCursor;

  int get limit => _limit;
}
