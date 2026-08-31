import 'pageable.dart';
import 'slice.dart';

/// A page is a sublist of a list of objects. It allows gaining information about
/// the position of it in the containing entire list.
abstract class Page<T> extends Slice<T> {
  /// Returns the number of total pages.
  int get totalPages;

  /// Returns the total amount of elements.
  int get totalElements;

  /// Returns a new [Page] with the content of the current one mapped by the given [toElement].
  @override
  Page<U> map<U>(U Function(T e) toElement);
}

/// Basic [Page] implementation.
class PageImpl<T> extends Chunk<T> implements Page<T> {
  final int _total;

  /// Creates a new [PageImpl] with the given [content], [pageable] and [total].
  ///
  /// The [total] might be adapted considering the length of the [content] given,
  /// if it is going to be the content of the last page. This is in place to mitigate inconsistencies.
  PageImpl({required super.content, super.pageable = Unpaged.unsorted, int? total})
    : _total = _computeTotal(content, pageable, total);

  static int _computeTotal(List<Object?> content, Pageable pageable, int? total) {
    final effectiveTotal = total ?? content.length;

    if (pageable.isPaged &&
        content.isNotEmpty &&
        pageable.offset + pageable.pageSize > effectiveTotal) {
      return pageable.offset + content.length;
    }

    return effectiveTotal;
  }

  @override
  int get totalPages => size == 0 ? 1 : (_total / size).ceil();

  @override
  int get totalElements => _total;

  @override
  bool get hasNext => number + 1 < totalPages;

  @override
  bool get isLast => !hasNext;

  @override
  Page<U> map<U>(U Function(T e) toElement) =>
      PageImpl<U>(content: getConvertedContent(toElement), pageable: pageable, total: _total);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageImpl<T> && other._total == _total && super == other;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _total);

  @override
  String toString() {
    var contentType = 'UNKNOWN';

    if (content.isNotEmpty && content.first != null) {
      contentType = content.first.runtimeType.toString();
    }

    return 'Page ${number + 1} of $totalPages containing $contentType instances';
  }
}
