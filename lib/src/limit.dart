/// [Limit] represents the maximum value up to which an operation should continue processing.
/// It may be used for defining the [max] number of results within a repository finder method
/// or if applicable a template operation.
///
/// A [isUnlimited] is used to indicate that there is no [Limit] defined, which should be favored
/// over using `null` to indicate the absence of an actual [Limit].
///
/// [Limit] itself does not make assumptions about the actual [max] value sign. This means that a negative
/// value may be valid within a defined context. A zero limit can be useful in cases where the result is not needed but
/// the underlying activity to compute results might be required.
sealed class Limit {
  const Limit();

  /// Returns a [Limit] instance that does not define [max] and answers [isUnlimited] with `true`.
  const factory Limit.unlimited() = Unlimited;

  /// Creates a new [Limit] from the given [max] value.
  const factory Limit.of(int max) = Limited;

  /// The max number of potential results.
  ///
  /// Throws a [StateError] if the limit [isUnlimited].
  int get max;

  /// Returns `true` if limiting (maximum value) should be applied.
  bool get isLimited;

  /// Returns `true` if no limiting (maximum value) should be applied.
  bool get isUnlimited => !isLimited;
}

/// [Limit] implementation representing a defined upper boundary.
final class Limited extends Limit {
  @override
  final int max;

  /// Creates a new [Limited] instance with the given [max] value.
  const Limited(this.max);

  @override
  bool get isLimited => true;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Limited && max == other.max;
  }

  @override
  int get hashCode => max.hashCode;

  @override
  String toString() => 'Limit($max)';
}

/// [Limit] implementation representing no limit.
final class Unlimited extends Limit {
  /// Creates a new [Unlimited] instance.
  const Unlimited();

  @override
  int get max => throw StateError(
    "Unlimited does not define 'max'. Please check 'isLimited' before attempting to read 'max'",
  );

  @override
  bool get isLimited => false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Unlimited;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() => 'unlimited';
}
