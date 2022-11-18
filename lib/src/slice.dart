import 'order.dart';
import 'pageable.dart';

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
  final List<T> _content = [];
  final Pageable _pageable;

  Chunk({required List<T> content, required Pageable pageable}) : _pageable = pageable {
    this.content.addAll(content);
  }

  @override
  int get number => _pageable.page;

  @override
  int get size => _pageable.size;

  @override
  int get numberOfElements => content.length;

  @override
  List<T> get content => _content;

  @override
  bool hasContent() => content.isNotEmpty;

  @override
  Sort get sort => _pageable.sort;

  @override
  bool isFirst() => !hasPrevious();

  @override
  bool isLast() => !hasNext();

  @override
  bool hasPrevious() => number > 0;

  @override
  Pageable? nextPageable() => hasNext() ? _pageable.next() : null;

  @override
  Pageable? previousPageable() => hasPrevious() ? _pageable.previous() : null;

  List<U> getConvertedContent<U>(U Function(T e) toElement) => content.map(toElement).toList();
}

class SliceImpl<T> extends Chunk<T> {
  final bool _hasNext;

  SliceImpl({required super.content, required super.pageable, required bool hasNext})
      : _hasNext = hasNext;

  @override
  bool hasNext() => _hasNext;

  @override
  Slice<U> map<U>(U Function(T e) toElement) => SliceImpl<U>(
        content: getConvertedContent(toElement),
        pageable: _pageable,
        hasNext: _hasNext,
      );
}

abstract class Page<T> extends Slice<T> {
  int get totalPages;

  int get totalElements;

  factory Page.empty(Pageable pageable) {
    return PageImpl<T>(content: [], pageable: pageable, total: 0);
  }

  @override
  Page<U> map<U>(U Function(T e) toElement);
}

class PageImpl<T> extends Chunk<T> implements Page<T> {
  late final int _total;

  PageImpl({required List<T> content, required Pageable pageable, required int total})
      : super(content: content, pageable: pageable) {
    if (content.isNotEmpty && pageable.offset + pageable.size > total) {
      _total = pageable.offset + content.length;
    } else {
      _total = total;
    }
  }

  @override
  int get totalPages => size == 0 ? 1 : (_total / size).ceil();

  @override
  int get totalElements => _total;

  @override
  bool hasNext() => number + 1 < totalPages;

  @override
  bool isLast() => !hasNext();

  @override
  Page<U> map<U>(U Function(T e) toElement) => PageImpl<U>(
        content: getConvertedContent(toElement),
        pageable: _pageable,
        total: _total,
      );
}
