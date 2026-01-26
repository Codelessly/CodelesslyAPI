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
      )
      ..reactions = (json['reactions'] as List<dynamic>)
          .map((e) => Reaction.fromJson(e as Map))
          .toList();

Map<String, dynamic> _$M2NavigationBarItemToJson(
  M2NavigationBarItem instance,
) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'id': instance.id,
  'label': instance.label,
  'icon': instance.icon.toJson(),
  'selectedIcon': ?instance.selectedIcon?.toJson(),
  'differSelectedIcon': instance.differSelectedIcon,
  'tooltip': ?instance.tooltip,
  'backgroundColor': ?instance.backgroundColor?.toJson(),
};

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
      )
      ..reactions = (json['reactions'] as List<dynamic>)
          .map((e) => Reaction.fromJson(e as Map))
          .toList();

Map<String, dynamic> _$M3NavigationBarItemToJson(
  M3NavigationBarItem instance,
) => <String, dynamic>{
  'reactions': instance.reactions.map((e) => e.toJson()).toList(),
  'id': instance.id,
  'label': instance.label,
  'icon': instance.icon.toJson(),
  'selectedIcon': ?instance.selectedIcon?.toJson(),
  'differSelectedIcon': instance.differSelectedIcon,
  'tooltip': ?instance.tooltip,
};
