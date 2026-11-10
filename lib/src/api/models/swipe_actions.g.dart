// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_actions.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$SwipeActionModelOmitDefaults(
  SwipeActionModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.id, '')) json.remove('id');
  if (isJsonDefault(instance.label, '')) json.remove('label');
  if (isJsonDefault(
    instance.background,
    const ColorRGBA(r: 0.86, g: 0.15, b: 0.15, a: 1),
  ))
    json.remove('background');
  if (isJsonDefault(instance.foreground, ColorRGBA.white))
    json.remove('foreground');
  if (isJsonDefault(instance.removes, true)) json.remove('removes');
  return json;
}

Map<String, dynamic> _$SwipeActionsModelOmitDefaults(
  SwipeActionsModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.startActions, const []))
    json.remove('startActions');
  if (isJsonDefault(instance.endActions, const [])) json.remove('endActions');
  if (isJsonDefault(instance.threshold, 0.4)) json.remove('threshold');
  if (isJsonDefault(instance.undo, true)) json.remove('undo');
  if (isJsonDefault(instance.undoMs, 4000)) json.remove('undoMs');
  if (isJsonDefault(instance.undoMessage, r'${result.label}'))
    json.remove('undoMessage');
  if (isJsonDefault(instance.apply, ListApply.none)) json.remove('apply');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwipeActionModel _$SwipeActionModelFromJson(Map json) => SwipeActionModel(
  id: json['id'] as String? ?? '',
  label: json['label'] as String? ?? '',
  icon: json['icon'] == null
      ? null
      : MultiSourceIconModel.fromJson(json['icon'] as Map),
  background: json['background'] == null
      ? const ColorRGBA(r: 0.86, g: 0.15, b: 0.15, a: 1)
      : ColorRGBA.fromJson(json['background']),
  foreground: json['foreground'] == null
      ? ColorRGBA.white
      : ColorRGBA.fromJson(json['foreground']),
  removes: json['removes'] as bool? ?? true,
);

Map<String, dynamic> _$SwipeActionModelToJson(SwipeActionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'icon': ?instance.icon?.toJson(),
      'background': instance.background.toJson(),
      'foreground': instance.foreground.toJson(),
      'removes': instance.removes,
    };

SwipeActionsModel _$SwipeActionsModelFromJson(Map json) => SwipeActionsModel(
  enabled: json['enabled'] as bool? ?? true,
  startActions:
      (json['startActions'] as List<dynamic>?)
          ?.map((e) => SwipeActionModel.fromJson(e as Map))
          .toList() ??
      const [],
  endActions:
      (json['endActions'] as List<dynamic>?)
          ?.map((e) => SwipeActionModel.fromJson(e as Map))
          .toList() ??
      const [],
  threshold: (json['threshold'] as num?)?.toDouble() ?? 0.4,
  undo: json['undo'] as bool? ?? true,
  undoMs: (json['undoMs'] as num?)?.toInt() ?? 4000,
  undoMessage: json['undoMessage'] as String? ?? r'${result.label}',
  apply:
      $enumDecodeNullable(
        _$ListApplyEnumMap,
        json['apply'],
        unknownValue: ListApply.none,
      ) ??
      ListApply.none,
);

Map<String, dynamic> _$SwipeActionsModelToJson(SwipeActionsModel instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'startActions': instance.startActions.map((e) => e.toJson()).toList(),
      'endActions': instance.endActions.map((e) => e.toJson()).toList(),
      'threshold': instance.threshold,
      'undo': instance.undo,
      'undoMs': instance.undoMs,
      'undoMessage': instance.undoMessage,
      'apply': _$ListApplyEnumMap[instance.apply]!,
    };

const _$ListApplyEnumMap = {
  ListApply.none: 'none',
  ListApply.variable: 'variable',
  ListApply.cloud: 'cloud',
};
