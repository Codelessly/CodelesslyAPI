// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawValuePart _$RawValuePartFromJson(Map json) => RawValuePart(
      json['value'],
    );

Map<String, dynamic> _$RawValuePartToJson(RawValuePart instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('value', instance.value);
  return val;
}

VariablePart _$VariablePartFromJson(Map json) => VariablePart(
      variableName: json['variableName'] as String,
      jsonPath: json['jsonPath'] as String?,
    );

Map<String, dynamic> _$VariablePartToJson(VariablePart instance) {
  final val = <String, dynamic>{
    'variableName': instance.variableName,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('jsonPath', instance.jsonPath);
  return val;
}

Expression _$ExpressionFromJson(Map json) => Expression(
      operator: $enumDecode(_$ConditionOperationEnumMap, json['operator']),
      leftPart: json['leftPart'],
      rightPart: json['rightPart'],
    );

Map<String, dynamic> _$ExpressionToJson(Expression instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('leftPart', instance.leftPart);
  writeNotNull('rightPart', instance.rightPart);
  val['operator'] = _$ConditionOperationEnumMap[instance.operator]!;
  return val;
}

const _$ConditionOperationEnumMap = {
  ConditionOperation.EqualsTo: 'EqualsTo',
  ConditionOperation.NotEqualsTo: 'NotEqualsTo',
  ConditionOperation.GreaterThan: 'GreaterThan',
  ConditionOperation.LessThan: 'LessThan',
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
      (json['actions'] as List<dynamic>?)
          ?.map((e) => ActionModel.fromJson(e as Map))
          .toList(),
    );

Map<String, dynamic> _$ElseConditionToJson(ElseCondition instance) =>
    <String, dynamic>{
      'actions': instance.actions.map((e) => e.toJson()).toList(),
    };

Condition _$ConditionFromJson(Map json) => Condition(
      mode: $enumDecode(_$ConditionModeEnumMap, json['mode']),
      expression: BaseExpression.fromJson(
          Map<String, dynamic>.from(json['expression'] as Map)),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => ActionModel.fromJson(e as Map))
          .toList(),
    );

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
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
    );

Map<String, dynamic> _$ConditionGroupToJson(ConditionGroup instance) {
  final val = <String, dynamic>{
    'id': instance.id,
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
