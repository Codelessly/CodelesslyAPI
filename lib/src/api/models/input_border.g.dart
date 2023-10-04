// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_border.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InputBorderModel _$InputBorderModelFromJson(Map json) => InputBorderModel(
      borderType:
          $enumDecodeNullable(_$BorderTypeEnumEnumMap, json['borderType']) ??
              BorderTypeEnum.outline,
      borderSide: json['borderSide'] == null
          ? const BorderSideModel()
          : BorderSideModel.fromJson(json['borderSide'] as Map),
      cornerRadius: json['cornerRadius'] == null
          ? const CornerRadius.all(RadiusModel.circular(4))
          : CornerRadius.fromJson(json['cornerRadius']),
      gapPadding: (json['gapPadding'] as num?)?.toDouble() ?? 4,
    );

Map<String, dynamic> _$InputBorderModelToJson(InputBorderModel instance) {
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

  writeNotNull('borderType', instance.borderType,
      _$BorderTypeEnumEnumMap[instance.borderType]!, BorderTypeEnum.outline);
  writeNotNull('borderSide', instance.borderSide, instance.borderSide.toJson(),
      const BorderSideModel());
  writeNotNull(
      'cornerRadius',
      instance.cornerRadius,
      instance.cornerRadius.toJson(),
      const CornerRadius.all(RadiusModel.circular(4)));
  writeNotNull('gapPadding', instance.gapPadding, instance.gapPadding, 4);
  return val;
}

const _$BorderTypeEnumEnumMap = {
  BorderTypeEnum.none: 'none',
  BorderTypeEnum.outline: 'outline',
  BorderTypeEnum.underline: 'underline',
};
