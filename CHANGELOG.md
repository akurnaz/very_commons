# Changelog

## [Unreleased]

- Added `isAscending`, `isDescending` getters and `fromString` method to `Direction`.
- Added `NullHandling` enum.
- Added default constructor, `defaultDirection`, `defaultIgnoreCase`, `defaultNullHandling`, `isIgnoreCase`, `nullHandling`, `isAscending`, `isDescending`, `copyWith`, and `reverse` to `Order`.
- Made `Sort` class extend `Iterable<Order>`.
- Added `unsorted` constant, `Sort()` factory constructor, and `Sort.by()` constructor to `Sort`.
- Added `isSorted`, `isUnsorted` getters to `Sort`.
- Added `descending`, `ascending`, `and`, `reverse`, and `getOrderFor` methods to `Sort`.
- Added equality (`==`), `hashCode`, and `toString` implementations to `Sort`.
- Added `isPaged` and `isUnpaged` getters to `Pageable`.
- Renamed `page` to `pageNumber`, `size` to `pageSize`, and replaced `previous()` with `previousOrFirst()` in `Pageable`.
- Made `sort` parameter optional in `PageRequest` constructor, defaulting to `Sort.unsorted`.
- Added default value `0` for `pageNumber` in `PageRequest` constructor.
- Added `AbstractPageRequest` abstract class implementing common `Pageable` behavior.
- Made `PageRequest` extend `AbstractPageRequest`.
- Added `withSort` method and `toString` implementation to `PageRequest`.
- Added `Unpaged` class implementing `Pageable` with `Unpaged.unsorted` constant and `Unpaged.sorted()` factory constructor.

## 0.2.0

- Added `const` constructors to `Order`, `Sort`, `PageRequest`, `Chunk`, and `SliceImpl` classes.

## 0.1.0

- Initial version.
