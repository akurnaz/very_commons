/// Interface to specify a position within a total query result. Scroll positions
/// are used to start scrolling from the beginning of a query result or to resume
/// scrolling from a given position within the query result.
abstract class ScrollPosition {
  /// Returns whether the current scroll position is the initial one.
  bool get isInitial;

  /// Creates a new [ScrollPosition] from an optional [offset].
  ///
  /// If [offset] is omitted or `null`, creates an initial [ScrollPosition] to
  /// start scrolling using offset / limit.
  ///
  /// Otherwise, creates a new [OffsetScrollPosition] with the given [offset].
  factory ScrollPosition.offset([int? offset]) {
    return offset == null ? OffsetScrollPosition._initial : OffsetScrollPosition.of(offset);
  }
}

final class OffsetPositionFunction {
  static const OffsetPositionFunction zero = OffsetPositionFunction(0);

  final int startOffset;

  const OffsetPositionFunction(this.startOffset);

  OffsetScrollPosition apply(int offset) {
    if (offset < 0) {
      throw RangeError.value(offset, 'offset', 'Offset must not be negative');
    }

    return OffsetScrollPosition.of(startOffset + offset);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OffsetPositionFunction && other.startOffset == startOffset;
  }

  @override
  int get hashCode => startOffset.hashCode;

  @override
  String toString() => 'OffsetPositionFunction [$startOffset]';
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
  static OffsetPositionFunction positionFunction(int startOffset) {
    if (startOffset < 0) {
      throw RangeError.value(startOffset, 'startOffset', 'Start offset must not be negative');
    }

    return startOffset == 0 ? OffsetPositionFunction.zero : OffsetPositionFunction(startOffset);
  }

  /// Returns the position function starting after the current [offset].
  OffsetPositionFunction get nextPositionFunction => positionFunction(_offset + 1);

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
