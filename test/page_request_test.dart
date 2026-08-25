import 'package:test/test.dart';
import 'package:very_commons/very_commons.dart';

class _TestPageRequest extends AbstractPageRequest {
  final Sort _sort;

  const _TestPageRequest({
    required super.pageNumber,
    required super.pageSize,
    this._sort = Sort.unsorted,
  });

  @override
  Sort get sort => _sort;

  @override
  Pageable next() => _TestPageRequest(pageNumber: pageNumber + 1, pageSize: pageSize, sort: _sort);

  @override
  Pageable previous() => pageNumber == 0
      ? this
      : _TestPageRequest(pageNumber: pageNumber - 1, pageSize: pageSize, sort: _sort);

  @override
  Pageable first() => _TestPageRequest(pageNumber: 0, pageSize: pageSize, sort: _sort);

  @override
  Pageable withPage(int pageNumber) =>
      _TestPageRequest(pageNumber: pageNumber, pageSize: pageSize, sort: _sort);
}

void main() {
  group('AbstractPageRequest', () {
    group('constructor assertions', () {
      test('creates instance with valid pageNumber and pageSize', () {
        const request = _TestPageRequest(pageNumber: 0, pageSize: 10);

        expect(request.pageNumber, 0);
        expect(request.pageSize, 10);
      });

      test('throws AssertionError when pageNumber is negative', () {
        expect(
          () => _TestPageRequest(pageNumber: -1, pageSize: 10),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'Page index must not be less than zero',
            ),
          ),
        );
      });

      test('throws AssertionError when pageSize is less than one', () {
        expect(
          () => _TestPageRequest(pageNumber: 0, pageSize: 0),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'Page size must not be less than one',
            ),
          ),
        );

        expect(
          () => _TestPageRequest(pageNumber: 0, pageSize: -5),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'Page size must not be less than one',
            ),
          ),
        );
      });
    });

    group('isPaged and isUnpaged', () {
      test('isPaged returns true and isUnpaged returns false', () {
        const request = _TestPageRequest(pageNumber: 0, pageSize: 10);
        expect(request.isPaged, isTrue);
        expect(request.isUnpaged, isFalse);
      });
    });

    group('offset', () {
      test('calculates correct offset', () {
        expect(const _TestPageRequest(pageNumber: 0, pageSize: 10).offset, 0);
        expect(const _TestPageRequest(pageNumber: 1, pageSize: 10).offset, 10);
        expect(const _TestPageRequest(pageNumber: 2, pageSize: 20).offset, 40);
        expect(const _TestPageRequest(pageNumber: 5, pageSize: 15).offset, 75);
      });
    });

    group('hasPrevious()', () {
      test('returns false when pageNumber is 0', () {
        const request = _TestPageRequest(pageNumber: 0, pageSize: 10);
        expect(request.hasPrevious(), isFalse);
      });

      test('returns true when pageNumber is greater than 0', () {
        const request = _TestPageRequest(pageNumber: 1, pageSize: 10);
        expect(request.hasPrevious(), isTrue);

        const request2 = _TestPageRequest(pageNumber: 5, pageSize: 10);
        expect(request2.hasPrevious(), isTrue);
      });
    });

    group('previousOrFirst()', () {
      test('returns first() when hasPrevious() is false', () {
        const request = _TestPageRequest(pageNumber: 0, pageSize: 10);
        final result = request.previousOrFirst();
        expect(result.pageNumber, 0);
      });

      test('returns previous() when hasPrevious() is true', () {
        const request = _TestPageRequest(pageNumber: 2, pageSize: 10);
        final result = request.previousOrFirst();
        expect(result.pageNumber, 1);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        const request1 = _TestPageRequest(pageNumber: 1, pageSize: 10);
        const request2 = _TestPageRequest(pageNumber: 1, pageSize: 10);
        const requestDiffPage = _TestPageRequest(pageNumber: 2, pageSize: 10);
        const requestDiffSize = _TestPageRequest(pageNumber: 1, pageSize: 20);

        expect(request1 == request1, isTrue);
        expect(request1 == request2, isTrue);
        expect(request1.hashCode, request2.hashCode);

        expect(request1 == requestDiffPage, isFalse);
        expect(request1 == requestDiffSize, isFalse);
        expect(request1 == Object(), isFalse);
      });
    });
  });

  group('PageRequest', () {
    group('constructor & defaults', () {
      test('creates PageRequest with default pageNumber 0 and Sort.unsorted', () {
        const request = PageRequest(pageSize: 20);

        expect(request.pageNumber, 0);
        expect(request.pageSize, 20);
        expect(request.sort, Sort.unsorted);
        expect(request.isPaged, isTrue);
        expect(request.isUnpaged, isFalse);
        expect(request.offset, 0);
      });

      test('creates PageRequest with custom pageNumber and sort', () {
        final sort = Sort.by(['name']);
        final request = PageRequest(pageNumber: 2, pageSize: 15, sort: sort);

        expect(request.pageNumber, 2);
        expect(request.pageSize, 15);
        expect(request.sort, sort);
        expect(request.offset, 30);
      });

      test('throws AssertionError on invalid pageNumber or pageSize', () {
        expect(
          () => PageRequest(pageNumber: -1, pageSize: 10),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'Page index must not be less than zero',
            ),
          ),
        );

        expect(
          () => PageRequest(pageSize: 0),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'Page size must not be less than one',
            ),
          ),
        );
      });
    });

    group('next()', () {
      test('returns PageRequest for the next page with same pageSize and sort', () {
        final sort = Sort.by(['name']);
        final request = PageRequest(pageNumber: 1, pageSize: 20, sort: sort);
        final nextRequest = request.next();

        expect(nextRequest.pageNumber, 2);
        expect(nextRequest.pageSize, 20);
        expect(nextRequest.sort, sort);
      });
    });

    group('previous()', () {
      test('returns this when pageNumber is 0', () {
        const request = PageRequest(pageNumber: 0, pageSize: 20);
        final prevRequest = request.previous();

        expect(prevRequest, same(request));
      });

      test('returns PageRequest for the previous page when pageNumber > 0', () {
        final sort = Sort.by(['name']);
        final request = PageRequest(pageNumber: 2, pageSize: 20, sort: sort);
        final prevRequest = request.previous();

        expect(prevRequest.pageNumber, 1);
        expect(prevRequest.pageSize, 20);
        expect(prevRequest.sort, sort);
      });
    });

    group('first()', () {
      test('returns PageRequest for the first page (0)', () {
        final sort = Sort.by(['name']);
        final request = PageRequest(pageNumber: 3, pageSize: 20, sort: sort);
        final firstRequest = request.first();

        expect(firstRequest.pageNumber, 0);
        expect(firstRequest.pageSize, 20);
        expect(firstRequest.sort, sort);
      });

      test('returns new PageRequest with pageNumber 0 when already on first page', () {
        final sort = Sort.by(['name']);
        final request = PageRequest(pageNumber: 0, pageSize: 20, sort: sort);
        final firstRequest = request.first();

        expect(firstRequest.pageNumber, 0);
        expect(firstRequest.pageSize, 20);
        expect(firstRequest.sort, sort);
        expect(firstRequest, equals(request));
      });
    });

    group('previousOrFirst()', () {
      test('returns first page when on page 0', () {
        const request = PageRequest(pageNumber: 0, pageSize: 10);
        final result = request.previousOrFirst();

        expect(result.pageNumber, 0);
      });

      test('returns previous page when on page > 0', () {
        const request = PageRequest(pageNumber: 2, pageSize: 10);
        final result = request.previousOrFirst();

        expect(result.pageNumber, 1);
      });
    });

    group('withPage()', () {
      test('returns new PageRequest with updated pageNumber', () {
        final sort = Sort.by(['name']);
        final request = PageRequest(pageNumber: 0, pageSize: 20, sort: sort);
        final newRequest = request.withPage(3);

        expect(newRequest.pageNumber, 3);
        expect(newRequest.pageSize, 20);
        expect(newRequest.sort, sort);
      });

      test('throws AssertionError when new pageNumber is negative', () {
        const request = PageRequest(pageSize: 20);
        expect(
          () => request.withPage(-1),
          throwsA(
            isA<AssertionError>().having(
              (e) => e.message,
              'message',
              'Page index must not be less than zero',
            ),
          ),
        );
      });
    });

    group('withSort()', () {
      test('returns new PageRequest with updated Sort', () {
        const request = PageRequest(pageNumber: 1, pageSize: 20);
        final sort = Sort.by(['created_at'], direction: Direction.desc);
        final newRequest = request.withSort(sort);

        expect(newRequest.pageNumber, 1);
        expect(newRequest.pageSize, 20);
        expect(newRequest.sort, sort);
      });
    });

    group('operator == and hashCode', () {
      test('correctly evaluates equality and consistent hashCode', () {
        final sort1 = Sort.by(['name']);
        final sort2 = Sort.by(['name']);
        final sort3 = Sort.by(['age']);

        final request1 = PageRequest(pageNumber: 1, pageSize: 10, sort: sort1);
        final request2 = PageRequest(pageNumber: 1, pageSize: 10, sort: sort2);
        final requestDiffSort = PageRequest(pageNumber: 1, pageSize: 10, sort: sort3);
        final requestDiffPage = PageRequest(pageNumber: 2, pageSize: 10, sort: sort1);
        final requestDiffSize = PageRequest(pageNumber: 1, pageSize: 20, sort: sort1);
        final testPageRequest = _TestPageRequest(pageNumber: 1, pageSize: 10, sort: sort1);

        expect(request1 == request1, isTrue);
        expect(request1 == request2, isTrue);
        expect(request1.hashCode, request2.hashCode);

        expect(request1 == requestDiffSort, isFalse);
        expect(request1 == requestDiffPage, isFalse);
        expect(request1 == requestDiffSize, isFalse);
        expect(request1 == testPageRequest, isFalse);
        expect(request1 == Object(), isFalse);
      });
    });

    group('toString()', () {
      test('returns formatted string for unsorted PageRequest', () {
        const request = PageRequest(pageNumber: 0, pageSize: 20);
        expect(request.toString(), 'Page request [number: 0, size: 20, sort: unsorted]');
      });

      test('returns formatted string for sorted PageRequest', () {
        final request = PageRequest(pageNumber: 1, pageSize: 10, sort: Sort.by(['name']));
        expect(request.toString(), 'Page request [number: 1, size: 10, sort: name: asc]');
      });
    });
  });
}
