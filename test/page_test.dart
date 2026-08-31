import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

void main() {
  group('Page / PageImpl', () {
    group('PageImpl', () {
      test('constructor with only content sets unpaged and correct total', () {
        final page = PageImpl<String>(content: ['a', 'b', 'c']);

        expect(page.content, equals(['a', 'b', 'c']));
        expect(page.pageable, equals(Unpaged.unsorted));
        expect(page.totalElements, equals(3));
        expect(page.totalPages, equals(1));
        expect(page.number, equals(0));
        expect(page.size, equals(3));
        expect(page.hasNext, isFalse);
        expect(page.isLast, isTrue);
      });

      test('constructor with empty content defaults total to 0 and totalPages to 1', () {
        final page = PageImpl<String>(content: []);

        expect(page.content, isEmpty);
        expect(page.totalElements, equals(0));
        expect(page.size, equals(0));
        expect(page.totalPages, equals(1));
        expect(page.hasNext, isFalse);
        expect(page.isLast, isTrue);
      });

      test('paged constructor with empty content and 0 total yields 0 totalPages', () {
        const pageable = PageRequest(pageNumber: 0, pageSize: 10);
        final page = PageImpl<String>(content: [], pageable: pageable, total: 0);

        expect(page.content, isEmpty);
        expect(page.totalElements, equals(0));
        expect(page.size, equals(10));
        expect(page.totalPages, equals(0));
        expect(page.isFirst, isTrue);
        expect(page.isLast, isTrue);
        expect(page.hasNext, isFalse);
        expect(page.hasPrevious, isFalse);
      });

      test('calculates totalPages and navigation correctly across multiple pages', () {
        const pageableFirst = PageRequest(pageNumber: 0, pageSize: 5);
        final pageFirst = PageImpl<int>(
          content: [1, 2, 3, 4, 5],
          pageable: pageableFirst,
          total: 15,
        );

        expect(pageFirst.number, equals(0));
        expect(pageFirst.size, equals(5));
        expect(pageFirst.numberOfElements, equals(5));
        expect(pageFirst.totalElements, equals(15));
        expect(pageFirst.totalPages, equals(3));
        expect(pageFirst.isFirst, isTrue);
        expect(pageFirst.isLast, isFalse);
        expect(pageFirst.hasNext, isTrue);
        expect(pageFirst.hasPrevious, isFalse);

        const pageableMiddle = PageRequest(pageNumber: 1, pageSize: 5);
        final pageMiddle = PageImpl<int>(
          content: [6, 7, 8, 9, 10],
          pageable: pageableMiddle,
          total: 15,
        );

        expect(pageMiddle.number, equals(1));
        expect(pageMiddle.totalPages, equals(3));
        expect(pageMiddle.isFirst, isFalse);
        expect(pageMiddle.isLast, isFalse);
        expect(pageMiddle.hasNext, isTrue);
        expect(pageMiddle.hasPrevious, isTrue);

        const pageableLast = PageRequest(pageNumber: 2, pageSize: 5);
        final pageLast = PageImpl<int>(
          content: [11, 12, 13, 14, 15],
          pageable: pageableLast,
          total: 15,
        );

        expect(pageLast.number, equals(2));
        expect(pageLast.totalPages, equals(3));
        expect(pageLast.isFirst, isFalse);
        expect(pageLast.isLast, isTrue);
        expect(pageLast.hasNext, isFalse);
        expect(pageLast.hasPrevious, isTrue);
      });

      test('single page navigation properties', () {
        const pageable = PageRequest(pageNumber: 0, pageSize: 10);
        final page = PageImpl<int>(content: [1, 2, 3], pageable: pageable, total: 3);

        expect(page.totalPages, equals(1));
        expect(page.isFirst, isTrue);
        expect(page.isLast, isTrue);
        expect(page.hasNext, isFalse);
        expect(page.hasPrevious, isFalse);
      });

      test('adapts total if offset + pageSize > total to mitigate inconsistencies', () {
        // offset is 10, pageSize is 5, but content size is 3 (total was given as 8, which is < offset + pageSize)
        const pageable = PageRequest(pageNumber: 2, pageSize: 5);
        final page = PageImpl<int>(content: [11, 12, 13], pageable: pageable, total: 8);

        // 10 + 3 = 13
        expect(page.totalElements, equals(13));
        expect(page.totalPages, equals(3));
        expect(page.hasNext, isFalse);
        expect(page.isLast, isTrue);
      });

      test('retains total when total >= offset + pageSize', () {
        const pageable = PageRequest(pageNumber: 0, pageSize: 5);
        final page = PageImpl<int>(content: [1, 2, 3, 4, 5], pageable: pageable, total: 100);

        expect(page.totalElements, equals(100));
        expect(page.totalPages, equals(20));
      });

      test('slice navigation methods return expected pageable', () {
        const pageable = PageRequest(pageNumber: 1, pageSize: 5);
        final page = PageImpl<int>(content: [6, 7, 8, 9, 10], pageable: pageable, total: 15);

        expect(page.nextPageable, equals(const PageRequest(pageNumber: 2, pageSize: 5)));
        expect(page.previousPageable, equals(const PageRequest(pageNumber: 0, pageSize: 5)));
        expect(page.nextOrLastPageable, equals(const PageRequest(pageNumber: 2, pageSize: 5)));
        expect(page.previousOrFirstPageable, equals(const PageRequest(pageNumber: 0, pageSize: 5)));

        const lastPageable = PageRequest(pageNumber: 2, pageSize: 5);
        final lastPage = PageImpl<int>(content: [11, 12], pageable: lastPageable, total: 12);
        expect(lastPage.nextPageable, equals(Unpaged.unsorted));
        expect(lastPage.nextOrLastPageable, equals(lastPageable));

        const firstPageable = PageRequest(pageNumber: 0, pageSize: 5);
        final firstPage = PageImpl<int>(content: [1, 2, 3], pageable: firstPageable, total: 12);
        expect(firstPage.previousPageable, equals(Unpaged.unsorted));
        expect(firstPage.previousOrFirstPageable, equals(firstPageable));
      });

      test('implements Iterable methods', () {
        final page = PageImpl<int>(content: [10, 20, 30]);

        expect(page.hasContent, isTrue);
        expect(page.contains(20), isTrue);
        expect(page.contains(99), isFalse);
        expect(page.where((e) => e > 15).toList(), equals([20, 30]));
        expect(page.iterator.moveNext(), isTrue);
      });

      test('map() preserves total', () {
        const pageable = PageRequest(pageNumber: 0, pageSize: 5);
        final page = PageImpl<int>(content: [1, 2, 3], pageable: pageable, total: 10);

        final mapped = page.map((e) => 'num_$e');
        expect(mapped.content, equals(['num_1', 'num_2', 'num_3']));
        expect(mapped.totalElements, equals(10));
        expect(mapped.totalPages, equals(2));
      });

      test('equality, hashCode and toString', () {
        const pageable = PageRequest(pageNumber: 0, pageSize: 5);
        final page1 = PageImpl<String>(content: ['a', 'b'], pageable: pageable, total: 10);
        final page2 = PageImpl<String>(content: ['a', 'b'], pageable: pageable, total: 10);

        final page3 = PageImpl<String>(content: ['a', 'b'], pageable: pageable, total: 20);

        expect(page1 == page2, isTrue);
        expect(page1.hashCode, equals(page2.hashCode));
        expect(page1 == page3, isFalse);
        expect(page1 == Object(), isFalse);
        expect(page1.toString(), equals('Page 1 of 2 containing String instances'));
      });

      test('toString with empty content', () {
        final page = PageImpl<String>(content: []);
        expect(page.toString(), equals('Page 1 of 1 containing UNKNOWN instances'));
      });
    });
  });
}
