// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawValuePart _$RawValuePartFromJson(Map json) => RawValuePart(
      json['value'] as String,
    );

Map<String, dynamic> _$RawValuePartToJson(RawValuePart instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

VariablePart _$VariablePartFromJson(Map json) => VariablePart(
      valueString: json['valueString'] as String? ?? '',
    );

Map<String, dynamic> _$VariablePartToJson(VariablePart instance) =>
    <String, dynamic>{
      'valueString': instance.valueString,
    };

Expression _$ExpressionFromJson(Map json) => Expression(
      operator: $enumDecode(_$ConditionOperationEnumMap, json['operator']),
      leftPart: ExpressionPart.fromJson(
          Map<String, dynamic>.from(json['leftPart'] as Map)),
      rightPart: ExpressionPart.fromJson(
          Map<String, dynamic>.from(json['rightPart'] as Map)),
    );

Map<String, dynamic> _$ExpressionToJson(Expression instance) =>
    <String, dynamic>{
      'leftPart': instance.leftPart.toJson(),
      'rightPart': instance.rightPart.toJson(),
      'operator': _$ConditionOperationEnumMap[instance.operator]!,
    };

const _$ConditionOperationEnumMap = {
  ConditionOperation.equalsTo: 'equalsTo',
  ConditionOperation.notEqualsTo: 'notEqualsTo',
  ConditionOperation.greaterThan: 'greaterThan',
  ConditionOperation.lessThan: 'lessThan',
};

ExpressionGroup _$ExpressionGroupFromJson(Map json) => ExpressionGroup(
      leftExpression: BaseExpression.fromJson(
          Map<String, dynamic>.from(json['leftExpression'] as Map)),
      join: $enumDecode(_$ConditionJoinEnumMap, json['join']),
      rightExpression: BaseExpression.fromJson(
          Map<String, dynamic>.from(json['rightExpression'] as Map)),
    );

Map<String, dynamic> _$ExpressionGroupToJson(ExpressionGroup instance) =>
    <String, dynamic>{
      'leftExpression': instance.leftExpression.toJson(),
      'join': _$ConditionJoinEnumMap[instance.join]!,
      'rightExpression': instance.rightExpression.toJson(),
    };

const _$ConditionJoinEnumMap = {
  ConditionJoin.and: 'and',
  ConditionJoin.or: 'or',
};

ElseCondition _$ElseConditionFromJson(Map json) => ElseCondition(
      id: json['id'] as String,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => ActionModel.fromJson(e as Map))
          .toList(),
      lastUpdated: jsonToDate(json['lastUpdated'] as int?),
    );

Map<String, dynamic> _$ElseConditionToJson(ElseCondition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lastUpdated': dateToJson(instance.lastUpdated),
      'actions': instance.actions.map((e) => e.toJson()).toList(),
    };

Condition _$ConditionFromJson(Map json) => Condition(
      id: json['id'] as String,
      mode: $enumDecode(_$ConditionModeEnumMap, json['mode']),
      expression: BaseExpression.fromJson(
          Map<String, dynamic>.from(json['expression'] as Map)),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => ActionModel.fromJson(e as Map))
          .toList(),
      lastUpdated: jsonToDate(json['lastUpdated'] as int?),
    );

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
      'id': instance.id,
      'lastUpdated': dateToJson(instance.lastUpdated),
      'expression': instance.expression.toJson(),
      'actions': instance.actions.map((e) => e.toJson()).toList(),
      'mode': _$ConditionModeEnumMap[instance.mode]!,
    };

const _$ConditionModeEnumMap = {
  ConditionMode.ifMode: 'ifMode',
  ConditionMode.elseIfMode: 'elseIfMode',
  ConditionMode.elseMode: 'elseMode',
};

ConditionGroup _$ConditionGroupFromJson(Map json) => ConditionGroup(
      id: json['id'] as String,
      name: json['name'] as String?,
      ifCondition: Condition.fromJson(
          Map<String, dynamic>.from(json['ifCondition'] as Map)),
      elseIfConditions: (json['elseIfConditions'] as List<dynamic>?)
          ?.map((e) => Condition.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      elseCondition: json['elseCondition'] == null
          ? null
          : ElseCondition.fromJson(
              Map<String, dynamic>.from(json['elseCondition'] as Map)),
      lastUpdated: jsonToDate(json['lastUpdated'] as int?),
    );

Map<String, dynamic> _$ConditionGroupToJson(ConditionGroup instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'lastUpdated': dateToJson(instance.lastUpdated),
    'ifCondition': instance.ifCondition.toJson(),
    'elseIfConditions':
        instance.elseIfConditions.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('elseCondition', instance.elseCondition?.toJson());
  writeNotNull('name', instance.name);
  return val;
}

CanvasConditions _$CanvasConditionsFromJson(Map json) => CanvasConditions(
      id: json['id'] as String,
      conditions: (json['conditions'] as Map).map(
        (k, e) => MapEntry(k as String,
            BaseCondition.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      lastUpdated: jsonToDate(json['lastUpdated'] as int?),
      projectId: json['project'] as String,
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$CanvasConditionsToJson(CanvasConditions instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conditions': instance.conditions.map((k, e) => MapEntry(k, e.toJson())),
      'lastUpdated': dateToJson(instance.lastUpdated),
      'owner': instance.owner,
      'project': instance.projectId,
    };
