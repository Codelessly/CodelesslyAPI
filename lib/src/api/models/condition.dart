import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../converters.dart';
import '../mixins.dart';
import 'models.dart';

part 'condition.g.dart';

/// condition operation for basic conditions
enum ConditionOperation {
  /// Checks if the value of the variable is equal to the value provided.
  equalsTo,

  /// Checks if the value of the variable is not equal to the value provided.
  notEqualsTo,

  /// Checks if the value of the variable is greater than the value provided.
  greaterThan,

  /// Checks if the value of the variable is less than the value provided.
  lessThan,

  /// Checks if the value of the variable is greater than or equal to the
  /// value provided.
  greaterThanOrEqualTo,

  /// Checks if the value of the variable is less than or equal to the
  /// value provided.
  lessThanOrEqualTo,

  /// Checks if the value of the variable is empty. This is applicable only
  /// for strings and collections.
  isEmpty,

  /// Checks if the value of the variable is not empty. This is applicable only
  /// for strings and collections.
  isNotEmpty,

  /// Checks if the value of the variable contains a given item. This is
  /// applicable only for collections.
  contains,

  /// Checks if the value of the variable is odd. This is applicable only
  /// for integers.
  isOdd,

  /// Checks if the value of the variable is even. This is applicable only
  /// for integers.
  isEven,

  /// Checks if the value of the variable is null.
  isNull;

  /// label for the operation
  String get label => switch (this) {
        equalsTo => 'Equals To',
        notEqualsTo => 'Not Equal To',
        greaterThan => 'Greater Than',
        lessThan => 'Less Than',
        greaterThanOrEqualTo => 'Greater Than Or Equal To',
        lessThanOrEqualTo => 'Less Than Or Equal To',
        isEmpty => 'Is Empty',
        isNotEmpty => 'Is Not Empty',
        contains => 'Contains',
        isOdd => 'Is Odd',
        isEven => 'Is Even',
        isNull => 'Is Null',
      };

  /// short description of the operation
  String get sentence => switch (this) {
        equalsTo => 'equal to',
        notEqualsTo => 'not equal to',
        greaterThan => 'greater than',
        lessThan => 'less than',
        greaterThanOrEqualTo => 'greater than or equal to',
        lessThanOrEqualTo => 'less than or equal to',
        isEmpty => 'is empty',
        isNotEmpty => 'is not empty',
        contains => 'contains',
        isOdd => 'is odd',
        isEven => 'is even',
        isNull => 'is null',
      };

  /// short description of the operation
  String? get sign => switch (this) {
        equalsTo => '==',
        notEqualsTo => '!=',
        greaterThan => '>',
        lessThan => '<',
        greaterThanOrEqualTo => '>=',
        lessThanOrEqualTo => '<=',
        isEmpty => null,
        isNotEmpty => null,
        contains => null,
        isOdd => null,
        isEven => null,
        isNull => null,
      };

  /// Allows the provided [visitor] to visit this operation.
  bool accept(Object? left, Object? right, ConditionOperatorVisitor visitor) =>
      switch (this) {
        equalsTo => visitor.visitEqualsOperator(left, right),
        notEqualsTo => visitor.visitNotEqualsOperator(left, right),
        greaterThan => visitor.visitGreaterThanOperator(left, right),
        lessThan => visitor.visitLessThanOperator(left, right),
        greaterThanOrEqualTo =>
          visitor.visitGreaterThanOrEqualToOperator(left, right),
        lessThanOrEqualTo =>
          visitor.visitLessThanOrEqualToOperator(left, right),
        isEmpty => visitor.visitIsEmptyOperator(left),
        isNotEmpty => visitor.visitIsNotEmptyOperator(left),
        contains => visitor.visitContainsOperator(left, right),
        isOdd => visitor.visitIsOddOperator(left),
        isEven => visitor.visitIsEvenOperator(left),
        isNull => visitor.visitIsNullOperator(left),
      };

  /// Returns true if the operation requires a right operand.
  bool get requiresRightOperand => switch (this) {
        equalsTo => true,
        notEqualsTo => true,
        greaterThan => true,
        lessThan => true,
        greaterThanOrEqualTo => true,
        lessThanOrEqualTo => true,
        isEmpty => false,
        isNotEmpty => false,
        contains => true,
        isOdd => false,
        isEven => false,
        isNull => false,
      };
}

