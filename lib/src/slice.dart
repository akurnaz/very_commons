import 'page_request.dart';
import 'pageable.dart';
import 'sort.dart';

/// A slice of data that indicates whether there's a next or previous slice available.
/// Allows to obtain a [Pageable] to request a previous or next [Slice].
abstract class Slice<T> extends Iterable<T> {
  /// Returns the number of the current [Slice]. Is always non-negative.
  int get number;

  /// Returns the size of the [Slice].
  int get size;

  /// Returns the number of elements currently on this [Slice].
  int get numberOfElements;

  /// Returns the page content as [List].
  List<T> get content;

  /// Returns whether the [Slice] has content at all.
  bool get hasContent;

  /// Returns the sorting parameters for the [Slice].
  Sort get sort;

  /// Returns whether the current [Slice] is the first one.
  bool get isFirst;

  /// Returns whether the current [Slice] is the last one.
  bool get isLast;

  /// Returns if there is a next [Slice].
  bool get hasNext;

  /// Returns if there is a previous [Slice].
  bool get hasPrevious;

  /// Returns the [Pageable] that's been used to request the current [Slice].
  Pageable get pageable => PageRequest(pageNumber: number, pageSize: size, sort: sort);

  /// Returns the [Pageable] to request the next [Slice]. Can be [Unpaged] in case the
  /// current [Slice] is already the last one. Clients should check [hasNext] before calling this method.
  Pageable get nextPageable;

  /// Returns the [Pageable] to request the previous [Slice]. Can be [Unpaged] in case the
  /// current [Slice] is already the first one. Clients should check [hasPrevious] before calling this method.
  Pageable get previousPageable;

  /// Returns the [Pageable] describing the next slice or the one describing the current slice in case it's the
  /// last one.
  Pageable get nextOrLastPageable => hasNext ? nextPageable : pageable;

  /// Returns the [Pageable] describing the previous slice or the one describing the current slice in case it's the
  /// first one.
  Pageable get previousOrFirstPageable => hasPrevious ? previousPageable : pageable;

  /// Returns a new [Slice] with the content of the current one mapped by the given [toElement].
  @override
  Slice<U> map<U>(U Function(T e) toElement);
}

/// Abstract basis for [Slice] implementations.
abstract class Chunk<T> extends Slice<T> {
  @override
  final List<T> content;

  @override
  final Pageable pageable;

  /// Creates a new [Chunk] with given [content] and [pageable].
  Chunk({required List<T> content, required this.pageable}) : content = List.unmodifiable(content);

  @override
  int get number => pageable.isPaged ? pageable.pageNumber : 0;

  @override
  int get size => pageable.isPaged ? pageable.pageSize : content.length;

  @override
  int get numberOfElements => content.length;

  @override
  bool get hasPrevious => number > 0;

  @override
  bool get isFirst => !hasPrevious;

  @override
  bool get isLast => !hasNext;

  @override
  Pageable get nextPageable => hasNext ? pageable.next : Unpaged.unsorted;

  @override
  Pageable get previousPageable => hasPrevious ? pageable.previousOrFirst : Unpaged.unsorted;

  @override
  bool get hasContent => content.isNotEmpty;

  @override
  Sort get sort => pageable.sort;

  @override
  Iterator<T> get iterator => content.iterator;

  /// Applies the given [toElement] function to the content of this [Chunk].
  List<U> getConvertedContent<U>(U Function(T e) toElement) => content.map(toElement).toList();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Chunk<T>) return false;

    if (other.pageable != pageable) return false;
    if (other.content.length != content.length) return false;

    for (var i = 0; i < content.length; i++) {
      if (other.content[i] != content[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(pageable, Object.hashAll(content));
}

/// Default implementation of [Slice].
class SliceImpl<T> extends Chunk<T> {
  @override
  final bool hasNext;

  /// Creates a new [SliceImpl] with the given [content], [pageable] and [hasNext].
  SliceImpl({required super.content, super.pageable = Unpaged.unsorted, this.hasNext = false});

  @override
  Slice<U> map<U>(U Function(T e) toElement) =>
      SliceImpl<U>(content: getConvertedContent(toElement), pageable: pageable, hasNext: hasNext);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SliceImpl<T> && other.hasNext == hasNext && super == other;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, hasNext);

  @override
  String toString() {
    var contentType = 'UNKNOWN';

    if (content.isNotEmpty && content.first != null) {
      contentType = content.first.runtimeType.toString();
    }

    return 'Slice $number containing $contentType instances';
  }
}
