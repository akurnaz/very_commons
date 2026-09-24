import 'sort.dart';

/// Keyset scrolling direction.
enum ScrollDirection {
  /// Forward (default) direction to scroll from the beginning of the results to their end.
  forward,

  /// Backward direction to scroll from the end of the results to their beginning.
  backward;

  ScrollDirection get reverse => this == forward ? backward : forward;
}

/// Interface to specify a position within a total query result. Scroll positions
/// are used to start scrolling from the beginning of a query result or to resume
/// scrolling from a given position within the query result.
abstract class ScrollPosition {
  /// Returns whether the current scroll position is the initial one.
  bool get isInitial;

  /// Creates a new initial [ScrollPosition] to start scrolling using keyset-queries.
  static KeysetScrollPosition keyset() => KeysetScrollPosition.initial();

  /// Creates a new [ScrollPosition] from an optional [offset].
  ///
  /// If [offset] is omitted or `null`, creates an initial [ScrollPosition] to
  /// start scrolling using offset / limit.
  ///
  /// Otherwise, creates a new [OffsetScrollPosition] with the given [offset].
  static OffsetScrollPosition offset([int? offset]) {
    return offset == null ? OffsetScrollPosition.initial() : OffsetScrollPosition.of(offset);
  }

  /// Creates a new [ScrollPosition] from a key set and [ScrollDirection].
  static KeysetScrollPosition of(
    Map<String, dynamic> keys, [
    ScrollDirection direction = ScrollDirection.forward,
  ]) => KeysetScrollPosition.of(keys, direction);
}

/// A [ScrollPosition] based on the offsets within query results.
///
/// An initial [OffsetScrollPosition] does not point to a specific element and is
/// different to a position [ScrollPosition.offset].
final class OffsetScrollPosition implements ScrollPosition {
  static const OffsetScrollPosition _initial = OffsetScrollPosition._(-1);

  final int _offset;

  /// Creates a new [OffsetScrollPosition] for the given non-negative offset.
  const OffsetScrollPosition._(this._offset);

  /// Creates a new initial [OffsetScrollPosition] to start scrolling using offset / limit.
  factory OffsetScrollPosition.initial() => _initial;

  /// Creates a new [OffsetScrollPosition] from an [offset].
  ///
  /// The [offset] must not be negative.
  factory OffsetScrollPosition.of(int offset) {
    if (offset < 0) {
      throw RangeError.value(offset, 'offset', 'Offset must not be negative');
    }

    return OffsetScrollPosition._(offset);
  }

  /// Returns a position function starting at [startOffset].
  ///
  /// The [startOffset] must not be negative.
  static OffsetScrollPosition Function(int offset) positionFunction(int startOffset) {
    if (startOffset < 0) {
      throw RangeError.value(startOffset, 'startOffset', 'Start offset must not be negative');
    }

    return (offset) {
      if (offset < 0) {
        throw RangeError.value(offset, 'offset', 'Offset must not be negative');
      }

      return OffsetScrollPosition.of(startOffset + offset);
    };
  }

  /// Returns the position function starting after the current [offset].
  OffsetScrollPosition Function(int offset) get nextPositionFunction =>
      positionFunction(_offset + 1);

  /// The zero or positive offset.
  ///
  /// An [isInitial] position does not define an offset and will throw a [StateError].
  int get offset {
    if (_offset < 0) {
      throw StateError('Initial state does not have an offset. Make sure to check isInitial.');
    }

    return _offset;
  }

  /// Returns a new [OffsetScrollPosition] that has been advanced by the given [delta].
  ///
  /// Negative deltas will be constrained so that the new offset is at least zero.
  OffsetScrollPosition advanceBy(int delta) {
    final value = isInitial ? delta : _offset + delta;

    return OffsetScrollPosition._(value < 0 ? 0 : value);
  }

  @override
  bool get isInitial => _offset == -1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OffsetScrollPosition && other._offset == _offset;
  }

  @override
  int get hashCode => _offset.hashCode;

  @override
  String toString() => 'OffsetScrollPosition [$_offset]';
}

