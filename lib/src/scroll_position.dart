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

  /// Creates a new [ScrollPosition] from a key set scrolling forward.
  static KeysetScrollPosition forward(Map<String, dynamic> keys) =>
      KeysetScrollPosition.of(keys, ScrollDirection.forward);

  /// Creates a new [ScrollPosition] from a key set scrolling backward.
  static KeysetScrollPosition backward(Map<String, dynamic> keys) =>
      KeysetScrollPosition.of(keys, ScrollDirection.backward);

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
      final keys = {for (final order in sort.orders) order.property: item[order.property]};

      return KeysetScrollPosition.of(keys, direction);
    };
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
