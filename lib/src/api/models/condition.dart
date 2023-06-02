import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../mixins.dart';
import '../utils.dart';
import 'models.dart';

part 'condition.g.dart';

/// condition operation for basic conditions
enum ConditionOperation {
  /// equals to operator. Checks if the value of the variable is equal to the
  /// value provided.
  equalsTo,

  /// not equals to operator. Checks if the value of the variable is not equal
  /// to the value provided.
  notEqualsTo,

  /// greater than operator. Checks if the value of the variable is greater
  /// than the value provided.
  greaterThan,

  /// less than operator. Checks if the value of the variable is less than the
  /// value provided.
  lessThan;

  /// label for the operation
  String get label {
    switch (this) {
      case ConditionOperation.equalsTo:
        return 'Equal';
      case ConditionOperation.notEqualsTo:
        return 'Not Equals';
      case ConditionOperation.greaterThan:
        return 'Greater';
      case ConditionOperation.lessThan:
        return 'Less';
    }
  }

  /// short description of the operation
  String get sentence {
    switch (this) {
      case ConditionOperation.equalsTo:
        return 'equal to';
      case ConditionOperation.notEqualsTo:
        return 'not equal to';
      case ConditionOperation.greaterThan:
        return 'greater than';
      case ConditionOperation.lessThan:
        return 'less than';
    }
  }

  /// short description of the operation
  String get sign {
    switch (this) {
      case ConditionOperation.equalsTo:
        return '==';
      case ConditionOperation.notEqualsTo:
        return '!=';
      case ConditionOperation.greaterThan:
        return '>';
      case ConditionOperation.lessThan:
        return '<';
    }
  }
}

/// join operator for complex conditions
enum ConditionJoin {
  /// and operator
  and,

  /// or operator
  or;
}

/// Represents the mode of a condition (if/else if/else).
enum ConditionMode {
  /// if condition
  ifMode,

  /// else if condition
  elseIfMode,

  /// else condition
  elseMode;

  /// label for the condition
  String get label => switch (this) {
        ConditionMode.ifMode => 'If',
        ConditionMode.elseIfMode => 'Else If',
        ConditionMode.elseMode => 'Else',
      };
}

/// Represents an expression in a condition.
sealed class BaseExpression with EquatableMixin, SerializableMixin {
  /// Creates a base expression.
  const BaseExpression();

  /// Factory constructor for creating a new [BaseExpression] instance from
  /// JSON data.
  factory BaseExpression.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String?) {
      case 'Expression':
        return Expression.fromJson(json);
      case 'ExpressionGroup':
        return ExpressionGroup.fromJson(json);
      default:
        throw UnimplementedError('Unregistered type: ${json['type']}');
    }
  }
}

/// Represents an expression part in an expression. e.g. `a == b` has two
/// expression parts: `a` and `b`.
sealed class ExpressionPart with EquatableMixin, SerializableMixin {
  /// Creates an expression part.
  const ExpressionPart();

  /// Creates an expression part with the provided [type] from JSON data.
  factory ExpressionPart.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String?) {
      case 'RawValue':
        return RawValuePart.fromJson(json);
      case 'Variable':
        return VariablePart.fromJson(json);
      default:
        throw UnimplementedError('Unregistered type: ${json['type']}');
    }
  }
}

/// Represents a raw value in an expression. e.g. `a == 1` has a raw value of
/// `1`.
@JsonSerializable()
class RawValuePart extends ExpressionPart {
  /// value of the raw value.
  final dynamic value;

  /// Creates a raw value part.
  RawValuePart(this.value);

  /// Duplicates the raw value part with the provided values.
  factory RawValuePart.fromJson(Map<String, dynamic> json) =>
      _$RawValuePartFromJson(json);

  @override
  List<Object?> get props => [value];

  @override
  Map toJson() => _$RawValuePartToJson(this)..['type'] = 'RawValue';
}

/// Represents a variable in an expression. e.g. `a == b` has two variables:
/// `a` and `b`.
@JsonSerializable()
class VariablePart extends ExpressionPart {
  /// name of the variable
  final String variableName;

  /// json path to access data from the variable.
  final String? jsonPath;

  /// Creates a variable part.
  VariablePart({
    required this.variableName,
    this.jsonPath,
  });

  /// Factory constructor for creating a new [VariablePart] instance from
  /// JSON data.
  factory VariablePart.fromJson(Map<String, dynamic> json) =>
      _$VariablePartFromJson(json);

  /// Duplicates the variable part with the provided values.
  VariablePart copyWith({
    String? variableName,
    String? jsonPath,
  }) {
    return VariablePart(
      variableName: variableName ?? this.variableName,
      jsonPath: jsonPath ?? this.jsonPath,
    );
  }

