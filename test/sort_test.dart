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
}
