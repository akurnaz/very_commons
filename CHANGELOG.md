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

## 0.2.0

- Added `const` constructors to `Order`, `Sort`, `PageRequest`, `Chunk`, and `SliceImpl` classes.

## 0.1.0

- Initial version.