  @override
  List<Object?> get props => [variableName, jsonPath];

  @override
  Map toJson() => _$VariablePartToJson(this)..['type'] = 'Variable';
}

/// Represents a simple expression in a condition. e.g. `a == b` is an
/// expression containing two expression parts: `a` and `b` and an operator
/// `==`.
@JsonSerializable()
class Expression extends BaseExpression {
  /// left side of the expression
  final ExpressionPart leftPart;

  /// right side of the expression
  final ExpressionPart rightPart;

  /// operation to perform
  final ConditionOperation operator;

  /// Creates a simple expression
  Expression({
    required this.operator,
    required this.leftPart,
    required this.rightPart,
  });

  /// Duplicates the expression with the provided values.
  Expression copyWith({
    ExpressionPart? leftPart,
    ExpressionPart? rightPart,
    ConditionOperation? operator,
  }) {
    return Expression(
      leftPart: leftPart ?? this.leftPart,
      rightPart: rightPart ?? this.rightPart,
      operator: operator ?? this.operator,
    );
  }

  /// Factory constructor for creating a new [Expression] instance from
  /// JSON data.
  factory Expression.fromJson(Map<String, dynamic> json) =>
      _$ExpressionFromJson(json);

  @override
  List<Object?> get props => [leftPart, rightPart, operator];

  @override
  Map toJson() => _$ExpressionToJson(this)..['type'] = 'Expression';
}

/// Represents a group of expressions in a condition typically joined by
/// and/or.
/// e.g. `a == b && c == d` is a group of two expressions: `a == b` and
/// `c == d` joined by join operator `&&`.
@JsonSerializable()
class ExpressionGroup extends BaseExpression {
  /// left side of the expression
  final BaseExpression leftExpression;

  /// join operator
  final ConditionJoin join;

  /// right side of the expression
  final BaseExpression rightExpression;

  /// Creates a group of expressions
  ExpressionGroup({
    required this.leftExpression,
    required this.join,
    required this.rightExpression,
  });

  /// Duplicates the expression group with the provided expressions.
  ExpressionGroup copyWith({
    BaseExpression? leftExpression,
    ConditionJoin? join,
    BaseExpression? rightExpression,
  }) {
    return ExpressionGroup(
      leftExpression: leftExpression ?? this.leftExpression,
      join: join ?? this.join,
      rightExpression: rightExpression ?? this.rightExpression,
    );
  }

  /// Factory constructor for creating a new [ExpressionGroup] instance from
  /// JSON data.
  factory ExpressionGroup.fromJson(Map<String, dynamic> json) =>
      _$ExpressionGroupFromJson(json);

  @override
  List<Object?> get props => [leftExpression, join, rightExpression];

  @override
  Map toJson() => _$ExpressionGroupToJson(this)..['type'] = 'ExpressionGroup';
}

/// Base class for conditions
sealed class BaseCondition with EquatableMixin, SerializableMixin {
  /// id of the condition
  final String id;

  /// Creates a base condition.
  const BaseCondition({required this.id});

  /// Factory constructor for creating a new [BaseCondition] instance from
  /// JSON data.
  factory BaseCondition.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String?) {
      case 'Condition':
        return Condition.fromJson(json);
      case 'ElseCondition':
        return ElseCondition.fromJson(json);
      case 'ConditionGroup':
        return ConditionGroup.fromJson(json);
      default:
        throw UnimplementedError('Unregistered type: ${json['type']}');
    }
  }
}

/// Represents an else condition. e.g. `else { ... }`. [actions] are performed
/// when the condition is met.
@JsonSerializable()
class ElseCondition extends BaseCondition {
  /// Condition mode
  final ConditionMode mode = ConditionMode.elseMode;

  /// Actions to perform when the condition is met.
  final List<ActionModel> actions;

  /// Creates an else condition
  ElseCondition({
    required super.id,
    List<ActionModel>? actions,
  }) : actions = actions ?? [];

  /// Duplicates the else condition with the provided actions list.
  ElseCondition copyWith({
    String? id,
    List<ActionModel>? actions,
  }) {
    return ElseCondition(
      id: id ?? this.id,
      actions: actions ?? this.actions,
    );
  }

  /// Factory constructor for creating a new [ElseCondition] instance from
  /// JSON data.
  factory ElseCondition.fromJson(Map<String, dynamic> json) =>
      _$ElseConditionFromJson(json);

  @override
  List<Object?> get props => [mode, actions];

  @override
  Map toJson() => _$ElseConditionToJson(this)..['type'] = 'ElseCondition';
}

