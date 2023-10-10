// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reaction _$ReactionFromJson(Map json) => Reaction(
      name: json['name'] as String? ?? 'Action',
      action: ActionModel.fromJson(json['action'] as Map),
      trigger: TriggerModel.fromJson(json['trigger'] as Map),
    );

Map<String, dynamic> _$ReactionToJson(Reaction instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('name', instance.name, instance.name, 'Action');
  val['action'] = instance.action.toJson();
  val['trigger'] = instance.trigger.toJson();
  return val;
}
