import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('Window', () {
    const positionFunction = OffsetPositionFunction(10);

    group('Window.from constructor and default values', () {
      test('creates Window with default hasNext false', () {
        const window = Window.from(['a', 'b', 'c'], positionFunction);

        expect(window, isA<Window<String>>());
        expect(window.content, equals(['a', 'b', 'c']));
        expect(window.hasNext, isFalse);
        expect(window.isLast, isTrue);
      });

      test('creates Window with explicit hasNext true', () {
        const window = Window.from(['a', 'b'], positionFunction, hasNext: true);

        expect(window.content, equals(['a', 'b']));
        expect(window.hasNext, isTrue);
        expect(window.isLast, isFalse);
      });

      test('creates Window with empty content', () {
        const window = Window<int>.from([], positionFunction);

        expect(window.content, isEmpty);
        expect(window.hasNext, isFalse);
        expect(window.isLast, isTrue);
      });
    });

    group('content', () {
      test('returns the list of items', () {
        final items = [1, 2, 3];
        final window = Window.from(items, positionFunction);

        expect(window.content, equals([1, 2, 3]));
      });
    });

    group('hasNext and isLast', () {
      test('isLast is true when hasNext is false', () {
        const window = Window.from(['item'], positionFunction, hasNext: false);

        expect(window.hasNext, isFalse);
        expect(window.isLast, isTrue);
      });

      test('isLast is false when hasNext is true', () {
        const window = Window.from(['item'], positionFunction, hasNext: true);

        expect(window.hasNext, isTrue);
        expect(window.isLast, isFalse);
      });
    });

    group('positionAt()', () {
      test('returns correct ScrollPosition for valid index', () {
        const window = Window.from(['first', 'second', 'third'], OffsetPositionFunction(5));

        final pos0 = window.positionAt(0);
        final pos1 = window.positionAt(1);
        final pos2 = window.positionAt(2);

        expect(pos0, isA<OffsetScrollPosition>());
        expect((pos0 as OffsetScrollPosition).offset, equals(5));
        expect((pos1 as OffsetScrollPosition).offset, equals(6));
        expect((pos2 as OffsetScrollPosition).offset, equals(7));
      });

      test('throws RangeError when index is negative', () {
        const window = Window.from(['a', 'b'], positionFunction);

        expect(() => window.positionAt(-1), throwsRangeError);
      });

      test('throws RangeError when index is equal to content length', () {
        const window = Window.from(['a', 'b'], positionFunction);

        expect(() => window.positionAt(2), throwsRangeError);
      });

      test('throws RangeError when index is greater than content length', () {
        const window = Window.from(['a', 'b'], positionFunction);

        expect(() => window.positionAt(5), throwsRangeError);
      });

      test('throws RangeError on empty window', () {
        const window = Window<String>.from([], positionFunction);

        expect(() => window.positionAt(0), throwsRangeError);
      });
    });

    group('hasPosition()', () {
      test('returns true for valid indices within bounds', () {
        const window = Window.from(['a', 'b', 'c'], positionFunction);

        expect(window.hasPosition(0), isTrue);
        expect(window.hasPosition(1), isTrue);
        expect(window.hasPosition(2), isTrue);
      });

      test('returns false for negative index', () {
        const window = Window.from(['a', 'b'], positionFunction);

        expect(window.hasPosition(-1), isFalse);
      });

      test('returns false for out-of-bounds index', () {
        const window = Window.from(['a', 'b'], positionFunction);

        expect(window.hasPosition(2), isFalse);
        expect(window.hasPosition(10), isFalse);
      });

      test('returns false for any index on empty window', () {
        const window = Window<int>.from([], positionFunction);

        expect(window.hasPosition(0), isFalse);
        expect(window.hasPosition(-1), isFalse);
      });
    });

    group('positionOf()', () {
      test('returns ScrollPosition of item present in window', () {
        const window = Window.from(['alpha', 'beta', 'gamma'], OffsetPositionFunction(20));

        final posBeta = window.positionOf('beta');
        expect((posBeta as OffsetScrollPosition).offset, equals(21));

        final posGamma = window.positionOf('gamma');
        expect((posGamma as OffsetScrollPosition).offset, equals(22));
      });

      test('returns position of the first occurrence when duplicates exist', () {
        const window = Window.from(['dup', 'other', 'dup'], OffsetPositionFunction(0));

        final pos = window.positionOf('dup');
        expect((pos as OffsetScrollPosition).offset, equals(0));
      });

      test('throws StateError when item is not in window', () {
        const window = Window.from(['a', 'b'], positionFunction);

        expect(
          () => window.positionOf('c'),
          throwsA(
            isA<StateError>().having((e) => e.message, 'message', 'Element not found in window: c'),
          ),
        );
      });
    });

    group('map()', () {
      test('transforms content elements while preserving positionFunction and hasNext', () {
        const window = Window.from([1, 2, 3], OffsetPositionFunction(5), hasNext: true);

        final mapped = window.map((n) => 'num_$n');

        expect(mapped, isA<Window<String>>());
        expect(mapped.content, equals(['num_1', 'num_2', 'num_3']));
        expect(mapped.hasNext, isTrue);
        expect(mapped.isLast, isFalse);

        final pos = mapped.positionAt(1);
        expect((pos as OffsetScrollPosition).offset, equals(6));
      });

      test('transforms empty window correctly', () {
        const window = Window<int>.from([], positionFunction, hasNext: false);

        final mapped = window.map((n) => 'item_$n');

        expect(mapped.content, isEmpty);
        expect(mapped.hasNext, isFalse);
        expect(mapped.isLast, isTrue);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        const w1 = Window.from(['a', 'b'], OffsetPositionFunction(0), hasNext: false);
        const w2 = Window.from(['a', 'b'], OffsetPositionFunction(0), hasNext: false);
        const wDiffContent = Window.from(['a', 'c'], OffsetPositionFunction(0), hasNext: false);
        const wDiffLength = Window.from(['a'], OffsetPositionFunction(0), hasNext: false);
        const wDiffFn = Window.from(['a', 'b'], OffsetPositionFunction(1), hasNext: false);
        const wDiffHasNext = Window.from(['a', 'b'], OffsetPositionFunction(0), hasNext: true);

        expect(w1 == w1, isTrue);
        expect(w1 == w2, isTrue);
        expect(w1.hashCode, equals(w2.hashCode));

        expect(w1 == wDiffContent, isFalse);
        expect(w1 == wDiffLength, isFalse);
        expect(w1 == wDiffFn, isFalse);
        expect(w1 == wDiffHasNext, isFalse);
        expect(w1 == Object(), isFalse);
      });
    });

    group('toString()', () {
      test('returns formatted string representation', () {
        const window = Window.from(['x', 'y', 'z'], positionFunction);

        expect(window.toString(), equals('Window [x, y, z]'));
      });

      test('returns formatted string for empty window', () {
        const window = Window<String>.from([], positionFunction);

        expect(window.toString(), equals('Window []'));
      });
    });
  });
}
