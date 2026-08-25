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
        expect(Direction.fromString(' asc '), Direction.asc);
        expect(Direction.fromString('  desc  '), Direction.desc);

        expect(() => Direction.fromString('invalid'), throwsA(isA<ArgumentError>()));
      });
    });
  });

  group('Order', () {
    group('Order()', () {
      test('creates Order with default values', () {
        const order = Order('name');

        expect(order.property, 'name');
        expect(order.direction, Order.defaultDirection);
        expect(order.isIgnoreCase, Order.defaultIgnoreCase);
        expect(order.nullHandling, Order.defaultNullHandling);
      });

      test('creates Order with custom values when provided', () {
        const order = Order(
          'name',
          direction: .desc,
          isIgnoreCase: true,
          nullHandling: .nullsFirst,
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

      test('creates Order with custom nullHandling and isIgnoreCase', () {
        const order = Order.asc('name', nullHandling: .nullsFirst, isIgnoreCase: true);

        expect(order.property, 'name');
        expect(order.direction, Direction.asc);
        expect(order.isIgnoreCase, isTrue);
        expect(order.nullHandling, NullHandling.nullsFirst);
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

      test('creates Order with custom nullHandling and isIgnoreCase', () {
        const order = Order.desc('name', nullHandling: .nullsLast, isIgnoreCase: true);

        expect(order.property, 'name');
        expect(order.direction, Direction.desc);
        expect(order.isIgnoreCase, isTrue);
        expect(order.nullHandling, NullHandling.nullsLast);
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
        const order = Order('name', direction: .asc, isIgnoreCase: false, nullHandling: .native);

        final updated = order.copyWith(
          property: 'subtitle',
          direction: .desc,
          isIgnoreCase: true,
          nullHandling: .nullsFirst,
        );

        expect(updated.property, 'subtitle');
        expect(updated.direction, Direction.desc);
        expect(updated.isIgnoreCase, isTrue);
        expect(updated.nullHandling, NullHandling.nullsFirst);
      });

      test('retains original values when properties are omitted', () {
        const order = Order('name', direction: .asc, isIgnoreCase: false, nullHandling: .native);

        final copy = order.copyWith();

        expect(copy.property, order.property);
        expect(copy.direction, order.direction);
        expect(copy.isIgnoreCase, order.isIgnoreCase);
        expect(copy.nullHandling, order.nullHandling);
      });

      test('updates only specified property and retains the rest', () {
        const order = Order(
          'name',
          direction: .asc,
          isIgnoreCase: false,
          nullHandling: .nullsFirst,
        );

        final updated = order.copyWith(direction: .desc);

        expect(updated.property, order.property);
        expect(updated.direction, Direction.desc);
        expect(updated.isIgnoreCase, order.isIgnoreCase);
        expect(updated.nullHandling, order.nullHandling);
      });
    });

    group('reverse()', () {
      test('returns new Order with reversed direction', () {
        const ascOrder = Order.asc('name');
        expect(ascOrder.reverse().direction, Direction.desc);

        const descOrder = Order.desc('name');
        expect(descOrder.reverse().direction, Direction.asc);
      });

      test('preserves other fields when reversing', () {
        const order = Order('name', direction: .asc, isIgnoreCase: true, nullHandling: .nullsFirst);

        final reversed = order.reverse();

        expect(reversed.property, order.property);
        expect(reversed.direction, Direction.desc);
        expect(reversed.isIgnoreCase, order.isIgnoreCase);
        expect(reversed.nullHandling, order.nullHandling);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        const o1 = Order('name', direction: .asc, isIgnoreCase: false, nullHandling: .native);
        final o2 = o1.copyWith();

        expect(o1, equals(o1));
        expect(o1, equals(o2));
        expect(o1.hashCode, equals(o2.hashCode));

        expect(o1, isNot(equals(o1.copyWith(property: 'title'))));
        expect(o1, isNot(equals(o1.copyWith(direction: Direction.desc))));
        expect(o1, isNot(equals(o1.copyWith(isIgnoreCase: true))));
        expect(o1, isNot(equals(o1.copyWith(nullHandling: NullHandling.nullsFirst))));
        expect(o1, isNot(equals('not an order')));
      });
    });

    group('toString()', () {
      test('returns formatted string', () {
        expect(
          const Order.asc('name', nullHandling: .native, isIgnoreCase: false).toString(),
          'name: asc',
        );
        expect(
          const Order.asc('name', nullHandling: .nullsFirst, isIgnoreCase: false).toString(),
          'name: asc, nullsFirst',
        );
        expect(
          const Order.asc('name', nullHandling: .native, isIgnoreCase: true).toString(),
          'name: asc, ignoring case',
        );
        expect(
          const Order.asc('name', nullHandling: .nullsFirst, isIgnoreCase: true).toString(),
          'name: asc, nullsFirst, ignoring case',
        );
        expect(
          const Order.desc('name', nullHandling: .native, isIgnoreCase: false).toString(),
          'name: desc',
        );
        expect(
          const Order.desc('name', nullHandling: .nullsLast).toString(),
          'name: desc, nullsLast',
        );
        expect(
          const Order.desc('name', isIgnoreCase: true).toString(),
          'name: desc, ignoring case',
        );
        expect(
          const Order.desc('name', nullHandling: .nullsLast, isIgnoreCase: true).toString(),
          'name: desc, nullsLast, ignoring case',
        );
      });
    });
  });

  group('Sort', () {
    group('Sort.unsorted', () {
      test('is empty and unsorted', () {
        expect(Sort.unsorted.isEmpty, isTrue);
        expect(Sort.unsorted.isNotEmpty, isFalse);
        expect(Sort.unsorted.length, 0);
        expect(Sort.unsorted.isSorted, isFalse);
        expect(Sort.unsorted.isUnsorted, isTrue);
        expect(Sort.unsorted.toList(), isEmpty);
      });
    });

    group('Sort()', () {
      test('creates Sort with given orders', () {
        final orders = [const Order.asc('name'), const Order.desc('createdAt')];
        final sort = Sort(orders);

        expect(sort.length, 2);
        expect(sort.first.property, 'name');
        expect(sort.last.property, 'createdAt');
        expect(sort.toList(), orders);
      });

      test('returns Sort.unsorted when orders list is empty', () {
        final sort = Sort(const []);

        expect(sort, equals(Sort.unsorted));
        expect(identical(sort, Sort.unsorted), isTrue);
      });

      test('creates defensive copy with unmodifiable list', () {
        final original = [const Order.asc('name')];
        final sort = Sort(original);

        original.add(const Order.desc('createdAt'));

        expect(sort.length, 1);
        expect(sort.first.property, 'name');
      });
    });

    group('Sort.by()', () {
      test('creates Sort with default direction', () {
        final sort = Sort.by(['name', 'createdAt']);

        expect(sort.length, 2);
        expect(sort.first, const Order('name'));
        expect(sort.last, const Order('createdAt'));
      });

      test('creates Sort with specified direction', () {
        final sort = Sort.by(['name', 'createdAt'], direction: .desc);

        expect(sort.length, 2);
        expect(sort.first, const Order.desc('name'));
        expect(sort.last, const Order.desc('createdAt'));
      });

      test('returns Sort.unsorted when properties list is empty', () {
        final sort = Sort.by([]);

        expect(sort, equals(Sort.unsorted));
        expect(identical(sort, Sort.unsorted), isTrue);
      });
    });

    group('isSorted and isUnsorted', () {
      test('returns correct boolean values based on emptiness', () {
        final sorted = Sort([const Order.asc('name')]);
        expect(sorted.isSorted, isTrue);
        expect(sorted.isUnsorted, isFalse);

        const unsorted = Sort.unsorted;
        expect(unsorted.isSorted, isFalse);
        expect(unsorted.isUnsorted, isTrue);
      });
    });

    group('descending()', () {
      test('returns new Sort with all orders set to descending', () {
        final sort = Sort([
          const Order.asc('name', nullHandling: .nullsFirst, isIgnoreCase: true),
          const Order.desc('createdAt'),
        ]);

        final descendingSort = sort.descending();

        expect(descendingSort.length, 2);
        expect(
          descendingSort.first,
          const Order.desc('name', nullHandling: .nullsFirst, isIgnoreCase: true),
        );
        expect(descendingSort.last, const Order.desc('createdAt'));
      });

      test('returns unsorted when called on unsorted Sort', () {
        expect(Sort.unsorted.descending(), Sort.unsorted);
      });
    });

    group('ascending()', () {
      test('returns new Sort with all orders set to ascending', () {
        final sort = Sort([
          const Order.desc('name', nullHandling: .nullsFirst, isIgnoreCase: true),
          const Order.asc('createdAt'),
        ]);

        final ascendingSort = sort.ascending();

        expect(ascendingSort.length, 2);
        expect(
          ascendingSort.first,
          const Order.asc('name', nullHandling: .nullsFirst, isIgnoreCase: true),
        );
        expect(ascendingSort.last, const Order.asc('createdAt'));
      });

      test('returns unsorted when called on unsorted Sort', () {
        expect(Sort.unsorted.ascending(), Sort.unsorted);
      });
    });

    group('and()', () {
      test('combines two Sort instances', () {
        final sort1 = Sort([const Order.asc('name')]);
        final sort2 = Sort([const Order.desc('createdAt'), const Order.asc('age')]);

        final combined = sort1.and(sort2);

        expect(combined.length, 3);
        expect(combined.toList(), [
          const Order.asc('name'),
          const Order.desc('createdAt'),
          const Order.asc('age'),
        ]);
      });

      test('returns this when other Sort is empty', () {
        final sort = Sort([const Order.asc('name')]);

        expect(sort.and(Sort.unsorted), same(sort));
        expect(sort.and(Sort([])), same(sort));
      });

      test('returns other Sort when this Sort is empty', () {
        final sort = Sort([const Order.asc('name')]);

        expect(Sort.unsorted.and(sort), same(sort));
      });

      test('returns this when both Sorts are empty', () {
        final result = Sort.unsorted.and(Sort.unsorted);

        expect(result, same(Sort.unsorted));
      });
    });

    group('reverse()', () {
      test('returns new Sort with reversed order directions', () {
        final sort = Sort([
          const Order.asc('name', nullHandling: .nullsFirst, isIgnoreCase: true),
          const Order.desc('createdAt'),
        ]);

        final reversed = sort.reverse();

        expect(reversed.length, 2);
        expect(
          reversed.first,
          const Order.desc('name', nullHandling: .nullsFirst, isIgnoreCase: true),
        );
        expect(reversed.last, const Order.asc('createdAt'));
      });

      test('returns unsorted when called on unsorted Sort', () {
        expect(Sort.unsorted.reverse(), Sort.unsorted);
      });
    });

    group('getOrderFor()', () {
      test('returns Order for existing property', () {
        final sort = Sort([const Order.asc('name'), const Order.desc('createdAt')]);

        expect(sort.getOrderFor('name'), const Order.asc('name'));
        expect(sort.getOrderFor('createdAt'), const Order.desc('createdAt'));
      });

      test('returns null for non-existing property', () {
        final sort = Sort([const Order.asc('name')]);

        expect(sort.getOrderFor('nonExisting'), isNull);
        expect(Sort.unsorted.getOrderFor('name'), isNull);
      });

      test('returns first matching Order when property appears multiple times', () {
        final sort = Sort([const Order.asc('name'), const Order.desc('name')]);

        final result = sort.getOrderFor('name');

        expect(result, const Order.asc('name'));
        expect(result!.isAscending, isTrue);
      });
    });

    group('iterator', () {
      test('iterates over all orders and supports Iterable methods', () {
        final orders = [
          const Order.asc('name'),
          const Order.desc('createdAt'),
          const Order.asc('age'),
        ];
        final sort = Sort(orders);

        expect(sort.map((o) => o.property).toList(), ['name', 'createdAt', 'age']);
        expect(sort.where((o) => o.isAscending).length, 2);
        expect(sort.any((o) => o.property == 'age'), isTrue);

        final iterated = <Order>[];
        for (final order in sort) {
          iterated.add(order);
        }
        expect(iterated, orders);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        final s1 = Sort([const Order.asc('name'), const Order.desc('createdAt')]);
        final s2 = Sort([const Order.asc('name'), const Order.desc('createdAt')]);
        final s3 = Sort([const Order.asc('name')]);
        final s4 = Sort([const Order.desc('name'), const Order.asc('createdAt')]);
        final s5 = Sort([const Order.asc('title'), const Order.desc('createdAt')]);

        expect(s1, equals(s1));
        expect(s1, equals(s2));
        expect(s1.hashCode, equals(s2.hashCode));

        expect(s1, isNot(equals(s3)));
        expect(s1, isNot(equals(s4)));
        expect(s1, isNot(equals(s5)));
        expect(s1, isNot(equals('not a sort')));

        expect(Sort.unsorted, equals(Sort([])));
        expect(Sort.unsorted.hashCode, equals(Sort([]).hashCode));
      });
    });

    group('toString()', () {
      test('returns "unsorted" when empty', () {
        expect(Sort.unsorted.toString(), 'unsorted');
        expect(Sort([]).toString(), 'unsorted');
      });

      test('returns formatted string for single and multiple orders', () {
        expect(Sort([const Order.asc('name')]).toString(), 'name: asc');
        expect(
          Sort([const Order.asc('name'), const Order.desc('createdAt', nullHandling: .nullsFirst)])
              .toString(),
          'name: asc, createdAt: desc, nullsFirst',
        );
      });
    });
  });
}
