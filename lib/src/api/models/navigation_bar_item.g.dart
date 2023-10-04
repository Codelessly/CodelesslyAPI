// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_bar_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

M2NavigationBarItem _$M2NavigationBarItemFromJson(Map json) =>
    M2NavigationBarItem(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: MultiSourceIconModel.fromJson(json['icon'] as Map),
      differSelectedIcon: json['differSelectedIcon'] as bool? ?? false,
      tooltip: json['tooltip'] as String?,
      selectedIcon: json['selectedIcon'] == null
          ? null
          : MultiSourceIconModel.fromJson(json['selectedIcon'] as Map),
      backgroundColor: json['backgroundColor'] == null
          ? null
          : ColorRGBA.fromJson(json['backgroundColor']),
    )..reactions = (json['reactions'] as List<dynamic>)
        .map((e) => Reaction.fromJson(e as Map))
        .toList();

Map<String, dynamic> _$M2NavigationBarItemToJson(M2NavigationBarItem instance) {
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'id': instance.id,
    'label': instance.label,
    'icon': instance.icon.toJson(),
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

  writeNotNull('selectedIcon', instance.selectedIcon,
      instance.selectedIcon?.toJson(), null);
  writeNotNull('differSelectedIcon', instance.differSelectedIcon,
      instance.differSelectedIcon, false);
  writeNotNull('tooltip', instance.tooltip, instance.tooltip, null);
  writeNotNull('backgroundColor', instance.backgroundColor,
      instance.backgroundColor?.toJson(), null);
  return val;
}

M3NavigationBarItem _$M3NavigationBarItemFromJson(Map json) =>
    M3NavigationBarItem(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: MultiSourceIconModel.fromJson(json['icon'] as Map),
      tooltip: json['tooltip'] as String?,
      selectedIcon: json['selectedIcon'] == null
          ? null
          : MultiSourceIconModel.fromJson(json['selectedIcon'] as Map),
      differSelectedIcon: json['differSelectedIcon'] as bool? ?? false,
    )..reactions = (json['reactions'] as List<dynamic>)
        .map((e) => Reaction.fromJson(e as Map))
        .toList();

Map<String, dynamic> _$M3NavigationBarItemToJson(M3NavigationBarItem instance) {
  final val = <String, dynamic>{
    'reactions': instance.reactions.map((e) => e.toJson()).toList(),
    'id': instance.id,
    'label': instance.label,
    'icon': instance.icon.toJson(),
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

  writeNotNull('selectedIcon', instance.selectedIcon,
      instance.selectedIcon?.toJson(), null);
  writeNotNull('differSelectedIcon', instance.differSelectedIcon,
      instance.differSelectedIcon, false);
  writeNotNull('tooltip', instance.tooltip, instance.tooltip, null);
  return val;
}
