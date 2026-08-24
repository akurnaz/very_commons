import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('Direction', () {
    test('isAscending and isDescending properties', () {
      expect(Direction.asc.isAscending, isTrue);
      expect(Direction.asc.isDescending, isFalse);

      expect(Direction.desc.isAscending, isFalse);
      expect(Direction.desc.isDescending, isTrue);
    });

    test('fromString parses correctly and is case-insensitive', () {
      expect(Direction.fromString('asc'), Direction.asc);
      expect(Direction.fromString('ASC'), Direction.asc);
      expect(Direction.fromString('Asc'), Direction.asc);
      expect(Direction.fromString('desc'), Direction.desc);
      expect(Direction.fromString('DESC'), Direction.desc);
      expect(Direction.fromString('Desc'), Direction.desc);

      expect(() => Direction.fromString('invalid'), throwsA(isA<ArgumentError>()));
    });
  });

  group('Order', () {
    test('asc creates an Order with Direction.asc', () {
      const order = Order.asc('name');
      expect(order.property, equals('name'));
      expect(order.direction, equals(Direction.asc));
    });

    test('desc creates an Order with Direction.desc', () {
      const order = Order.desc('createdAt');
      expect(order.property, equals('createdAt'));
      expect(order.direction, equals(Direction.desc));
    });
  });
}
