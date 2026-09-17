import 'scroll_position.dart';
import 'slice.dart';

/// A set of data consumed from an underlying query result.
///
/// A [Window] is similar to [Slice] in the sense that it contains a subset of
/// the actual query results for easier scrolling across large result sets.
/// The window is less opinionated about the actual data retrieval, whether the
/// query has used index/offset, keyset-based pagination or cursor resume tokens.
abstract class Window<T> {
  const Window();

  /// Construct a [Window].
  const factory Window.from(
    List<T> items,
    ScrollPosition Function(int index) positionFunction, {
    bool hasNext,
  }) = _WindowImpl<T>;

  /// Returns the window content as [List].
  List<T> get content;

  /// Returns whether the current window is the last one.
  bool get isLast => !hasNext;

  /// Returns whether there is a next window.
  bool get hasNext;

  /// Returns whether the underlying scroll mechanism can provide a
  /// [ScrollPosition] at [index].
  bool hasPosition(int index) {
    try {
      positionAt(index);
      return true;
    } on RangeError {
      return false;
    }
  }

  /// Returns the [ScrollPosition] at [index].
  ///
  /// Throws a [RangeError] if the [index] is out of range.
  ScrollPosition positionAt(int index);

  /// Returns the [ScrollPosition] for [object].
  ///
  /// Throws a [StateError] if the [object] is not part of the window.
  ScrollPosition positionOf(T object) {
    final index = content.indexOf(object);

    if (index == -1) {
      throw StateError('Element not found in window: $object');
    }

    return positionAt(index);
  }

  /// Returns a new [Window] with the content of the current one mapped by the
  /// given [converter].
  Window<U> map<U>(U Function(T element) converter);
}

/// Default [Window] implementation.
class _WindowImpl<T> extends Window<T> {
  final List<T> _items;

  final ScrollPosition Function(int index) _positionFunction;

  @override
  final bool hasNext;

  const _WindowImpl(this._items, this._positionFunction, {this.hasNext = false});

  @override
  List<T> get content => _items;

  @override
  ScrollPosition positionAt(int index) {
    if (index < 0 || index >= _items.length) {
      throw RangeError.index(index, _items, 'index');
    }

    return _positionFunction(index);
  }

  @override
  Window<U> map<U>(U Function(T element) converter) {
    return _WindowImpl<U>(_items.map(converter).toList(), _positionFunction, hasNext: hasNext);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _WindowImpl<T>) return false;

    if (_items.length != other._items.length) return false;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i] != other._items[i]) {
        return false;
      }
    }

    if (hasNext != other.hasNext) return false;

    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(_items), hasNext);

  @override
  String toString() => 'Window $_items';
}
