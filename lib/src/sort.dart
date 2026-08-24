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

class Order {
  final String property;
  final Direction direction;

  const Order.asc(this.property) : direction = Direction.asc;

  const Order.desc(this.property) : direction = Direction.desc;
}

class Sort {
  final List<Order> orders;

  const Sort.by(this.orders);
}
