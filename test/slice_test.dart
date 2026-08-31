import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('Slice / SliceImpl', () {
    group('constructors and default values', () {
      test('creates SliceImpl with unpaged pageable when pageable is not provided', () {
        final slice = SliceImpl<String>(content: ['a', 'b']);

        expect(slice.content, equals(['a', 'b']));
        expect(slice.number, equals(0));
        expect(slice.size, equals(2));
        expect(slice.numberOfElements, equals(2));
        expect(slice.hasContent, isTrue);
        expect(slice.sort, equals(Sort.unsorted));
        expect(slice.isFirst, isTrue);
        expect(slice.isLast, isTrue);
        expect(slice.hasNext, isFalse);
        expect(slice.hasPrevious, isFalse);
        expect(slice.pageable, equals(Unpaged.unsorted));
      });

      test('creates SliceImpl with empty content', () {
        final slice = SliceImpl<String>(content: []);

        expect(slice.content, isEmpty);
        expect(slice.number, equals(0));
        expect(slice.size, equals(0));
        expect(slice.numberOfElements, equals(0));
        expect(slice.hasContent, isFalse);
        expect(slice.isFirst, isTrue);
        expect(slice.isLast, isTrue);
        expect(slice.hasNext, isFalse);
        expect(slice.hasPrevious, isFalse);
      });

      test('creates SliceImpl with explicit Pageable and hasNext true', () {
        final sort = Sort.by(['name'], direction: Direction.desc);
        final pageable = PageRequest(pageNumber: 2, pageSize: 5, sort: sort);
        final slice = SliceImpl<int>(
          content: [10, 20, 30, 40, 50],
          pageable: pageable,
          hasNext: true,
        );

        expect(slice.number, equals(2)); 
        expect(slice.size, equals(5));
        expect(slice.numberOfElements, equals(5));
        expect(slice.hasContent, isTrue);
        expect(slice.sort, equals(sort));
        expect(slice.isFirst, isFalse);
        expect(slice.isLast, isFalse);
        expect(slice.hasNext, isTrue);
        expect(slice.hasPrevious, isTrue);
        expect(slice.pageable, equals(pageable));
      });

      test('content is unmodifiable', () {
        final list = ['x', 'y'];
        final slice = SliceImpl<String>(content: list);

        expect(() => (slice.content as dynamic).add('z'), throwsUnsupportedError);
      });
    });

    group('navigation methods', () {
      test('nextPageable returns next pageable when hasNext is true', () {
        final pageable = PageRequest(pageNumber: 1, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: true);

        final next = slice.nextPageable;
        expect(next.isPaged, isTrue);
        expect(next.pageNumber, equals(2));
        expect(next.pageSize, equals(10));
      });

      test('nextPageable returns Unpaged when hasNext is false', () {
        final pageable = PageRequest(pageNumber: 1, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: false);

        expect(slice.nextPageable.isUnpaged, isTrue);
      });

      test('previousPageable returns previous pageable when hasPrevious is true', () {
        final pageable = PageRequest(pageNumber: 2, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: false);

        final previous = slice.previousPageable;
        expect(previous.isPaged, isTrue);
        expect(previous.pageNumber, equals(1));
        expect(previous.pageSize, equals(10));
      });

      test('previousPageable returns Unpaged when hasPrevious is false', () {
        final pageable = PageRequest(pageNumber: 0, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: true);

        expect(slice.previousPageable.isUnpaged, isTrue);
      });

      test('nextOrLastPageable returns next pageable if hasNext is true', () {
        final pageable = PageRequest(pageNumber: 0, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: true);

        expect(slice.nextOrLastPageable.pageNumber, equals(1));
      });

      test('nextOrLastPageable returns current pageable if hasNext is false', () {
        final pageable = PageRequest(pageNumber: 0, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: false);

        expect(slice.nextOrLastPageable, equals(pageable));
      });

      test('previousOrFirstPageable returns previous pageable if hasPrevious is true', () {
        final pageable = PageRequest(pageNumber: 3, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: false);

        expect(slice.previousOrFirstPageable.pageNumber, equals(2));
      });

      test('previousOrFirstPageable returns current pageable if hasPrevious is false', () {
        final pageable = PageRequest(pageNumber: 0, pageSize: 10);
        final slice = SliceImpl<int>(content: [1, 2], pageable: pageable, hasNext: true);

        expect(slice.previousOrFirstPageable, equals(pageable));
      });
    });

    group('map()', () {
      test('transforms elements into a new SliceImpl preserving metadata', () {
        final pageable = PageRequest(pageNumber: 1, pageSize: 5);
        final slice = SliceImpl<int>(content: [1, 2, 3], pageable: pageable, hasNext: true);

        final mapped = slice.map((e) => 'num_$e');

        expect(mapped.content, equals(['num_1', 'num_2', 'num_3']));
        expect(mapped.number, equals(1));
        expect(mapped.size, equals(5));
        expect(mapped.hasNext, isTrue);
        expect(mapped.pageable, equals(pageable));
      });
    });

    group('Iterable methods', () {
      test('implements Iterable methods correctly', () {
        final slice = SliceImpl<int>(content: [10, 20, 30]);

        expect(slice.toList(), equals([10, 20, 30]));
        expect(slice.where((x) => x > 15).toList(), equals([20, 30]));
        expect(slice.fold<int>(0, (sum, x) => sum + x), equals(60));
        expect(slice.first, equals(10));
        expect(slice.last, equals(30));
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        final pageable1 = PageRequest(pageNumber: 0, pageSize: 10);
        final pageable2 = PageRequest(pageNumber: 0, pageSize: 10);
        final slice1 = SliceImpl<String>(content: ['a', 'b'], pageable: pageable1, hasNext: true);
        final slice2 = SliceImpl<String>(content: ['a', 'b'], pageable: pageable2, hasNext: true);
        final slice3 = SliceImpl<String>(content: ['a', 'c'], pageable: pageable1, hasNext: true);
        final slice4 = SliceImpl<String>(content: ['a', 'b'], pageable: pageable1, hasNext: false);

        expect(slice1 == slice2, isTrue);
        expect(slice1.hashCode, equals(slice2.hashCode));
        expect(slice1 == slice3, isFalse);
        expect(slice1 == slice4, isFalse);
        expect(slice1 == Object(), isFalse);
      });
    });

    group('toString()', () {
      test('returns formatted string representation', () {
        final pageable = PageRequest(pageNumber: 2, pageSize: 5);
        final slice = SliceImpl<String>(content: ['hello', 'world'], pageable: pageable);

        expect(slice.toString(), equals('Slice 2 containing String instances'));
      });

      test('returns UNKNOWN when content is empty', () {
        final slice = SliceImpl<String>(content: []);

        expect(slice.toString(), equals('Slice 0 containing UNKNOWN instances'));
      });
    });
  });
}
