import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('Direction', () {
    group('isAscending and isDescending', () {
      test('returns correct boolean values', () {
        expect(Direction.asc.isAscending, isTrue);
        expect(Direction.asc.isDescending, isFalse);

        expect(Direction.desc.isAscending, isFalse);
        expect(Direction.desc.isDescending, isTrue);
      });
    });

    group('fromString()', () {
      test('parses correctly and is case-insensitive', () {
        expect(Direction.fromString('asc'), Direction.asc);
        expect(Direction.fromString('ASC'), Direction.asc);
        expect(Direction.fromString('Asc'), Direction.asc);
        expect(Direction.fromString('desc'), Direction.desc);
        expect(Direction.fromString('DESC'), Direction.desc);
        expect(Direction.fromString('Desc'), Direction.desc);

        expect(() => Direction.fromString('invalid'), throwsA(isA<ArgumentError>()));
      });
    });
  });

  group('Order', () {
    group('Order()', () {
      test('creates Order with default values', () {
        const order = Order('name');

        expect(order.property, 'name');
        expect(order.direction, Sort.defaultDirection);
        expect(order.isIgnoreCase, Order.defaultIgnoreCase);
        expect(order.nullHandling, Order.defaultNullHandling);
      });

      test('creates Order with custom values when provided', () {
        const order = Order(
          'name',
          direction: Direction.desc,
          isIgnoreCase: true,
          nullHandling: NullHandling.nullsFirst,
        );

        expect(order.property, 'name');
        expect(order.direction, Direction.desc);
        expect(order.isIgnoreCase, isTrue);
        expect(order.nullHandling, NullHandling.nullsFirst);
      });

      test('throws AssertionError when property is empty', () {
        expect(() => Order(''), throwsA(isA<AssertionError>()));
      });
    });

    group('Order.asc()', () {
      test('creates Order with Direction.asc and default values', () {
        const order = Order.asc('name');

        expect(order.property, 'name');
        expect(order.direction, Direction.asc);
        expect(order.isIgnoreCase, Order.defaultIgnoreCase);
        expect(order.nullHandling, Order.defaultNullHandling);
      });
    });

    group('Order.desc()', () {
      test('creates Order with Direction.desc and default values', () {
        const order = Order.desc('name');

        expect(order.property, 'name');
        expect(order.direction, Direction.desc);
        expect(order.isIgnoreCase, Order.defaultIgnoreCase);
        expect(order.nullHandling, Order.defaultNullHandling);
      });
    });

    group('isAscending and isDescending', () {
      test('returns correct boolean based on direction', () {
        const ascOrder = Order.asc('name');
        expect(ascOrder.isAscending, isTrue);
        expect(ascOrder.isDescending, isFalse);

        const descOrder = Order.desc('name');
        expect(descOrder.isAscending, isFalse);
        expect(descOrder.isDescending, isTrue);
      });
    });

    group('copyWith()', () {
      test('creates a copy with updated properties', () {
        const order = Order(
          'name',
          direction: Direction.asc,
          isIgnoreCase: false,
          nullHandling: NullHandling.native,
        );

        final updated = order.copyWith(
          property: 'subtitle',
          direction: Direction.desc,
          isIgnoreCase: true,
          nullHandling: NullHandling.nullsFirst,
        );

        expect(updated.property, 'subtitle');
        expect(updated.direction, Direction.desc);
        expect(updated.isIgnoreCase, isTrue);
        expect(updated.nullHandling, NullHandling.nullsFirst);
      });

      test('retains original values when properties are omitted', () {
        const order = Order(
          'name',
          direction: Direction.asc,
          isIgnoreCase: false,
          nullHandling: NullHandling.native,
        );

        final copy = order.copyWith();

        expect(copy.property, order.property);
        expect(copy.direction, order.direction);
        expect(copy.isIgnoreCase, order.isIgnoreCase);
        expect(copy.nullHandling, order.nullHandling);
      });
    });

    group('reverse()', () {
      test('returns new Order with reversed direction', () {
        const ascOrder = Order.asc('name');
        expect(ascOrder.reverse().direction, Direction.desc);

        const descOrder = Order.desc('name');
        expect(descOrder.reverse().direction, Direction.asc);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        const o1 = Order(
          'name',
          direction: Direction.asc,
          isIgnoreCase: false,
          nullHandling: NullHandling.native,
        );
        final o2 = o1.copyWith();

        expect(o1, equals(o1));
        expect(o1, equals(o2));
        expect(o1.hashCode, equals(o2.hashCode));

        expect(o1, isNot(equals(o1.copyWith(property: 'title'))));
        expect(o1, isNot(equals(o1.copyWith(direction: Direction.desc))));
        expect(o1, isNot(equals(o1.copyWith(isIgnoreCase: true))));
        expect(o1, isNot(equals(o1.copyWith(nullHandling: NullHandling.nullsFirst))));
      });
    });

    group('toString()', () {
      test('returns formatted string', () {
        expect(const Order.asc('name').toString(), 'name: asc');
        expect(const Order.desc('name').toString(), 'name: desc');
        expect(
          const Order.asc('name', nullHandling: NullHandling.nullsFirst).toString(),
          'name: asc, nullsFirst',
        );
        expect(const Order.asc('name', isIgnoreCase: true).toString(), 'name: asc, ignoring case');
        expect(
          const Order.asc(
            'name',
            nullHandling: NullHandling.nullsFirst,
            isIgnoreCase: true,
          ).toString(),
          'name: asc, nullsFirst, ignoring case',
        );
      });
    });
  });

  group('Sort', () {
    group('Sort.by()', () {
      test('creates Sort with given orders', () {
        final orders = [const Order.asc('name'), const Order.desc('createdAt')];
        final sort = Sort.by(orders);

        expect(sort.orders, orders);
        expect(sort.orders.length, 2);
        expect(sort.orders.first.property, 'name');
        expect(sort.orders.last.property, 'createdAt');
      });

      test('creates Sort with empty orders list', () {
        const sort = Sort.by([]);

        expect(sort.orders, isEmpty);
      });
    });
  });
}
