// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_variant_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetVariantAction _$SetVariantActionFromJson(Map json) => SetVariantAction(
      nodeID: json['nodeID'] as String,
      variantID: json['variantID'] as String,
    )..type = $enumDecode(_$ActionTypeEnumMap, json['type']);

Map<String, dynamic> _$SetVariantActionToJson(SetVariantAction instance) =>
    <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'nodeID': instance.nodeID,
      'variantID': instance.variantID,
    };

const _$ActionTypeEnumMap = {
  ActionType.navigation: 'navigation',
  ActionType.link: 'link',
  ActionType.submit: 'submit',
  ActionType.setValue: 'setValue',
  ActionType.setVariant: 'setVariant',
  ActionType.setVariable: 'setVariable',
  ActionType.callFunction: 'callFunction',
  ActionType.callApi: 'callApi',
};