/// join operator for complex conditions
enum ConditionJoin {
  /// and operator
  and,

  /// or operator
  or;

  /// Represents the logical sign for this enum.
  String get sign {
    switch (this) {
      case ConditionJoin.and:
        return '&&';
      case ConditionJoin.or:
        return '||';
    }
  }
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

  /// Allows the provided [visitor] to visit this expression.
  R? accept<R>(ExpressionVisitor<R> visitor);
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

  /// Allows the provided [visitor] to visit this expression part.
  R? accept<R>(ExpressionPartVisitor<R> visitor);
}

/// Represents a raw value in an expression. e.g. `a == 1` has a raw value of
/// `1`.
@JsonSerializable()
class RawValuePart extends ExpressionPart {
  /// value of the raw value.
  final String value;

  /// Creates a raw value part.
  RawValuePart(this.value);

  /// Duplicates the raw value part with the provided values.
  factory RawValuePart.fromJson(Map<String, dynamic> json) =>
      _$RawValuePartFromJson(json);

  @override
  List<Object?> get props => [value];

  @override
  Map toJson() => _$RawValuePartToJson(this)..['type'] = 'RawValue';

  @override
  R? accept<R>(ExpressionPartVisitor<R> visitor) =>
      visitor.visitRawValuePart(this);
}

/// Represents a variable in an expression. e.g. `a == b` has two variables:
/// `a` and `b`.
@JsonSerializable()
class VariablePart extends ExpressionPart {
  @JsonKey(defaultValue: '')

  /// the actual string interpolated with variables.
  final String valueString;

  /// Creates a variable part.
  VariablePart({
    required this.valueString,
  });

  /// Factory constructor for creating a new [VariablePart] instance from
  /// JSON data.
  factory VariablePart.fromJson(Map<String, dynamic> json) =>
      _$VariablePartFromJson(json);

  /// Duplicates the variable part with the provided values.
  VariablePart copyWith({
    String? valueString,
  }) {
    return VariablePart(
      valueString: valueString ?? this.valueString,
    );
  }

  @override
  List<Object?> get props => [valueString];

  @override
  Map toJson() => _$VariablePartToJson(this)..['type'] = 'Variable';

  @override
  R? accept<R>(ExpressionPartVisitor<R> visitor) =>
      visitor.visitVariablePart(this);
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

  @override
  R? accept<R>(ExpressionVisitor<R> visitor) => visitor.visitExpression(this);
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

  @override
  R? accept<R>(ExpressionVisitor<R> visitor) =>
      visitor.visitExpressionGroup(this);
}

/// Base class for conditions
sealed class BaseCondition with EquatableMixin, SerializableMixin {
  /// id of the condition
  final String id;

  /// last updated timestamp
  @DateTimeConverter()
  final DateTime lastUpdated;

  /// Creates a base condition.
  BaseCondition({
    required this.id,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

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

  /// Allows the provided [visitor] to visit this condition.
  R? accept<R>(ConditionVisitor<R> visitor);

  /// Creates a copy of the condition with the provided values.
  BaseCondition copyWith({String? id});
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
    super.lastUpdated,
  }) : actions = actions ?? [];

  /// Duplicates the else condition with the provided actions list.
  @override
  ElseCondition copyWith({
    String? id,
    List<ActionModel>? actions,
  }) {
    return ElseCondition(
      id: id ?? this.id,
      actions: actions ?? this.actions,
      lastUpdated: DateTime.now(),
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

  @override
  R? accept<R>(ConditionVisitor<R> visitor) => visitor.visitElseCondition(this);
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
  Condition({
    required super.id,
    required this.mode,
    required this.expression,
    required this.actions,
    super.lastUpdated,
  });

  /// Creates a new [Condition] instance with provided properties overridden.
  @override
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
      lastUpdated: DateTime.now(),
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

  @override
  R? accept<R>(ConditionVisitor<R> visitor) => visitor.visitCondition(this);
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
    super.lastUpdated,
  }) : elseIfConditions = elseIfConditions ?? [];

