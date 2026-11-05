// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_model.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ScriptParamOmitDefaults(
  ScriptParam instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.description, '')) json.remove('description');
  return json;
}

Map<String, dynamic> _$ScriptModelOmitDefaults(
  ScriptModel instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.description, '')) json.remove('description');
  if (isJsonDefault(instance.params, const [])) json.remove('params');
  if (isJsonDefault(instance.source, '')) json.remove('source');
  if (isJsonDefault(instance.version, 1)) json.remove('version');
  if (isJsonDefault(instance.capabilities, const []))
    json.remove('capabilities');
  if (isJsonDefault(instance.timeoutMs, 1000)) json.remove('timeoutMs');
  if (isJsonDefault(instance.memoryLimitMb, 32)) json.remove('memoryLimitMb');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScriptParam _$ScriptParamFromJson(Map json) => ScriptParam(
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  defaultValue: json['defaultValue'],
);

Map<String, dynamic> _$ScriptParamToJson(ScriptParam instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'defaultValue': ?instance.defaultValue,
    };

ScriptModel _$ScriptModelFromJson(Map json) => ScriptModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  params:
      (json['params'] as List<dynamic>?)
          ?.map((e) => ScriptParam.fromJson(e as Map))
          .toList() ??
      const [],
  source: json['source'] as String? ?? '',
  version: (json['version'] as num?)?.toInt() ?? 1,
  capabilities: json['capabilities'] == null
      ? const []
      : _capabilitiesFromJson(json['capabilities']),
  timeoutMs: (json['timeoutMs'] as num?)?.toInt() ?? 1000,
  memoryLimitMb: (json['memoryLimitMb'] as num?)?.toInt() ?? 32,
  pageId: json['pageId'] as String?,
);

Map<String, dynamic> _$ScriptModelToJson(ScriptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'params': instance.params.map((e) => e.toJson()).toList(),
      'source': instance.source,
      'version': instance.version,
      'capabilities': instance.capabilities
          .map((e) => _$ScriptCapabilityEnumMap[e]!)
          .toList(),
      'timeoutMs': instance.timeoutMs,
      'memoryLimitMb': instance.memoryLimitMb,
      'pageId': ?instance.pageId,
    };

const _$ScriptCapabilityEnumMap = {
  ScriptCapability.variablesRead: 'variables.read',
  ScriptCapability.variablesWrite: 'variables.write',
  ScriptCapability.nodesRead: 'nodes.read',
  ScriptCapability.navigation: 'navigation',
  ScriptCapability.api: 'api',
  ScriptCapability.cloud: 'cloud',
  ScriptCapability.actions: 'actions',
  ScriptCapability.clock: 'clock',
};
