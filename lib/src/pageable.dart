import 'order.dart';

abstract class Pageable {
  int get page;

  int get size;

  int get offset;

  Sort get sort;

  Pageable next();

  Pageable previous();

  Pageable first();

  Pageable withPage(int pageNumber);

  bool hasPrevious();
}

class PageRequest implements Pageable {
  @override
  final int page;

  @override
  final int size;

  @override
  final Sort sort;

  PageRequest({required this.page, required this.size, required this.sort}) {
    if (page < 0) {
      throw ArgumentError("Page index must not be less than zero!");
    }

    if (size < 1) {
      throw ArgumentError("Page size must not be less than one!");
    }
  }

  @override
  int get offset => page * size;

  @override
  PageRequest next() => PageRequest(page: page + 1, size: size, sort: sort);

  @override
  PageRequest previous() => page == 0 ? this : PageRequest(page: page - 1, size: size, sort: sort);

  @override
  PageRequest first() => PageRequest(page: 0, size: size, sort: sort);

  @override
  Pageable withPage(int page) => PageRequest(page: page, size: size, sort: sort);

  @override
  bool hasPrevious() => page > 0;
}
