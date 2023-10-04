// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ink_well.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InkWellModel _$InkWellModelFromJson(Map json) => InkWellModel(
      overlayColor: json['overlayColor'] == null
          ? null
          : ColorRGBA.fromJson(json['overlayColor']),
      highlightColor: json['highlightColor'] == null
          ? null
          : ColorRGBA.fromJson(json['highlightColor']),
      splashColor: json['splashColor'] == null
          ? null
          : ColorRGBA.fromJson(json['splashColor']),
      hoverColor: json['hoverColor'] == null
          ? null
          : ColorRGBA.fromJson(json['hoverColor']),
      focusColor: json['focusColor'] == null
          ? null
          : ColorRGBA.fromJson(json['focusColor']),
    );

Map<String, dynamic> _$InkWellModelToJson(InkWellModel instance) {
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

  writeNotNull('overlayColor', instance.overlayColor,
      instance.overlayColor?.toJson(), null);
  writeNotNull('highlightColor', instance.highlightColor,
      instance.highlightColor?.toJson(), null);
  writeNotNull('splashColor', instance.splashColor,
      instance.splashColor?.toJson(), null);
  writeNotNull(
      'hoverColor', instance.hoverColor, instance.hoverColor?.toJson(), null);
  writeNotNull(
      'focusColor', instance.focusColor, instance.focusColor?.toJson(), null);
  return val;
}
