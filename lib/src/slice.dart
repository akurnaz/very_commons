import 'pageable.dart';
import 'sort.dart';

abstract class Slice<T> {
  int get number;

  int get size;

  int get numberOfElements;

  List<T> get content;

  bool hasContent();

  Sort get sort;

  bool isFirst();

  bool isLast();

  bool hasNext();

  bool hasPrevious();

  Pageable? nextPageable();

  Pageable? previousPageable();

  Slice<U> map<U>(U Function(T e) toElement);
}

abstract class Chunk<T> implements Slice<T> {
  final List<T> _content;
  final Pageable pageable;

  const Chunk({required this._content, required this.pageable});

  @override
  int get number => pageable.pageNumber;

  @override
  int get size => pageable.pageSize;

  @override
  int get numberOfElements => content.length;

  @override
  List<T> get content => _content;

  @override
  bool hasContent() => content.isNotEmpty;

  @override
  Sort get sort => pageable.sort;

  @override
  bool isFirst() => !hasPrevious();

  @override
  bool isLast() => !hasNext();

  @override
  bool hasPrevious() => number > 0;

  @override
  Pageable? nextPageable() => hasNext() ? pageable.next() : null;

  @override
  Pageable? previousPageable() => hasPrevious() ? pageable.previousOrFirst() : null;

  List<U> getConvertedContent<U>(U Function(T e) toElement) => content.map(toElement).toList();
}

class SliceImpl<T> extends Chunk<T> {
  final bool _hasNext;

  const SliceImpl({required super.content, required super.pageable, required this._hasNext});

  @override
  bool hasNext() => _hasNext;

  @override
  Slice<U> map<U>(U Function(T e) toElement) =>
      SliceImpl<U>(content: getConvertedContent(toElement), pageable: pageable, hasNext: _hasNext);
}
