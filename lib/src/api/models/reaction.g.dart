// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonDefaultsGenerator
// **************************************************************************

Map<String, dynamic> _$ReactionOmitDefaults(
  Reaction instance,
  Map<String, dynamic> json,
) {
  if (isJsonDefault(instance.name, 'Action')) json.remove('name');
  return json;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reaction _$ReactionFromJson(Map json) => Reaction(
  id: json['id'] as String?,
  name: json['name'] as String? ?? 'Action',
  action: ActionModel.fromJson(json['action'] as Map),
  trigger: TriggerModel.fromJson(json['trigger'] as Map),
);

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
  'name': instance.name,
  'action': instance.action.toJson(),
  'trigger': instance.trigger.toJson(),
  'id': instance.id,
};
