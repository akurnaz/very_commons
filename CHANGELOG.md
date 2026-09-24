# Changelog

## [Unreleased]

- Added `CursorScrollPosition` class for cursor-based pagination.
- Added `cursor` factory method to `ScrollPosition`.
- Removed `forward`, `backward`, and `of` factory methods from `ScrollPosition`.
- Updated `ScrollPosition.keyset` factory method to accept optional named `keys` and `direction` parameters.

## 0.5.1

- Added support for nested maps and dot-separated property paths in `KeysetScrollPosition.positionFunction`.

## 0.5.0

- Removed `Iterable<Order>` inheritance from `Sort`.
- Added `orders` property to `Sort`.
- Removed `Iterable<T>` inheritance from `Slice`.
- Removed `iterator` from `Chunk`.
- Introduced `ScrollPosition`, `OffsetScrollPosition`, and `Window`.
- Added `ScrollDirection` enum and `KeysetScrollPosition` class.
- Added `keyset`, `forward`, `backward`, and `of` factory methods to `ScrollPosition`.

## 0.4.0

- Added `Limit` sealed class with `Limited` and `Unlimited` implementations.
- Added `limit` getter to `Pageable`, `AbstractPageRequest`, and `Unpaged`.

## 0.3.0

- Added `NullHandling` enum and enhanced `Direction` and `Order` with utility getters and `copyWith`/`reverse` methods.
- Enhanced `Sort` with factory constructors (`Sort.by`, `unsorted`), utility getters, and helper methods.
- Introduced `AbstractPageRequest` and `Unpaged` classes implementing `Pageable`.
- Converted pagination navigation methods to getters and renamed `page`/`size` to `pageNumber`/`pageSize`.
- Enhanced `Slice`, `Chunk`, `SliceImpl`, and `PageImpl` with new getters, unmodifiable content, and equality/toString implementations.

## 0.2.0

- Added `const` constructors to `Order`, `Sort`, `PageRequest`, `Chunk`, and `SliceImpl` classes.

## 0.1.0

- Initial version.