/// A [ScrollPosition] based on the last seen key set. Keyset scrolling must be
/// associated with a [well-defined sort][Sort] to be able to extract the key
/// set when resuming scrolling within the sorted result set.
final class KeysetScrollPosition implements ScrollPosition {
  static const KeysetScrollPosition _emptyForward = KeysetScrollPosition._(
    {},
    ScrollDirection.forward,
  );

  static const KeysetScrollPosition _emptyBackward = KeysetScrollPosition._(
    {},
    ScrollDirection.backward,
  );

  /// The keyset.
  final Map<String, dynamic> keys;

  /// The scroll direction.
  final ScrollDirection direction;

  const KeysetScrollPosition._(this.keys, this.direction);

  /// Creates a new initial [KeysetScrollPosition] to start scrolling using keyset-queries.
  factory KeysetScrollPosition.initial() => _emptyForward;

  /// Creates a new [KeysetScrollPosition] from a key set and [ScrollDirection].
  factory KeysetScrollPosition.of(
    Map<String, dynamic> keys, [
    ScrollDirection direction = ScrollDirection.forward,
  ]) {
    return keys.isEmpty
        ? (direction == ScrollDirection.forward ? _emptyForward : _emptyBackward)
        : KeysetScrollPosition._(Map.unmodifiableOf(keys), direction);
  }

  static KeysetScrollPosition Function(int index) positionFunction(
    List<Map<String, dynamic>> items,
    Sort sort,
    ScrollDirection direction,
  ) {
    return (index) {
      final item = items[index];
      final keys = {
        for (final order in sort.orders) order.property: _extractValue(item, order.property),
      };

      return KeysetScrollPosition.of(keys, direction);
    };
  }

