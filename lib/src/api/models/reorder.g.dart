// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ReorderModelOmitDefaults(
  ReorderModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.enabled, true)) json.remove('enabled');
  if (isJsonDefault(instance.start, ReorderStart.handle)) json.remove('start');
  if (isJsonDefault(instance.group, '')) json.remove('group');
  if (isJsonDefault(instance.listKey, '')) json.remove('listKey');
  if (isJsonDefault(instance.canReorderIf, '')) json.remove('canReorderIf');
  if (isJsonDefault(instance.canDropIf, '')) json.remove('canDropIf');
  if (isJsonDefault(instance.proxyElevation, 6)) json.remove('proxyElevation');
  if (isJsonDefault(instance.proxyScale, 1)) json.remove('proxyScale');
  if (isJsonDefault(instance.proxyOpacity, 1)) json.remove('proxyOpacity');
  if (isJsonDefault(instance.placeholder, ReorderPlaceholder.gap))
    json.remove('placeholder');
  if (isJsonDefault(instance.placeholderNodeId, ''))
    json.remove('placeholderNodeId');
  if (isJsonDefault(instance.autoScroll, true)) json.remove('autoScroll');
  if (isJsonDefault(instance.autoScrollEdge, 48)) json.remove('autoScrollEdge');
  if (isJsonDefault(instance.keyboard, true)) json.remove('keyboard');
  if (isJsonDefault(instance.apply, ListApply.none)) json.remove('apply');
  if (isJsonDefault(instance.orderField, 'order')) json.remove('orderField');
  if (isJsonDefault(instance.listField, '')) json.remove('listField');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReorderModel _$ReorderModelFromJson(Map json) => ReorderModel(
  enabled: json['enabled'] as bool? ?? true,
  start:
      $enumDecodeNullable(
        _$ReorderStartEnumMap,
        json['start'],
        unknownValue: ReorderStart.handle,
      ) ??
      ReorderStart.handle,
  group: json['group'] as String? ?? '',
  listKey: json['listKey'] as String? ?? '',
  canReorderIf: json['canReorderIf'] as String? ?? '',
  canDropIf: json['canDropIf'] as String? ?? '',
  proxyElevation: (json['proxyElevation'] as num?)?.toDouble() ?? 6,
  proxyScale: (json['proxyScale'] as num?)?.toDouble() ?? 1,
  proxyOpacity: (json['proxyOpacity'] as num?)?.toDouble() ?? 1,
  placeholder:
      $enumDecodeNullable(
        _$ReorderPlaceholderEnumMap,
        json['placeholder'],
        unknownValue: ReorderPlaceholder.gap,
      ) ??
      ReorderPlaceholder.gap,
  placeholderNodeId: json['placeholderNodeId'] as String? ?? '',
  autoScroll: json['autoScroll'] as bool? ?? true,
  autoScrollEdge: (json['autoScrollEdge'] as num?)?.toDouble() ?? 48,
  keyboard: json['keyboard'] as bool? ?? true,
  apply:
      $enumDecodeNullable(
        _$ListApplyEnumMap,
        json['apply'],
        unknownValue: ListApply.none,
      ) ??
      ListApply.none,
  orderField: json['orderField'] as String? ?? 'order',
  listField: json['listField'] as String? ?? '',
);

Map<String, dynamic> _$ReorderModelToJson(ReorderModel instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'start': _$ReorderStartEnumMap[instance.start]!,
      'group': instance.group,
      'listKey': instance.listKey,
      'canReorderIf': instance.canReorderIf,
      'canDropIf': instance.canDropIf,
      'proxyElevation': instance.proxyElevation,
      'proxyScale': instance.proxyScale,
      'proxyOpacity': instance.proxyOpacity,
      'placeholder': _$ReorderPlaceholderEnumMap[instance.placeholder]!,
      'placeholderNodeId': instance.placeholderNodeId,
      'autoScroll': instance.autoScroll,
      'autoScrollEdge': instance.autoScrollEdge,
      'keyboard': instance.keyboard,
      'apply': _$ListApplyEnumMap[instance.apply]!,
      'orderField': instance.orderField,
      'listField': instance.listField,
    };

const _$ReorderStartEnumMap = {
  ReorderStart.handle: 'handle',
  ReorderStart.longPress: 'longPress',
  ReorderStart.press: 'press',
};

const _$ReorderPlaceholderEnumMap = {
  ReorderPlaceholder.gap: 'gap',
  ReorderPlaceholder.node: 'node',
};

const _$ListApplyEnumMap = {
  ListApply.none: 'none',
  ListApply.variable: 'variable',
  ListApply.cloud: 'cloud',
};
