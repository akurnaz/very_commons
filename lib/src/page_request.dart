import 'pageable.dart';
import 'sort.dart';

class PageRequest implements Pageable {
  @override
  final int pageNumber;

  @override
  final int pageSize;

  @override
  final Sort sort;

  const PageRequest({required this.pageNumber, required this.pageSize, this.sort = Sort.unsorted})
    : assert(pageNumber >= 0, "Page index must not be less than zero!"),
      assert(pageSize >= 1, "Page size must not be less than one!");

  @override
  bool get isPaged => true;

  @override
  bool get isUnpaged => !isPaged;

  @override
  int get offset => pageNumber * pageSize;

  @override
  PageRequest next() => PageRequest(pageNumber: pageNumber + 1, pageSize: pageSize, sort: sort);

  PageRequest previous() => pageNumber == 0
      ? this
      : PageRequest(pageNumber: pageNumber - 1, pageSize: pageSize, sort: sort);

  @override
  PageRequest previousOrFirst() => hasPrevious() ? previous() : first();

  @override
  PageRequest first() => PageRequest(pageNumber: 0, pageSize: pageSize, sort: sort);

  @override
  Pageable withPage(int page) => PageRequest(pageNumber: page, pageSize: pageSize, sort: sort);

  @override
  bool hasPrevious() => pageNumber > 0;
}