/// Represents a condition.
/// e.g. `if (a == b) { ... }`
///       `else if (b == c) { ... }`
/// [actions] are performed when the condition is met.
@JsonSerializable()
class Condition extends BaseCondition {
  /// Expression to evaluate
  final BaseExpression expression;

  /// Actions to perform when the condition is met.
  final List<ActionModel> actions;

  /// Condition mode
  final ConditionMode mode;

  /// Creates a simple condition
  const Condition({
    required super.id,
    required this.mode,
    required this.expression,
    required this.actions,
  });

  /// CopyWith
  Condition copyWith({
    String? id,
    BaseExpression? expression,
    List<ActionModel>? actions,
  }) {
    return Condition(
      id: id ?? this.id,
      mode: mode,
      expression: expression ?? this.expression,
      actions: actions ?? this.actions,
    );
  }

  /// Factory constructor for creating a new [Condition] instance from
  /// JSON data.
  factory Condition.fromJson(Map<String, dynamic> json) =>
      _$ConditionFromJson(json);

  @override
  List<Object?> get props => [mode, expression, actions];

  @override
  Map toJson() => _$ConditionToJson(this)..['type'] = 'Condition';
}

/// Represents a group of conditions. Contains an if condition, else if
/// conditions (optional) and an else condition (optional).
/// Conditions are evaluated in order.
/// e.g. `if (a == b) { ... } else if (b == c) { ... } else { ... }`
@JsonSerializable()
class ConditionGroup extends BaseCondition {
  /// if condition
  final Condition ifCondition;

  /// else if conditions
  final List<Condition> elseIfConditions;

  /// else condition
  final ElseCondition? elseCondition;

  /// name of the condition group
  final String? name;

  /// Creates a condition group
  ConditionGroup({
    required super.id,
    this.name,
    required this.ifCondition,
    List<Condition>? elseIfConditions,
    this.elseCondition,
  }) : elseIfConditions = elseIfConditions ?? [];

  /// CopyWith
  ConditionGroup copyWith({
    String? id,
    String? name,
    Condition? ifCondition,
    List<Condition>? elseIfConditions,
    ElseCondition? elseCondition,
  }) {
    return ConditionGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      ifCondition: ifCondition ?? this.ifCondition,
      elseIfConditions: elseIfConditions ?? this.elseIfConditions,
      elseCondition: elseCondition ?? this.elseCondition,
    );
  }

  /// Factory constructor for creating a new [ConditionGroup] instance from
  /// JSON data.
  factory ConditionGroup.fromJson(Map<String, dynamic> json) =>
      _$ConditionGroupFromJson(json);

  @override
  List<Object?> get props => [ifCondition, elseIfConditions, elseCondition];

  @override
  Map toJson() => _$ConditionGroupToJson(this)..['type'] = 'ConditionGroup';
}

/// Contains all the variables associated with a canvas inside a page.
@JsonSerializable()
class CanvasConditions with EquatableMixin {
  /// Unique ID of the canvas.
  final String id;

  /// Variables associated with this canvas.
  final Map<String, BaseCondition> conditions;

  /// Last updated time of this canvas.
  @JsonKey(toJson: dateToJson, fromJson: jsonToDate)
  final DateTime lastUpdated;

  /// ID of the project this canvas belongs to.
  final String owner;

  /// ID of the project this canvas belongs to.
  @JsonKey(name: 'project')
  final String projectId;

  /// Creates a new [CanvasVariables].
  CanvasConditions({
    required this.id,
    required this.conditions,
    DateTime? lastUpdated,
    required this.projectId,
    required this.owner,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Duplicate a [CanvasVariables] with the given parameters.
  CanvasConditions copyWith({
    String? id,
    Map<String, BaseCondition>? conditions,
    String? projectId,
    String? owner,
  }) =>
      CanvasConditions(
        id: id ?? this.id,
        conditions: conditions ?? this.conditions,
        lastUpdated: DateTime.now(),
        projectId: projectId ?? this.projectId,
        owner: owner ?? this.owner,
      );

  @override
  List<Object?> get props => [id, conditions];

  /// Creates a new [CanvasVariables] from a JSON map.
  factory CanvasConditions.fromJson(Map<String, dynamic> json) =>
      _$CanvasConditionsFromJson(json);

  /// Converts this [CanvasVariables] into a JSON map.
  Map<String, dynamic> toJson() => _$CanvasConditionsToJson(this)..remove('id');

  /// Allows to access canvas variables by variable id.
  BaseCondition? operator [](String conditionId) {
    return conditions[conditionId];
  }

  /// Allows to assign canvas variables by variable id.
  void operator []=(String conditionId, BaseCondition value) {
    conditions[conditionId] = value;
  }
}
