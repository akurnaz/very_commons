import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('Unpaged', () {
    group('Unpaged.unsorted', () {
      test('is const and has unsorted Sort', () {
        const unpaged = Unpaged.unsorted;

        expect(unpaged.sort, Sort.unsorted);
        expect(unpaged.isPaged, isFalse);
        expect(unpaged.isUnpaged, isTrue);
      });
    });

    group('Unpaged.sorted()', () {
      test('returns Unpaged.unsorted when no arguments provided', () {
        final unpaged = Unpaged.sorted();

        expect(unpaged, equals(Unpaged.unsorted));
        expect(identical(unpaged, Unpaged.unsorted), isTrue);
        expect(unpaged.sort, Sort.unsorted);
        expect(unpaged.isPaged, isFalse);
        expect(unpaged.isUnpaged, isTrue);
      });

      test('returns Unpaged.unsorted when Sort.unsorted is provided', () {
        final unpaged = Unpaged.sorted(Sort.unsorted);

        expect(unpaged, equals(Unpaged.unsorted));
        expect(identical(unpaged, Unpaged.unsorted), isTrue);
      });

      test('creates Unpaged with given sort when sort is sorted', () {
        final sort = Sort.by(['name']);
        final unpaged = Unpaged.sorted(sort);

        expect(unpaged.sort, sort);
        expect(unpaged.isPaged, isFalse);
        expect(unpaged.isUnpaged, isTrue);
        expect(identical(unpaged, Unpaged.unsorted), isFalse);
      });
    });

    group('pageNumber, pageSize, and offset', () {
      test('pageNumber throws UnsupportedError', () {
        const unpaged = Unpaged.unsorted;

        expect(
          () => unpaged.pageNumber,
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'Instance of Unpaged does not support get pageNumber',
            ),
          ),
        );
      });

      test('pageSize throws UnsupportedError', () {
        const unpaged = Unpaged.unsorted;

        expect(
          () => unpaged.pageSize,
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'Instance of Unpaged does not support get pageSize',
            ),
          ),
        );
      });

      test('offset throws UnsupportedError', () {
        const unpaged = Unpaged.unsorted;

        expect(
          () => unpaged.offset,
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'Instance of Unpaged does not support get offset',
            ),
          ),
        );
      });

      test('sorted Unpaged also throws on pageNumber, pageSize, offset', () {
        final unpaged = Unpaged.sorted(Sort.by(['name']));

        expect(() => unpaged.pageNumber, throwsUnsupportedError);
        expect(() => unpaged.pageSize, throwsUnsupportedError);
        expect(() => unpaged.offset, throwsUnsupportedError);
      });
    });

    group('navigation methods', () {
      test('next() returns this', () {
        const unpaged = Unpaged.unsorted;
        expect(unpaged.next(), same(unpaged));

        final sortedUnpaged = Unpaged.sorted(Sort.by(['name']));
        expect(sortedUnpaged.next(), same(sortedUnpaged));
      });

      test('previousOrFirst() returns this', () {
        const unpaged = Unpaged.unsorted;
        expect(unpaged.previousOrFirst(), same(unpaged));

        final sortedUnpaged = Unpaged.sorted(Sort.by(['name']));
        expect(sortedUnpaged.previousOrFirst(), same(sortedUnpaged));
      });

      test('first() returns this', () {
        const unpaged = Unpaged.unsorted;
        expect(unpaged.first(), same(unpaged));

        final sortedUnpaged = Unpaged.sorted(Sort.by(['name']));
        expect(sortedUnpaged.first(), same(sortedUnpaged));
      });

      test('withPage(0) returns this', () {
        const unpaged = Unpaged.unsorted;
        expect(unpaged.withPage(0), same(unpaged));

        final sortedUnpaged = Unpaged.sorted(Sort.by(['name']));
        expect(sortedUnpaged.withPage(0), same(sortedUnpaged));
      });

      test('withPage() with non-zero pageNumber throws UnsupportedError', () {
        const unpaged = Unpaged.unsorted;

        expect(
          () => unpaged.withPage(1),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'Instance of Unpaged does not support withPage() with non-zero pageNumber',
            ),
          ),
        );

        expect(
          () => unpaged.withPage(-1),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'Instance of Unpaged does not support withPage() with non-zero pageNumber',
            ),
          ),
        );
      });

      test('sorted Unpaged withPage() with non-zero throws', () {
        final unpaged = Unpaged.sorted(Sort.by(['name']));

        expect(
          () => unpaged.withPage(1),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'Instance of Unpaged does not support withPage() with non-zero pageNumber',
            ),
          ),
        );

        expect(
          () => unpaged.withPage(-1),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              'Instance of Unpaged does not support withPage() with non-zero pageNumber',
            ),
          ),
        );
      });

      test('hasPrevious() returns false', () {
        const unpaged = Unpaged.unsorted;
        expect(unpaged.hasPrevious(), isFalse);

        final sortedUnpaged = Unpaged.sorted(Sort.by(['name']));
        expect(sortedUnpaged.hasPrevious(), isFalse);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        final sort1 = Sort.by(['name']);
        final sort2 = Sort.by(['name']);
        final sort3 = Sort.by(['age']);

        final unpaged1 = Unpaged.sorted(sort1);
        final unpaged2 = Unpaged.sorted(sort2);
        final unpaged3 = Unpaged.sorted(sort3);

        expect(unpaged1 == unpaged1, isTrue);
        expect(unpaged1 == unpaged2, isTrue);
        expect(unpaged1.hashCode, unpaged2.hashCode);

        expect(unpaged1 == unpaged3, isFalse);
        expect(unpaged1 == Unpaged.unsorted, isFalse);
        expect(unpaged1 == Object(), isFalse);
      });
    });

    group('toString()', () {
      test('returns "unpaged" for unsorted instance', () {
        expect(Unpaged.unsorted.toString(), 'unpaged');
        expect(Unpaged.sorted().toString(), 'unpaged');
      });

      test('returns formatted string for sorted instance', () {
        final unpaged = Unpaged.sorted(Sort.by(['name']));
        expect(unpaged.toString(), 'Unpaged.sorted(name: asc)');
      });
    });
  });
}
