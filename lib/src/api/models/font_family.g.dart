// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_family.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FontFamilyModel _$FontFamilyModelFromJson(Map json) => FontFamilyModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      fontVariants: (json['fontVariants'] as List<dynamic>)
          .map((e) =>
              FontVariantModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$FontFamilyModelToJson(FontFamilyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fontVariants': instance.fontVariants.map((e) => e.toJson()).toList(),
    };

FontVariantModel _$FontVariantModelFromJson(Map json) => FontVariantModel(
      name: json['name'] as String? ?? 'regular',
      weight: $enumDecodeNullable(_$FontWeightNumericEnumMap, json['weight']) ??
          FontWeightNumeric.w400,
      style: json['style'] as String? ?? 'Normal',
      fontURL: json['fontURL'] as String? ?? '',
      previewURL: json['previewURL'] as String? ?? '',
    );

Map<String, dynamic> _$FontVariantModelToJson(FontVariantModel instance) {
  final val = <String, dynamic>{};

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

  writeNotNull('name', instance.name, instance.name, 'regular');
  writeNotNull('weight', instance.weight,
      _$FontWeightNumericEnumMap[instance.weight]!, FontWeightNumeric.w400);
  writeNotNull('style', instance.style, instance.style, 'Normal');
  writeNotNull('fontURL', instance.fontURL, instance.fontURL, '');
  writeNotNull('previewURL', instance.previewURL, instance.previewURL, '');
  return val;
}

const _$FontWeightNumericEnumMap = {
  FontWeightNumeric.w100: 'w100',
  FontWeightNumeric.w200: 'w200',
  FontWeightNumeric.w300: 'w300',
  FontWeightNumeric.w400: 'w400',
  FontWeightNumeric.w500: 'w500',
  FontWeightNumeric.w600: 'w600',
  FontWeightNumeric.w700: 'w700',
  FontWeightNumeric.w800: 'w800',
  FontWeightNumeric.w900: 'w900',
};
