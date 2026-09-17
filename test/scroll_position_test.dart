import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('ScrollPosition', () {
    group('ScrollPosition.offset() factory', () {
      test('creates initial scroll position when offset is omitted', () {
        final position = ScrollPosition.offset();

        expect(position.isInitial, isTrue);
        expect(() => (position as OffsetScrollPosition).offset, throwsStateError);
      });

      test('creates initial scroll position when offset is null', () {
        final position = ScrollPosition.offset(null);

        expect(position.isInitial, isTrue);
        expect(() => (position as OffsetScrollPosition).offset, throwsStateError);
      });

      test('creates OffsetScrollPosition when valid non-negative offset is given', () {
        final position = ScrollPosition.offset(5);

        expect(position.isInitial, isFalse);
        expect(position, isA<OffsetScrollPosition>());
        expect((position as OffsetScrollPosition).offset, equals(5));
      });

      test('creates OffsetScrollPosition with zero offset', () {
        final position = ScrollPosition.offset(0);

        expect(position.isInitial, isFalse);
        expect((position as OffsetScrollPosition).offset, equals(0));
      });

      test('throws RangeError when negative offset is provided', () {
        expect(() => ScrollPosition.offset(-1), throwsRangeError);
        expect(() => ScrollPosition.offset(-10), throwsRangeError);
      });
    });
  });

  group('OffsetScrollPosition', () {
    group('OffsetScrollPosition.of()', () {
      test('creates instance with non-negative offset', () {
        final position = OffsetScrollPosition.of(10);

        expect(position.isInitial, isFalse);
        expect(position.offset, equals(10));
      });

      test('creates instance with zero offset', () {
        final position = OffsetScrollPosition.of(0);

        expect(position.isInitial, isFalse);
        expect(position.offset, equals(0));
      });

      test('throws RangeError when offset is negative', () {
        expect(
          () => OffsetScrollPosition.of(-1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              'message',
              contains('Offset must not be negative'),
            ),
          ),
        );
      });
    });

    group('isInitial', () {
      test('returns true for initial position', () {
        final initial = ScrollPosition.offset();
        expect(initial.isInitial, isTrue);
      });

      test('returns false for non-initial position', () {
        final position = OffsetScrollPosition.of(0);
        expect(position.isInitial, isFalse);
      });
    });

    group('offset getter', () {
      test('returns offset for non-initial position', () {
        expect(OffsetScrollPosition.of(42).offset, equals(42));
      });

      test('throws StateError with descriptive message on initial position', () {
        final initial = ScrollPosition.offset() as OffsetScrollPosition;

        expect(
          () => initial.offset,
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              'Initial state does not have an offset. Make sure to check isInitial.',
            ),
          ),
        );
      });
    });

    group('positionFunction()', () {
      test('returns function producing OffsetScrollPosition with startOffset + offset', () {
        final fn = OffsetScrollPosition.positionFunction(0);

        expect(fn(0).offset, equals(0));
        expect(fn(5).offset, equals(5));
      });

      test('returns function with positive startOffset', () {
        final fn = OffsetScrollPosition.positionFunction(15);

        expect(fn(0).offset, equals(15));
        expect(fn(5).offset, equals(20));
      });

      test('throws RangeError when startOffset is negative', () {
        expect(
          () => OffsetScrollPosition.positionFunction(-1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              'message',
              contains('Start offset must not be negative'),
            ),
          ),
        );
      });

      test('returned function throws RangeError when offset is negative', () {
        final fn = OffsetScrollPosition.positionFunction(10);

        expect(
          () => fn(-1),
          throwsA(
            isA<RangeError>().having(
              (e) => e.message,
              'message',
              contains('Offset must not be negative'),
            ),
          ),
        );
      });
    });

    group('nextPositionFunction', () {
      test('returns position function starting at offset + 1 for non-initial position', () {
        final position = OffsetScrollPosition.of(5);
        final nextFn = position.nextPositionFunction;

        expect(nextFn(0).offset, equals(6));
        expect(nextFn(2).offset, equals(8));
      });

      test('returns position function starting at 0 for initial position', () {
        final initial = ScrollPosition.offset() as OffsetScrollPosition;
        final nextFn = initial.nextPositionFunction;

        expect(nextFn(0).offset, equals(0));
        expect(nextFn(3).offset, equals(3));
      });
    });

    group('advanceBy()', () {
      test('advances non-initial position by positive delta', () {
        final position = OffsetScrollPosition.of(10);
        final advanced = position.advanceBy(5);

        expect(advanced.offset, equals(15));
        expect(advanced.isInitial, isFalse);
      });

      test('advances non-initial position by negative delta', () {
        final position = OffsetScrollPosition.of(10);
        final advanced = position.advanceBy(-3);

        expect(advanced.offset, equals(7));
        expect(advanced.isInitial, isFalse);
      });

      test('clamps non-initial position to 0 when negative delta exceeds offset', () {
        final position = OffsetScrollPosition.of(5);
        final advanced = position.advanceBy(-10);

        expect(advanced.offset, equals(0));
        expect(advanced.isInitial, isFalse);
      });

      test('advances initial position by positive delta', () {
        final initial = ScrollPosition.offset() as OffsetScrollPosition;
        final advanced = initial.advanceBy(8);

        expect(advanced.offset, equals(8));
        expect(advanced.isInitial, isFalse);
      });

      test('advances initial position by 0', () {
        final initial = ScrollPosition.offset() as OffsetScrollPosition;
        final advanced = initial.advanceBy(0);

        expect(advanced.offset, equals(0));
        expect(advanced.isInitial, isFalse);
      });

      test('clamps initial position to 0 when delta is negative', () {
        final initial = ScrollPosition.offset() as OffsetScrollPosition;
        final advanced = initial.advanceBy(-5);

        expect(advanced.offset, equals(0));
        expect(advanced.isInitial, isFalse);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        final pos1 = OffsetScrollPosition.of(5);
        final pos2 = OffsetScrollPosition.of(5);
        final pos3 = OffsetScrollPosition.of(10);
        final initial1 = ScrollPosition.offset() as OffsetScrollPosition;
        final initial2 = ScrollPosition.offset() as OffsetScrollPosition;

        expect(pos1 == pos1, isTrue);
        expect(pos1 == pos2, isTrue);
        expect(pos1.hashCode, equals(pos2.hashCode));

        expect(initial1 == initial2, isTrue);
        expect(initial1.hashCode, equals(initial2.hashCode));

        expect(pos1 == pos3, isFalse);
        expect(pos1 == initial1, isFalse);
        expect(initial1 == OffsetScrollPosition.of(0), isFalse);
        expect(pos1 == Object(), isFalse);
      });
    });

    group('toString()', () {
      test('returns formatted string for non-initial position', () {
        final position = OffsetScrollPosition.of(7);
        expect(position.toString(), equals('OffsetScrollPosition [7]'));
      });

      test('returns formatted string for initial position', () {
        final initial = ScrollPosition.offset();
        expect(initial.toString(), equals('OffsetScrollPosition [-1]'));
      });
    });
  });

  group('ScrollDirection', () {
    test('contains forward and backward values', () {
      expect(
        ScrollDirection.values,
        containsAll([ScrollDirection.forward, ScrollDirection.backward]),
      );
    });

    test('reverse toggles between forward and backward', () {
      expect(ScrollDirection.forward.reverse, equals(ScrollDirection.backward));
      expect(ScrollDirection.backward.reverse, equals(ScrollDirection.forward));
    });
  });
}