  /// Creates a new [ConditionGroup] with the provided parameters overridden.
  @override
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
      lastUpdated: DateTime.now(),
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

  @override
  R? accept<R>(ConditionVisitor<R> visitor) =>
      visitor.visitConditionGroup(this);
}

/// Contains all the variables associated with a canvas inside a page.
@JsonSerializable()
class CanvasConditions with EquatableMixin {
  /// Unique ID of the canvas.
  final String id;

  /// Variables associated with this canvas.
  final Map<String, BaseCondition> conditions;

  /// Last updated time of this canvas.
  @DateTimeConverter()
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

/// A visitor that can be used to visit a [ConditionOperation].
abstract interface class ConditionOperatorVisitor {
  /// Visits a [ConditionOperation.equalsTo] operator.
  bool visitEqualsOperator(Object? left, Object? right);

  /// Visits a [ConditionOperation.notEqualsTo] operator.
  bool visitNotEqualsOperator(Object? left, Object? right);

  /// Visits a [ConditionOperation.greaterThan] operator.
  bool visitGreaterThanOperator(Object? left, Object? right);

  /// Visits a [ConditionOperation.lessThan] operator.
  bool visitLessThanOperator(Object? left, Object? right);

  /// Visits a [ConditionOperation.greaterThanOrEqualTo] operator.
  bool visitGreaterThanOrEqualToOperator(Object? left, Object? right);

  /// Visits a [ConditionOperation.lessThanOrEqualTo] operator.
  bool visitLessThanOrEqualToOperator(Object? left, Object? right);

  /// Visits a [ConditionOperation.isEmpty] operator.
  bool visitIsEmptyOperator(Object? value);

  /// Visits a [ConditionOperation.isNotEmpty] operator.
  bool visitIsNotEmptyOperator(Object? value);

  /// Visits a [ConditionOperation.isNotEmpty] operator.
  bool visitContainsOperator(Object? left, Object? right);

  /// Visits a [ConditionOperation.isNotEmpty] operator.
  bool visitIsOddOperator(Object? value);

  /// Visits a [ConditionOperation.isNotEmpty] operator.
  bool visitIsEvenOperator(Object? value);

  /// Visits a [ConditionOperation.isNull] operator.
  bool visitIsNullOperator(Object? value);
}

/// An interface for evaluating conditions.
abstract interface class ConditionVisitor<R> {
  /// Evaluates the condition and returns the result.
  R? visitCondition(Condition condition);

  /// Evaluates the condition group and returns the result.
  R? visitConditionGroup(ConditionGroup condition);

  /// Evaluates the else condition and returns the result.
  R? visitElseCondition(ElseCondition condition);
}

/// An interface for evaluating actions and retrieving the result.
abstract interface class ActionVisitor<R> {
  /// Evaluates the action and returns the result.
  R? visitSetValueAction(SetValueAction action);

  /// Evaluates the action and returns the result.
  R? visitSetVariableAction(SetVariableAction action);

  /// Evaluates the action and returns the result.
  R? visitApiCall(ApiCallAction action);

  /// Evaluates the action and returns the result.
  R? visitNavigationAction(NavigationAction action);

  /// Evaluates the action and returns the result.
  R? visitSetVariantAction(SetVariantAction action);

  /// Evaluates the action and returns the result.
  R? visitSubmitAction(SubmitAction action);

  /// Evaluates the action and returns the result.
  R? visitLinkAction(LinkAction action);

  /// Evaluates the action and returns the result.
  R? visitCallFunctionAction(CallFunctionAction action);
}

/// An interface for evaluating expressions.
abstract interface class ExpressionVisitor<R> {
  /// Evaluates the expression and returns the result.
  R? visitExpression(Expression expression);

  /// Evaluates the expression group and returns the result.
  R? visitExpressionGroup(ExpressionGroup expression);
}

/// An interface for evaluating expression parts.
abstract interface class ExpressionPartVisitor<R> {
  /// Evaluates the raw value expression part and returns the result.
  R? visitRawValuePart(RawValuePart part);

  /// Evaluates the variable value expression part and returns the value of the
  /// variable.
  R? visitVariablePart(VariablePart part);
}
