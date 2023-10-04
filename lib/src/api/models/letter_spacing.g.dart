// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_spacing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LetterSpacing _$LetterSpacingFromJson(Map json) => LetterSpacing(
      value: (json['value'] as num).toDouble(),
      unit: $enumDecodeNullable(_$LetterSpacingUnitEnumEnumMap, json['unit']) ??
          LetterSpacingUnitEnum.pixels,
    );

Map<String, dynamic> _$LetterSpacingToJson(LetterSpacing instance) {
  final val = <String, dynamic>{
    'value': instance.value,
  };

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool listsEqual(List? a, List? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool mapsEqual(Map? a, Map? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final k in a.keys) {
      var bValue = b[k];
      if (bValue == null && !b.containsKey(k)) return false;
      if (bValue != a[k]) return false;
    }

    return true;
  }

  /// Code from: https://github.com/google/quiver-dart/blob/master/lib/src/collection/utils.dart
  bool setsEqual(Set? a, Set? b) {
    if (a == b) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    return a.containsAll(b);
  }

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    if (value == null) return;
    bool areEqual = false;
    if (value is List) {
      areEqual = listsEqual(value, defaultValue);
    } else if (value is Map) {
      areEqual = mapsEqual(value, defaultValue);
    } else if (value is Set) {
      areEqual = setsEqual(value, defaultValue);
    } else {
      areEqual = value == defaultValue;
    }

    if (!areEqual) {
      val[key] = jsonValue;
    }
  }

  writeNotNull(
      'unit',
      instance.unit,
      _$LetterSpacingUnitEnumEnumMap[instance.unit]!,
      LetterSpacingUnitEnum.pixels);
  return val;
}

const _$LetterSpacingUnitEnumEnumMap = {
  LetterSpacingUnitEnum.pixels: 'pixels',
  LetterSpacingUnitEnum.percent: 'percent',
};
