import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('Limit', () {
    group('Limit.unlimited()', () {
      test('is const and has isLimited false, isUnlimited true', () {
        const limit = Limit.unlimited();

        expect(limit.isLimited, isFalse);
        expect(limit.isUnlimited, isTrue);
      });

      test('throws StateError when reading max', () {
        const limit = Limit.unlimited();

        expect(
          () => limit.max,
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              "Unlimited does not define 'max'. Please check 'isLimited' before attempting to read 'max'",
            ),
          ),
        );
      });

      test('equals another unlimited instance', () {
        const limit1 = Limit.unlimited();
        const limit2 = Unlimited();
        const limit3 = Limit.unlimited();

        expect(limit1, equals(limit2));
        expect(limit1, equals(limit3));
        expect(limit1.hashCode, equals(limit2.hashCode));
      });

      test('does not equal a limited instance', () {
        const unlimited = Limit.unlimited();
        const limited = Limit.of(10);

        expect(unlimited, isNot(equals(limited)));
        expect(limited, isNot(equals(unlimited)));
      });

      test('toString returns unlimited', () {
        const limit = Limit.unlimited();
        expect(limit.toString(), equals('unlimited'));
      });
    });

    group('Limit.of()', () {
      test('creates Limited with positive value', () {
        const limit = Limit.of(25);

        expect(limit.isLimited, isTrue);
        expect(limit.isUnlimited, isFalse);
        expect(limit.max, equals(25));
      });

      test('creates Limited with zero value', () {
        const limit = Limit.of(0);

        expect(limit.isLimited, isTrue);
        expect(limit.isUnlimited, isFalse);
        expect(limit.max, equals(0));
      });

      test('creates Limited with negative value', () {
        const limit = Limit.of(-5);

        expect(limit.isLimited, isTrue);
        expect(limit.isUnlimited, isFalse);
        expect(limit.max, equals(-5));
      });

      test('equals another Limited with the same max', () {
        const limit1 = Limit.of(10);
        const limit2 = Limit.of(10);

        expect(limit1, equals(limit2));
        expect(limit1.hashCode, equals(limit2.hashCode));
      });

      test('does not equal another Limited with different max', () {
        const limit1 = Limit.of(10);
        const limit2 = Limit.of(20);

        expect(limit1, isNot(equals(limit2)));
      });

      test('toString returns Limit.of(max)', () {
        const limit = Limit.of(50);
        expect(limit.toString(), equals('Limit(50)'));
      });
    });

    group('pattern matching', () {
      test('exhaustively matches Limited and Unlimited', () {
        String describe(Limit limit) {
          return switch (limit) {
            Limited(:final max) => 'limited: $max',
            Unlimited() => 'unlimited',
          };
        }

        expect(describe(const Limit.of(10)), equals('limited: 10'));
        expect(describe(const Limit.unlimited()), equals('unlimited'));
      });
    });
  });
}
