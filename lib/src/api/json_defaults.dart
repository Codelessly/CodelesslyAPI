import 'package:collection/collection.dart';

/// Leaves a JSON key out of `toJson` when [test] returns true for the
/// instance being serialized.
///
/// Read by `tool/json_defaults_builder`, which generates the
/// `_$<Class>OmitDefaults` function that each class calls from its `toJson`.
class JsonOmitIf {
  /// Called with the instance being serialized.
  final bool Function(Never instance) test;

  /// Creates a [JsonOmitIf] that omits the annotated field when [test] is
  /// true.
  const JsonOmitIf(this.test);
}

/// Marks the value a field had before its constructor default changed.
///
/// Stored JSON leaves out fields that equal their default, so changing a
/// default would change every design saved with the old one. A field with
/// this annotation is omitted from `toJson` when it equals [value] instead of
/// the constructor default, and should read a missing key as [value] through
/// `@JsonKey(readValue: ...)`. Literal values can use
/// `@JsonKey(defaultValue: ...)` alone.
///
/// Read by `tool/json_defaults_builder`.
class JsonLegacyDefault {
  /// The value stored designs imply when the key is missing.
  final Object? value;

  /// Creates a [JsonLegacyDefault] for [value].
  const JsonLegacyDefault(this.value);
}

const DeepCollectionEquality _equality = DeepCollectionEquality();

/// Whether [value] equals the constructor default [defaultValue], comparing
/// lists, maps and sets by content.
///
/// Used by the generated `_$<Class>OmitDefaults` functions so `toJson` leaves
/// out fields that `fromJson` would restore to the same value anyway.
bool isJsonDefault(Object? value, Object? defaultValue) {
  if (value is Iterable || value is Map) {
    return _equality.equals(value, defaultValue);
  }
  return value == defaultValue;
}
