import 'pageable.dart';
import 'sort.dart';

/// Abstract implementation of [Pageable].
abstract class AbstractPageRequest implements Pageable {
  @override
  final int pageNumber;

  @override
  final int pageSize;

  /// Creates a new [AbstractPageRequest]. Pages are zero indexed, thus providing 0 for [pageNumber] will
  /// return the first page.
  ///
  /// [pageNumber] must not be negative.
  /// [pageSize] must be greater than 0.
  const AbstractPageRequest({required this.pageNumber, required this.pageSize})
    : assert(pageNumber >= 0, 'Page index must not be less than zero'),
      assert(pageSize >= 1, 'Page size must not be less than one');

  @override
  bool get isPaged => true;

  @override
  bool get isUnpaged => !isPaged;

  @override
  int get offset => pageNumber * pageSize;

  @override
  bool get hasPrevious => pageNumber > 0;

  @override
  Pageable get previousOrFirst => hasPrevious ? previous : first;

  @override
  Pageable get next;

  /// Returns the [Pageable] requesting the previous page.
  Pageable get previous;

  @override
  Pageable get first;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AbstractPageRequest &&
        other.pageNumber == pageNumber &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode => Object.hash(pageNumber, pageSize);
}

/// Basic implementation of [Pageable].
class PageRequest extends AbstractPageRequest {
  @override
  final Sort sort;

  /// Creates a new [PageRequest] with sort parameters applied.
  ///
  /// [pageNumber] zero-based page number, must not be negative.
  /// [pageSize] the size of the page to be returned, must be greater than 0.
  /// [sort] sorting parameters, defaults to [Sort.unsorted].
  const PageRequest({super.pageNumber = 0, required super.pageSize, this.sort = Sort.unsorted});

  @override
  PageRequest get next => PageRequest(pageNumber: pageNumber + 1, pageSize: pageSize, sort: sort);

  @override
  PageRequest get previous => pageNumber == 0
      ? this
      : PageRequest(pageNumber: pageNumber - 1, pageSize: pageSize, sort: sort);

  @override
  PageRequest get first => PageRequest(pageNumber: 0, pageSize: pageSize, sort: sort);

  /// Creates a new [PageRequest] with [pageNumber] applied.
  @override
  PageRequest withPage(int pageNumber) =>
      PageRequest(pageNumber: pageNumber, pageSize: pageSize, sort: sort);

  /// Creates a new [PageRequest] with [Sort] applied.
  PageRequest withSort(Sort sort) =>
      PageRequest(pageNumber: pageNumber, pageSize: pageSize, sort: sort);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageRequest && super == other && other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, sort);

  @override
  String toString() {
    return 'Page request [number: $pageNumber, size: $pageSize, sort: $sort]';
  }
}
