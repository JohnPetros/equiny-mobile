class PaginationResponse<Item> {
  final List<Item> _items;
  final int _itemsPerPage;
  final int _currentPage;
  final int _totalItems;
  final int _totalPages;

  PaginationResponse({
    List<Item> items = const [],
    int itemsPerPage = 0,
    int currentPage = 0,
    int totalItems = 0,
  }) : _items = items,
       _itemsPerPage = itemsPerPage,
       _currentPage = currentPage,
       _totalItems = totalItems,
       _totalPages = itemsPerPage > 0 ? (totalItems / itemsPerPage).ceil() : 0;

  List<Item> get items => _items;

  int get itemsPerPage => _itemsPerPage;

  int get currentPage => _currentPage;

  int get totalItems => _totalItems;

  int get totalPages => _totalPages;
}
