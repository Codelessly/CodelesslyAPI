// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reaction _$ReactionFromJson(Map json) => Reaction(
      name: json['name'] as String? ?? 'Action',
      action: actionFromJson(json['action'] as Map),
      trigger: TriggerModel.fromJson(json['trigger'] as Map),
    );

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
      'name': instance.name,
      'action': instance.action.toJson(),
      'trigger': instance.trigger.toJson(),
    };
