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

Map<String, dynamic> _$VariablePartToJson(VariablePart instance) {
  final val = <String, dynamic>{};

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('valueString', instance.valueString, instance.valueString, '');
  return val;
}

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
  ConditionOperation.greaterThanOrEqualTo: 'greaterThanOrEqualTo',
  ConditionOperation.lessThanOrEqualTo: 'lessThanOrEqualTo',
  ConditionOperation.isEmpty: 'isEmpty',
  ConditionOperation.isNotEmpty: 'isNotEmpty',
  ConditionOperation.contains: 'contains',
  ConditionOperation.isOdd: 'isOdd',
  ConditionOperation.isEven: 'isEven',
  ConditionOperation.isNull: 'isNull',
  ConditionOperation.isTrue: 'isTrue',
  ConditionOperation.isFalse: 'isFalse',
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
      lastUpdated:
          const DateTimeConverter().fromJson(json['lastUpdated'] as int?),
    );

Map<String, dynamic> _$ElseConditionToJson(ElseCondition instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('lastUpdated', instance.lastUpdated,
      const DateTimeConverter().toJson(instance.lastUpdated), null);
  val['actions'] = instance.actions.map((e) => e.toJson()).toList();
  return val;
}

Condition _$ConditionFromJson(Map json) => Condition(
      id: json['id'] as String,
      mode: $enumDecode(_$ConditionModeEnumMap, json['mode']),
      expression: BaseExpression.fromJson(
          Map<String, dynamic>.from(json['expression'] as Map)),
      actions: (json['actions'] as List<dynamic>)
          .map((e) => ActionModel.fromJson(e as Map))
          .toList(),
      lastUpdated:
          const DateTimeConverter().fromJson(json['lastUpdated'] as int?),
    );

Map<String, dynamic> _$ConditionToJson(Condition instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('lastUpdated', instance.lastUpdated,
      const DateTimeConverter().toJson(instance.lastUpdated), null);
  val['expression'] = instance.expression.toJson();
  val['actions'] = instance.actions.map((e) => e.toJson()).toList();
  val['mode'] = _$ConditionModeEnumMap[instance.mode]!;
  return val;
}

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
      lastUpdated:
          const DateTimeConverter().fromJson(json['lastUpdated'] as int?),
    );

Map<String, dynamic> _$ConditionGroupToJson(ConditionGroup instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('lastUpdated', instance.lastUpdated,
      const DateTimeConverter().toJson(instance.lastUpdated), null);
  val['ifCondition'] = instance.ifCondition.toJson();
  val['elseIfConditions'] =
      instance.elseIfConditions.map((e) => e.toJson()).toList();
  writeNotNull('elseCondition', instance.elseCondition,
      instance.elseCondition?.toJson(), null);
  writeNotNull('name', instance.name, instance.name, null);
  return val;
}

CanvasConditions _$CanvasConditionsFromJson(Map json) => CanvasConditions(
      id: json['id'] as String,
      conditions: (json['conditions'] as Map).map(
        (k, e) => MapEntry(k as String,
            BaseCondition.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
      lastUpdated:
          const DateTimeConverter().fromJson(json['lastUpdated'] as int?),
      projectId: json['project'] as String,
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$CanvasConditionsToJson(CanvasConditions instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'conditions': instance.conditions.map((k, e) => MapEntry(k, e.toJson())),
  };

  void writeNotNull(
      String key, dynamic value, dynamic jsonValue, dynamic defaultValue) {
    final bool serialize =
        shouldSerialize(key, value, jsonValue, defaultValue, false);

    if (serialize) {
      val[key] = jsonValue;
    }
  }

  writeNotNull('lastUpdated', instance.lastUpdated,
      const DateTimeConverter().toJson(instance.lastUpdated), null);
  val['owner'] = instance.owner;
  val['project'] = instance.projectId;
  return val;
}
