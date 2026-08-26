import 'pageable.dart';
import 'slice.dart';

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
    if (content.isNotEmpty && pageable.offset + pageable.pageSize > total) {
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
  Page<U> map<U>(U Function(T e) toElement) =>
      PageImpl<U>(content: getConvertedContent(toElement), pageable: pageable, total: _total);
}
