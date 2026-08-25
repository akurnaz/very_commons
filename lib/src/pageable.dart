import 'page_request.dart';
import 'sort.dart';

/// Abstract class for pagination information.
abstract class Pageable {
  /// Returns a [Pageable] instance representing no pagination setup.
  ///
  /// If [sort] is provided, returns an unpaged [Pageable] instance considering the given [sort] order.
  factory Pageable.unpaged([Sort sort = Sort.unsorted]) {
    return Unpaged.sorted(sort);
  }

  /// Creates a new [Pageable] for the first page (page number `0`) given [pageSize].
  ///
  /// [pageSize] must be greater than 0.
  factory Pageable.ofSize(int pageSize) {
    return PageRequest(pageNumber: 0, pageSize: pageSize);
  }

  /// Returns whether the current [Pageable] contains pagination information.
  bool get isPaged;

  /// Returns whether the current [Pageable] does not contain pagination information.
  bool get isUnpaged;

  /// Returns the page to be returned.
  ///
  /// Throws [UnsupportedError] if the object [isUnpaged].
  int get pageNumber;

  /// Returns the number of items to be returned.
  ///
  /// Throws [UnsupportedError] if the object [isUnpaged].
  int get pageSize;

  /// Returns the offset to be taken according to the underlying page and page size.
  ///
  /// Throws [UnsupportedError] if the object [isUnpaged].
  int get offset;

  /// Returns the sorting parameters.
  Sort get sort;

  /// Returns the [Pageable] requesting the next page.
  Pageable next();

  /// Returns the previous [Pageable] or the first [Pageable] if the current one already is the first one.
  Pageable previousOrFirst();

  /// Returns the [Pageable] requesting the first page.
  Pageable first();

  /// Creates a new [Pageable] with [pageNumber] applied.
  ///
  /// Throws [UnsupportedError] if the object [isUnpaged] and [pageNumber] is not zero.
  Pageable withPage(int pageNumber);

  /// Returns whether there's a previous [Pageable] we can access from the current one.
  ///
  /// Will return `false` in case the current [Pageable] already refers to the first page.
  bool hasPrevious();
}

/// [Pageable] implementation to represent the absence of pagination information.
class Unpaged implements Pageable {
  static const Unpaged unsorted = Unpaged._(Sort.unsorted);

  @override
  final Sort sort;

  const Unpaged._(this.sort);

  /// Returns an [Unpaged] instance with the given [sort] order.
  factory Unpaged.sorted([Sort sort = Sort.unsorted]) {
    return sort.isSorted ? Unpaged._(sort) : unsorted;
  }

  @override
  bool get isPaged => false;

  @override
  bool get isUnpaged => !isPaged;

  @override
  int get pageNumber =>
      throw UnsupportedError('Instance of Unpaged does not support get pageNumber');

  @override
  int get pageSize => throw UnsupportedError('Instance of Unpaged does not support get pageSize');

  @override
  int get offset => throw UnsupportedError('Instance of Unpaged does not support get offset');

  @override
  Pageable next() => this;

  @override
  Pageable previousOrFirst() => this;

  @override
  Pageable first() => this;

  @override
  Pageable withPage(int pageNumber) {
    if (pageNumber == 0) {
      return this;
    }

    throw UnsupportedError(
      'Instance of Unpaged does not support withPage() with non-zero pageNumber',
    );
  }

  @override
  bool hasPrevious() => false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Unpaged && other.sort == sort;
  }

  @override
  int get hashCode => sort.hashCode;

  @override
  String toString() => sort.isSorted ? 'Unpaged.sorted($sort)' : 'unpaged';
}
