/// Enumeration for sort directions.
enum Direction {
  asc,
  desc;

  /// Returns whether the direction is ascending.
  bool get isAscending => this == .asc;

  /// Returns whether the direction is descending.
  bool get isDescending => this == .desc;

  /// Returns the [Direction] enum for the given [String] value (case-insensitive).
  ///
  /// Throws an [ArgumentError] if the value is invalid.
  factory Direction.fromString(String value) {
    final lower = value.trim().toLowerCase();

    if (lower == 'asc') {
      return .asc;
    }

    if (lower == 'desc') {
      return .desc;
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
  static const Direction defaultDirection = .asc;
  static const bool defaultIgnoreCase = false;
  static const NullHandling defaultNullHandling = .native;

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
    : direction = direction ?? defaultDirection,
      isIgnoreCase = isIgnoreCase ?? defaultIgnoreCase,
      nullHandling = nullHandling ?? defaultNullHandling,
      assert(property != '', 'Property must not be empty');

  /// Creates a new [Order] instance with [Direction.asc].
  const Order.asc(String property, {NullHandling? nullHandling, bool? isIgnoreCase})
    : this(property, direction: .asc, isIgnoreCase: isIgnoreCase, nullHandling: nullHandling);

  /// Creates a new [Order] instance with [Direction.desc].
  const Order.desc(String property, {NullHandling? nullHandling, bool? isIgnoreCase})
    : this(property, direction: .desc, isIgnoreCase: isIgnoreCase, nullHandling: nullHandling);

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
    return copyWith(direction: direction == .asc ? .desc : .asc);
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

    if (nullHandling != .native) {
      buffer.write(', ${nullHandling.name}');
    }

    if (isIgnoreCase) {
      buffer.write(', ignoring case');
    }

    return buffer.toString();
  }
}

/// Sort option for queries.
class Sort extends Iterable<Order> {
  /// Instance representing no sorting setup at all.
  static const Sort unsorted = Sort._([]);

  final List<Order> _orders;

  const Sort._(this._orders);

  /// Creates a new [Sort] instance with given [orders].
  factory Sort(List<Order> orders) {
    return orders.isEmpty ? unsorted : Sort._(List.unmodifiable(orders));
  }

  /// Creates a new [Sort] for the given [properties] and optional [direction].
  factory Sort.by(List<String> properties, {Direction? direction}) {
    final orders = properties.map((property) => Order(property, direction: direction)).toList();

    return Sort(orders);
  }

  /// Returns `true` if this Sort instance is sorted, `false` otherwise.
  bool get isSorted => isNotEmpty;

  /// Returns `true` if this Sort instance is unsorted, `false` otherwise.
  bool get isUnsorted => !isSorted;

  /// Returns a new [Sort] with the current setup but [Direction.desc].
  Sort descending() => _withDirection(.desc);

  /// Returns a new [Sort] with the current setup but [Direction.asc].
  Sort ascending() => _withDirection(.asc);

  /// Returns a new [Sort] consisting of the [Order]s of the current [Sort] combined with the given ones.
  Sort and(Sort sort) {
    if (sort.isEmpty) return this;
    if (isEmpty) return sort;

    return Sort([...this, ...sort]);
  }

  /// Returns a new [Sort] with reversed sort [Order]s turning ascending into descending and vice versa.
  Sort reverse() {
    return Sort(map((order) => order.reverse()).toList());
  }

  /// Returns the [Order] registered for the given [property], or `null` if not found.
  Order? getOrderFor(String property) {
    for (final order in this) {
      if (order.property == property) {
        return order;
      }
    }

    return null;
  }

  Sort _withDirection(Direction direction) {
    return Sort(map((order) => order.copyWith(direction: direction)).toList());
  }

  @override
  Iterator<Order> get iterator => _orders.iterator;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Sort) return false;
    if (_orders.length != other._orders.length) return false;

    for (var i = 0; i < _orders.length; i++) {
      if (_orders[i] != other._orders[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_orders);

  @override
  String toString() {
    return isEmpty ? 'unsorted' : _orders.join(', ');
  }
}
