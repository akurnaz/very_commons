import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('ScrollPosition', () {
    group('ScrollPosition.offset()', () {
      test('creates initial scroll position when offset is omitted', () {
        final position = ScrollPosition.offset();

        expect(position, isA<ScrollPosition>());
        expect(position, isA<OffsetScrollPosition>());
        expect(position.isInitial, isTrue);
        expect(() => position.offset, throwsStateError);
        expect(position, equals(OffsetScrollPosition.initial()));
      });

      test('creates initial scroll position when offset is null', () {
        final position = ScrollPosition.offset(null);

        expect(position, isA<ScrollPosition>());
        expect(position, isA<OffsetScrollPosition>());
        expect(position.isInitial, isTrue);
        expect(() => position.offset, throwsStateError);
        expect(position, equals(OffsetScrollPosition.initial()));
      });

      test('creates OffsetScrollPosition when valid non-negative offset is given', () {
        final position = ScrollPosition.offset(5);

        expect(position, isA<ScrollPosition>());
        expect(position, isA<OffsetScrollPosition>());
        expect(position.isInitial, isFalse);
        expect(position.offset, equals(5));
        expect(position, equals(OffsetScrollPosition.of(5)));
      });

      test('creates OffsetScrollPosition with zero offset', () {
        final position = ScrollPosition.offset(0);

        expect(position, isA<ScrollPosition>());
        expect(position, isA<OffsetScrollPosition>());
        expect(position.isInitial, isFalse);
        expect(position.offset, equals(0));
        expect(position, equals(OffsetScrollPosition.of(0)));
      });

      test('throws RangeError when negative offset is provided', () {
        expect(() => ScrollPosition.offset(-1), throwsRangeError);
        expect(() => ScrollPosition.offset(-10), throwsRangeError);
      });
    });

    group('ScrollPosition.keyset()', () {
      test('creates initial keyset scroll position', () {
        final position = ScrollPosition.keyset();

        expect(position, isA<ScrollPosition>());
        expect(position, isA<KeysetScrollPosition>());
        expect(position.isInitial, isTrue);
        expect(position.keys, isEmpty);
        expect(position.direction, equals(ScrollDirection.forward));
        expect(position.scrollsForward, isTrue);
        expect(position.scrollsBackward, isFalse);
        expect(identical(position, KeysetScrollPosition.initial()), isTrue);
        expect(position, equals(KeysetScrollPosition.initial()));
      });
    });

    group('ScrollPosition.forward()', () {
      test('creates keyset scroll position scrolling forward with given keys', () {
        final keys = {'id': 1, 'name': 'Alice'};
        final position = ScrollPosition.forward(keys);

        expect(position, isA<ScrollPosition>());
        expect(position, isA<KeysetScrollPosition>());
        expect(position.isInitial, isFalse);
        expect(position.keys, equals(keys));
        expect(position.direction, equals(ScrollDirection.forward));
        expect(position.scrollsForward, isTrue);
        expect(position.scrollsBackward, isFalse);
        expect(position, equals(ScrollPosition.of(keys, ScrollDirection.forward)));
      });

      test('creates initial keyset scroll position when keys are empty', () {
        final position = ScrollPosition.forward({});

        expect(position.isInitial, isTrue);
        expect(position.direction, equals(ScrollDirection.forward));
        expect(position, equals(KeysetScrollPosition.initial()));
      });

      test('creates unmodifiable defensive copy of keys', () {
        final map = {'id': 1};
        final position = ScrollPosition.forward(map);
        map['id'] = 2;

        expect(position.keys['id'], equals(1));
        expect(() => position.keys['newKey'] = 'val', throwsUnsupportedError);
      });
    });

    group('ScrollPosition.backward()', () {
      test('creates keyset scroll position scrolling backward with given keys', () {
        final keys = {'id': 1, 'name': 'Alice'};
        final position = ScrollPosition.backward(keys);

        expect(position, isA<ScrollPosition>());
        expect(position, isA<KeysetScrollPosition>());
        expect(position.isInitial, isFalse);
        expect(position.keys, equals(keys));
        expect(position.direction, equals(ScrollDirection.backward));
        expect(position.scrollsForward, isFalse);
        expect(position.scrollsBackward, isTrue);
        expect(position, equals(ScrollPosition.of(keys, ScrollDirection.backward)));
      });

      test('creates initial backward keyset scroll position when keys are empty', () {
        final position = ScrollPosition.backward({});

        expect(position.isInitial, isTrue);
        expect(position.direction, equals(ScrollDirection.backward));
        expect(position, equals(KeysetScrollPosition.of({}, ScrollDirection.backward)));
      });

      test('creates unmodifiable defensive copy of keys', () {
        final map = {'id': 1};
        final position = ScrollPosition.backward(map);
        map['id'] = 2;

        expect(position.keys['id'], equals(1));
        expect(() => position.keys['newKey'] = 'val', throwsUnsupportedError);
      });
    });

    group('ScrollPosition.of()', () {
      test('creates keyset scroll position with default forward direction', () {
        final keys = {'id': 42};
        final position = ScrollPosition.of(keys);

        expect(position, isA<ScrollPosition>());
        expect(position, isA<KeysetScrollPosition>());
        expect(position.isInitial, isFalse);
        expect(position.keys, equals(keys));
        expect(position.direction, equals(ScrollDirection.forward));
        expect(position, equals(ScrollPosition.forward(keys)));
      });

      test('creates keyset scroll position with specified backward direction', () {
        final keys = {'id': 42};
        final position = ScrollPosition.of(keys, ScrollDirection.backward);

        expect(position, isA<ScrollPosition>());
        expect(position, isA<KeysetScrollPosition>());
        expect(position.isInitial, isFalse);
        expect(position.keys, equals(keys));
        expect(position.direction, equals(ScrollDirection.backward));
        expect(position, equals(ScrollPosition.backward(keys)));
      });

      test('creates initial position when keys are empty with forward direction', () {
        final position = ScrollPosition.of({}, ScrollDirection.forward);

        expect(position.isInitial, isTrue);
        expect(position.direction, equals(ScrollDirection.forward));
        expect(position, equals(KeysetScrollPosition.initial()));
      });

      test('creates initial position when keys are empty with backward direction', () {
        final position = ScrollPosition.of({}, ScrollDirection.backward);

        expect(position.isInitial, isTrue);
        expect(position.direction, equals(ScrollDirection.backward));
        expect(position, equals(KeysetScrollPosition.of({}, ScrollDirection.backward)));
      });

      test('creates unmodifiable defensive copy of keys', () {
        final map = {'score': 99};
        final position = ScrollPosition.of(map);
        map['score'] = 100;

        expect(position.keys['score'], equals(99));
        expect(() => position.keys['extra'] = 'test', throwsUnsupportedError);
      });
    });

    group('isInitial getter', () {
      test('returns true for initial positions across all types', () {
        expect(ScrollPosition.offset().isInitial, isTrue);
        expect(ScrollPosition.offset(null).isInitial, isTrue);
        expect(ScrollPosition.keyset().isInitial, isTrue);
        expect(ScrollPosition.forward({}).isInitial, isTrue);
        expect(ScrollPosition.backward({}).isInitial, isTrue);
        expect(ScrollPosition.of({}).isInitial, isTrue);
        expect(ScrollPosition.of({}, ScrollDirection.backward).isInitial, isTrue);
      });

      test('returns false for non-initial positions across all types', () {
        expect(ScrollPosition.offset(0).isInitial, isFalse);
        expect(ScrollPosition.offset(10).isInitial, isFalse);
        expect(ScrollPosition.forward({'id': 1}).isInitial, isFalse);
        expect(ScrollPosition.backward({'id': 1}).isInitial, isFalse);
        expect(ScrollPosition.of({'id': 1}).isInitial, isFalse);
        expect(ScrollPosition.of({'id': 1}, ScrollDirection.backward).isInitial, isFalse);
      });
    });

    group('polymorphism and cross-type equality', () {
      test('different types of scroll positions are not equal', () {
        final ScrollPosition offsetInit = ScrollPosition.offset();
        final ScrollPosition keysetInit = ScrollPosition.keyset();

        expect(offsetInit == keysetInit, isFalse);
        expect(keysetInit == offsetInit, isFalse);
      });

      test('offset position is not equal to keyset position with same numeric data', () {
        final ScrollPosition offsetPos = ScrollPosition.offset(5);
        final ScrollPosition keysetPos = ScrollPosition.forward({'offset': 5});

        expect(offsetPos == keysetPos, isFalse);
      });
    });
  });

  group('OffsetScrollPosition', () {
    group('OffsetScrollPosition.initial()', () {
      test('creates initial instance with isInitial true and throwing offset getter', () {
        final position = OffsetScrollPosition.initial();

        expect(position.isInitial, isTrue);
        expect(() => position.offset, throwsStateError);
        expect(position, equals(ScrollPosition.offset()));
      });
    });

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
        final initial = ScrollPosition.offset();

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
        final initial = ScrollPosition.offset();
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
        final initial = ScrollPosition.offset();
        final advanced = initial.advanceBy(8);

        expect(advanced.offset, equals(8));
        expect(advanced.isInitial, isFalse);
      });

      test('advances initial position by 0', () {
        final initial = ScrollPosition.offset();
        final advanced = initial.advanceBy(0);

        expect(advanced.offset, equals(0));
        expect(advanced.isInitial, isFalse);
      });

      test('clamps initial position to 0 when delta is negative', () {
        final initial = ScrollPosition.offset();
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
        final initial1 = ScrollPosition.offset();
        final initial2 = ScrollPosition.offset();

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

  group('KeysetScrollPosition', () {
    final keys1 = {'id': 1, 'name': 'Alice'};
    final keys2 = {'name': 'Alice', 'id': 1};
    final keys3 = {'id': 2, 'name': 'Bob'};

    group('initial()', () {
      test('creates initial forward scroll position with empty keys', () {
        final position = KeysetScrollPosition.initial();

        expect(position.isInitial, isTrue);
        expect(position.keys, isEmpty);
        expect(position.direction, equals(ScrollDirection.forward));
        expect(position.scrollsForward, isTrue);
        expect(position.scrollsBackward, isFalse);
      });
    });

    group('of()', () {
      test('returns cached empty forward when keys are empty and direction is forward', () {
        final position = KeysetScrollPosition.of({});

        expect(position.isInitial, isTrue);
        expect(position.direction, equals(ScrollDirection.forward));
        expect(identical(position, KeysetScrollPosition.initial()), isTrue);
      });

      test('returns cached empty backward when keys are empty and direction is backward', () {
        final position = KeysetScrollPosition.of({}, ScrollDirection.backward);

        expect(position.isInitial, isTrue);
        expect(position.direction, equals(ScrollDirection.backward));
        expect(position.scrollsBackward, isTrue);
      });

      test('creates position with given keys and default forward direction', () {
        final position = KeysetScrollPosition.of(keys1);

        expect(position.isInitial, isFalse);
        expect(position.keys, equals(keys1));
        expect(position.direction, equals(ScrollDirection.forward));
      });

      test('creates position with given keys and backward direction', () {
        final position = KeysetScrollPosition.of(keys1, ScrollDirection.backward);

        expect(position.isInitial, isFalse);
        expect(position.keys, equals(keys1));
        expect(position.direction, equals(ScrollDirection.backward));
      });
    });

    group('positionFunction()', () {
      final items = [
        {'id': 101, 'name': 'Item A', 'score': 90},
        {'id': 102, 'name': 'Item B', 'score': 85},
      ];
      final sort = Sort.by(['id', 'score']);

      test('extracts keys based on sort orders and assigns direction', () {
        final fn = KeysetScrollPosition.positionFunction(items, sort, ScrollDirection.forward);

        final pos0 = fn(0);
        expect(pos0.keys, equals({'id': 101, 'score': 90}));
        expect(pos0.direction, equals(ScrollDirection.forward));

        final pos1 = fn(1);
        expect(pos1.keys, equals({'id': 102, 'score': 85}));
        expect(pos1.direction, equals(ScrollDirection.forward));
      });

      test('works with backward direction', () {
        final fn = KeysetScrollPosition.positionFunction(items, sort, ScrollDirection.backward);

        final pos0 = fn(0);
        expect(pos0.keys, equals({'id': 101, 'score': 90}));
        expect(pos0.direction, equals(ScrollDirection.backward));
      });

      test('extracts values from nested maps using dot-separated property paths', () {
        final nestedItems = [
          {
            'id': 1,
            'author': {
              'name': 'George Orwell',
              'address': {'city': 'London'},
            },
          },
          {
            'id': 2,
            'author': {'name': 'Aldous Huxley', 'address': null},
          },
          {'id': 3, 'author': null},
        ];
        final nestedSort = Sort.by(['id', 'author.name', 'author.address.city']);

        final fn = KeysetScrollPosition.positionFunction(
          nestedItems,
          nestedSort,
          ScrollDirection.forward,
        );

        final pos0 = fn(0);
        expect(
          pos0.keys,
          equals({'id': 1, 'author.name': 'George Orwell', 'author.address.city': 'London'}),
        );

        final pos1 = fn(1);
        expect(
          pos1.keys,
          equals({'id': 2, 'author.name': 'Aldous Huxley', 'author.address.city': null}),
        );

        final pos2 = fn(2);
        expect(pos2.keys, equals({'id': 3, 'author.name': null, 'author.address.city': null}));
      });

      test('prioritizes direct key match when map contains key with dot', () {
        final itemsWithDotKey = [
          {
            'author.name': 'Direct Match',
            'author': {'name': 'Nested Value'},
          },
        ];
        final sort = Sort.by(['author.name']);
        final fn = KeysetScrollPosition.positionFunction(
          itemsWithDotKey,
          sort,
          ScrollDirection.forward,
        );

        expect(fn(0).keys, equals({'author.name': 'Direct Match'}));
      });
    });

    group('getNextPositionFunction()', () {
      final items = [
        {'id': 201, 'title': 'Book 1'},
        {'id': 202, 'title': 'Book 2'},
      ];
      final sort = Sort.by(['id']);

      test('uses the instance direction to create next position function', () {
        final forwardPos = KeysetScrollPosition.of({'id': 200}, ScrollDirection.forward);
        final nextFnForward = forwardPos.getNextPositionFunction(items, sort);

        expect(nextFnForward(0).keys, equals({'id': 201}));
        expect(nextFnForward(0).direction, equals(ScrollDirection.forward));

        final backwardPos = KeysetScrollPosition.of({'id': 200}, ScrollDirection.backward);
        final nextFnBackward = backwardPos.getNextPositionFunction(items, sort);

        expect(nextFnBackward(1).keys, equals({'id': 202}));
        expect(nextFnBackward(1).direction, equals(ScrollDirection.backward));
      });
    });

    group('direction and navigation', () {
      test('scrollsForward and scrollsBackward return correct booleans', () {
        final forwardPos = KeysetScrollPosition.of(keys1, ScrollDirection.forward);
        final backwardPos = KeysetScrollPosition.of(keys1, ScrollDirection.backward);

        expect(forwardPos.scrollsForward, isTrue);
        expect(forwardPos.scrollsBackward, isFalse);
        expect(backwardPos.scrollsForward, isFalse);
        expect(backwardPos.scrollsBackward, isTrue);
      });

      test('forward returns same instance if already forward, or new forward instance', () {
        final pos = KeysetScrollPosition.of(keys1, ScrollDirection.forward);
        expect(identical(pos.forward, pos), isTrue);

        final backwardPos = KeysetScrollPosition.of(keys1, ScrollDirection.backward);
        final forwardPos = backwardPos.forward;
        expect(forwardPos.direction, equals(ScrollDirection.forward));
        expect(forwardPos.keys, equals(keys1));
      });

      test('backward returns same instance if already backward, or new backward instance', () {
        final pos = KeysetScrollPosition.of(keys1, ScrollDirection.backward);
        expect(identical(pos.backward, pos), isTrue);

        final forwardPos = KeysetScrollPosition.of(keys1, ScrollDirection.forward);
        final backwardPos = forwardPos.backward;
        expect(backwardPos.direction, equals(ScrollDirection.backward));
        expect(backwardPos.keys, equals(keys1));
      });

      test('reverse inverts the direction', () {
        final forwardPos = KeysetScrollPosition.of(keys1, ScrollDirection.forward);
        final reversed = forwardPos.reverse;

        expect(reversed.direction, equals(ScrollDirection.backward));
        expect(reversed.reverse.direction, equals(ScrollDirection.forward));
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode for same keys', () {
        final pos1 = KeysetScrollPosition.of({'id': 1, 'name': 'Alice'});
        final pos2 = KeysetScrollPosition.of({'id': 1, 'name': 'Alice'});

        expect(pos1 == pos1, isTrue);
        expect(pos1 == pos2, isTrue);
        expect(pos2 == pos1, isTrue);
        expect(pos1.hashCode, equals(pos2.hashCode));
      });

      test('evaluates equality and hashCode consistently regardless of map insertion order', () {
        final pos1 = KeysetScrollPosition.of(keys1);
        final pos2 = KeysetScrollPosition.of(keys2);

        expect(pos1 == pos2, isTrue);
        expect(pos2 == pos1, isTrue);
        expect(pos1.hashCode, equals(pos2.hashCode));
      });

      test('evaluates initial instances as equal with matching hashCode', () {
        final init1 = KeysetScrollPosition.initial();
        final init2 = KeysetScrollPosition.of({});

        expect(init1 == init2, isTrue);
        expect(init1.hashCode, equals(init2.hashCode));
      });

      test('returns false when directions differ', () {
        final posForward = KeysetScrollPosition.of(keys1, ScrollDirection.forward);
        final posBackward = KeysetScrollPosition.of(keys1, ScrollDirection.backward);

        expect(posForward == posBackward, isFalse);
      });

      test('returns false when keys differ', () {
        final pos1 = KeysetScrollPosition.of({'id': 1});
        final pos2 = KeysetScrollPosition.of({'id': 2});
        final pos3 = KeysetScrollPosition.of({'other': 1});
        final pos4 = KeysetScrollPosition.of({'id': 1, 'extra': 'val'});

        expect(pos1 == pos2, isFalse);
        expect(pos1 == pos3, isFalse);
        expect(pos1 == pos4, isFalse);
        expect(pos1 == KeysetScrollPosition.of(keys3), isFalse);
      });

      test('correctly handles null values in keys map', () {
        final nullVal1 = KeysetScrollPosition.of({'id': null});
        final nullVal2 = KeysetScrollPosition.of({'id': null});
        final otherNullKey = KeysetScrollPosition.of({'other': null});
        final notNullVal = KeysetScrollPosition.of({'id': 1});

        expect(nullVal1 == nullVal2, isTrue);
        expect(nullVal1.hashCode, equals(nullVal2.hashCode));
        expect(nullVal1 == otherNullKey, isFalse);
        expect(nullVal1 == notNullVal, isFalse);
      });

      test('returns false when compared to other types', () {
        final pos = KeysetScrollPosition.of(keys1);
        final Object otherType = OffsetScrollPosition.of(0);
        expect(pos == Object(), isFalse);
        expect(pos == otherType, isFalse);
      });
    });

    group('toString()', () {
      test('returns formatted string representation', () {
        final pos = KeysetScrollPosition.of({'id': 42}, ScrollDirection.forward);
        expect(pos.toString(), equals('KeysetScrollPosition [ScrollDirection.forward, {id: 42}]'));
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
