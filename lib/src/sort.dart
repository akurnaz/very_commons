/// Enumeration for sort directions.
enum Direction {
  asc,
  desc;

  /// Returns whether the direction is ascending.
  bool get isAscending => this == Direction.asc;

  /// Returns whether the direction is descending.
  bool get isDescending => this == Direction.desc;

  /// Returns the [Direction] enum for the given [String] value (case-insensitive).
  ///
  /// Throws an [ArgumentError] if the value is invalid.
  static Direction fromString(String value) {
    final lower = value.trim().toLowerCase();

    if (lower == 'asc') {
      return Direction.asc;
    }

    if (lower == 'desc') {
      return Direction.desc;
    }

    throw ArgumentError.value(
      value,
      'value',
      "Invalid value '$value' for orders given; Has to be either 'desc' or 'asc' (case insensitive)",
    );
  }
}

/// Enumeration for null handling hints that can be used in [Order] expressions.
enum NullHandling {
  /// Lets the data store decide what to do with nulls.
  native,

  /// A hint to the data store to order entries with null values before non-null entries.
  nullsFirst,

  /// A hint to the data store to order entries with null values after non-null entries.
  nullsLast,
}

/// Property and [Direction] pairing used to define sorting criteria for a property.
class Order {
  static const bool defaultIgnoreCase = false;
  static const NullHandling defaultNullHandling = NullHandling.native;

  /// The property name to sort by.
  final String property;

  /// The sort direction for this property.
  final Direction direction;

  /// Whether sorting should be case-insensitive.
  final bool isIgnoreCase;

  /// The [NullHandling] hint for this property.
  final NullHandling nullHandling;

  /// Creates a new [Order] instance.
  ///
  /// [property] must not be empty.
  const Order(this.property, {Direction? direction, bool? isIgnoreCase, NullHandling? nullHandling})
    : direction = direction ?? Sort.defaultDirection,
      isIgnoreCase = isIgnoreCase ?? defaultIgnoreCase,
      nullHandling = nullHandling ?? defaultNullHandling,
      assert(property != '', 'Property must not be empty');

  /// Creates a new [Order] instance with [Direction.asc].
  const Order.asc(String property, {NullHandling? nullHandling, bool? isIgnoreCase})
    : this(
        property,
        direction: Direction.asc,
        isIgnoreCase: isIgnoreCase,
        nullHandling: nullHandling,
      );

  /// Creates a new [Order] instance with [Direction.desc].
  const Order.desc(String property, {NullHandling? nullHandling, bool? isIgnoreCase})
    : this(
        property,
        direction: Direction.desc,
        isIgnoreCase: isIgnoreCase,
        nullHandling: nullHandling,
      );

  /// Returns whether sorting for this property is ascending.
  bool get isAscending => direction.isAscending;

  /// Returns whether sorting for this property is descending.
  bool get isDescending => direction.isDescending;

  /// Creates a copy of this [Order] with the given fields replaced by non-null values.
  Order copyWith({
    String? property,
    Direction? direction,
    bool? isIgnoreCase,
    NullHandling? nullHandling,
  }) {
    return Order(
      property ?? this.property,
      direction: direction ?? this.direction,
      isIgnoreCase: isIgnoreCase ?? this.isIgnoreCase,
      nullHandling: nullHandling ?? this.nullHandling,
    );
  }

  /// Returns a new [Order] with reversed [direction].
  Order reverse() {
    return copyWith(direction: direction == Direction.asc ? Direction.desc : Direction.asc);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
        other.property == property &&
        other.direction == direction &&
        other.isIgnoreCase == isIgnoreCase &&
        other.nullHandling == nullHandling;
  }

  @override
  int get hashCode => Object.hash(property, direction, isIgnoreCase, nullHandling);

  @override
  String toString() {
    final buffer = StringBuffer('$property: ${direction.name}');

    if (nullHandling != NullHandling.native) {
      buffer.write(', ${nullHandling.name}');
    }

    if (isIgnoreCase) {
      buffer.write(', ignoring case');
    }

    return buffer.toString();
  }
}

class Sort {
  static const Direction defaultDirection = Direction.asc;

  final List<Order> orders;

  const Sort.by(this.orders);
}