  static dynamic _extractValue(Map<String, dynamic> item, String property) {
    if (item.containsKey(property)) {
      return item[property];
    }
    if (!property.contains('.')) {
      return null;
    }
    dynamic current = item;
    for (final part in property.split('.')) {
      if (current is Map) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  KeysetScrollPosition Function(int index) getNextPositionFunction(
    List<Map<String, dynamic>> items,
    Sort sort,
  ) => positionFunction(items, sort, direction);

  /// Returns whether the current [KeysetScrollPosition] scrolls forward.
  bool get scrollsForward => direction == ScrollDirection.forward;

  /// Returns whether the current [KeysetScrollPosition] scrolls backward.
  bool get scrollsBackward => direction == ScrollDirection.backward;

  /// Returns a [KeysetScrollPosition] based on the same keyset and scrolling forward.
  KeysetScrollPosition get forward => direction == ScrollDirection.forward
      ? this
      : KeysetScrollPosition._(keys, ScrollDirection.forward);

  /// Returns a [KeysetScrollPosition] based on the same keyset and scrolling backward.
  KeysetScrollPosition get backward => direction == ScrollDirection.backward
      ? this
      : KeysetScrollPosition._(keys, ScrollDirection.backward);

  /// Returns a new [KeysetScrollPosition] with the direction reversed.
  KeysetScrollPosition get reverse => KeysetScrollPosition._(keys, direction.reverse);

  @override
  bool get isInitial => keys.isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KeysetScrollPosition) return false;
    if (other.direction != direction) return false;
    if (identical(other.keys, keys)) return true;
    if (other.keys.length != keys.length) return false;

    for (final entry in keys.entries) {
      if (!other.keys.containsKey(entry.key) || other.keys[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode {
    var keysHash = 0;
    for (final entry in keys.entries) {
      keysHash = (keysHash + Object.hash(entry.key, entry.value)) & 0x3fffffff;
    }

    return Object.hash(direction, keysHash);
  }

  @override
  String toString() => 'KeysetScrollPosition [$direction, $keys]';
}

/// A [ScrollPosition] based on an opaque cursor string pointing to a specific
/// element in a query result.
final class CursorScrollPosition implements ScrollPosition {
  static const CursorScrollPosition _emptyForward = CursorScrollPosition._(
    null,
    ScrollDirection.forward,
  );

  static const CursorScrollPosition _emptyBackward = CursorScrollPosition._(
    null,
    ScrollDirection.backward,
  );

  final String? _cursor;

  /// The scroll direction.
  final ScrollDirection direction;

  const CursorScrollPosition._(this._cursor, this.direction);

  /// Creates a new initial [CursorScrollPosition] to start scrolling using cursor-based pagination.
  factory CursorScrollPosition.initial() => _emptyForward;

  /// Creates a new [CursorScrollPosition] from an optional [cursor] and [ScrollDirection].
  ///
  /// If [cursor] is omitted or `null`, creates an initial [CursorScrollPosition]
  /// with the specified [direction].
  factory CursorScrollPosition.of(
    String? cursor, [
    ScrollDirection direction = ScrollDirection.forward,
  ]) {
    return cursor == null
        ? (direction == ScrollDirection.forward ? _emptyForward : _emptyBackward)
        : CursorScrollPosition._(cursor, direction);
  }

  /// Returns a position function that resolves [CursorScrollPosition]s for boundary items.
  ///
  /// The returned function extracts [beforeCursor] when [index] is `0` and
  /// [afterCursor] when [index] is `itemCount - 1`.
  ///
  /// Throws a [RangeError] if [index] is not `0` or `itemCount - 1`, or if no
  /// cursor is available for the requested index.
  static CursorScrollPosition Function(int index) positionFunction(
    int itemCount,
    ScrollDirection direction, {
    String? beforeCursor,
    String? afterCursor,
  }) {
    final lastIndex = itemCount - 1;

    return (index) {
      if (beforeCursor != null && index == 0) {
        return CursorScrollPosition.of(beforeCursor, direction);
      }

      if (afterCursor != null && index == lastIndex) {
        return CursorScrollPosition.of(afterCursor, direction);
      }

      throw RangeError.value(
        index,
        'index',
        beforeCursor == null && afterCursor == null
            ? 'No cursor is available for this window'
            : 'Cursor is only available for index 0 or $lastIndex',
      );
    };
  }

  /// Returns a position function using the current [direction] to resolve [CursorScrollPosition]s.
  CursorScrollPosition Function(int index) getPositionFunction(
    int itemCount, {
    String? beforeCursor,
    String? afterCursor,
  }) =>
      positionFunction(itemCount, direction, beforeCursor: beforeCursor, afterCursor: afterCursor);

  /// The cursor string.
  ///
  /// An [isInitial] position does not define a cursor and will throw a [StateError].
  String get cursor {
    if (_cursor == null) {
      throw StateError('Initial state does not have a cursor. Make sure to check isInitial.');
    }

    return _cursor;
  }

  /// Returns whether the current [CursorScrollPosition] scrolls forward.
  bool get scrollsForward => direction == ScrollDirection.forward;

  /// Returns whether the current [CursorScrollPosition] scrolls backward.
  bool get scrollsBackward => direction == ScrollDirection.backward;

  /// Returns a [CursorScrollPosition] based on the same cursor and scrolling forward.
  CursorScrollPosition get forward => direction == ScrollDirection.forward
      ? this
      : CursorScrollPosition._(_cursor, ScrollDirection.forward);

  /// Returns a [CursorScrollPosition] based on the same cursor and scrolling backward.
  CursorScrollPosition get backward => direction == ScrollDirection.backward
      ? this
      : CursorScrollPosition._(_cursor, ScrollDirection.backward);

  /// Returns a new [CursorScrollPosition] with the direction reversed.
  CursorScrollPosition get reverse => CursorScrollPosition._(_cursor, direction.reverse);

  @override
  bool get isInitial => _cursor == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CursorScrollPosition &&
        _cursor == other._cursor &&
        direction == other.direction;
  }

  @override
  int get hashCode => Object.hash(_cursor, direction);

  @override
  String toString() => 'CursorScrollPosition [$direction, $_cursor]';
}
