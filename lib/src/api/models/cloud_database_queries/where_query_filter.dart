import 'package:codelessly_json_annotation/codelessly_json_annotation.dart';
import 'package:equatable/equatable.dart';

import 'query_filter.dart';

part 'where_query_filter.g.dart';

/// Enum representing the Firestore where operation.
///
/// Reference: https://firebase.google.com/docs/firestore/query-data/queries?hl=en
///
/// Cloud Firestore supports the following comparison operators:
/// < less than
/// <= less than or equal to
/// == equal to
/// > greater than
/// >= greater than or equal to
/// != not equal to
/// array-contains
/// array-contains-any
/// in
/// not-in
enum WhereQueryOperator {
  /// Compares two values and returns true if they are equal.
  equal('Equal To', '=='),

  /// Checks if two values are not equal.
  notEqual('Not Equal To', '!='),

  /// Compares two values and returns true if the first is less than the second.
  lessThan('Less Than', '<'),

  /// Compares two values and returns true if the first is less than or equal
  /// to the second.
  lessThanOrEqual('Less Than Or Equal To', '<='),

  /// Compares two values and returns true if the first is greater than the
  /// second.
  greaterThan('Greater Than', '>'),

  /// Compares two values and returns true if the first is greater than or equal
  /// to the second.
  greaterThanOrEqual('Greater Than Or Equal To', '>='),

  /// Checks if an array contains a value.
  arrayContains('Contains', 'array-contains'),

  /// Checks if an array contains any of the values in a given array.
  arrayContainsAny('Contains any', 'array-contains-any'),

  /// Checks if a value is in a given array.
  inArray('Is in', 'in'),

  /// Checks if a value is not in a given array.
  notInArray('Is not in', 'not-in');

  /// The human-readable name of the operation.
  final String label;

  /// The operator to use in the query.
  final String operator;

  const WhereQueryOperator(this.label, this.operator);

  /// Returns true if this operation is a range operation.
  bool get isRangeOperator =>
      this == WhereQueryOperator.greaterThan ||
      this == WhereQueryOperator.greaterThanOrEqual ||
      this == WhereQueryOperator.lessThan ||
      this == WhereQueryOperator.lessThanOrEqual;

  /// Returns true if this operation is an inequality operation.
  bool get isInequalityOperator =>
      isRangeOperator ||
      this == WhereQueryOperator.notEqual ||
      this == WhereQueryOperator.notInArray;

  /// Returns true if this operation is an equality operation.
  bool get isEqualityOperator =>
      this == WhereQueryOperator.equal ||
      this == WhereQueryOperator.arrayContains ||
      this == WhereQueryOperator.arrayContainsAny ||
      this == WhereQueryOperator.inArray;

  /// Returns a set of all range operators.
  static Set<WhereQueryOperator> get rangeOperators => {
        WhereQueryOperator.greaterThan,
        WhereQueryOperator.greaterThanOrEqual,
        WhereQueryOperator.lessThan,
        WhereQueryOperator.lessThanOrEqual,
      };

  /// Returns a set of all inequality operators.
  static Set<WhereQueryOperator> get inequalityOperators => {
        ...rangeOperators,
        WhereQueryOperator.notEqual,
        WhereQueryOperator.notInArray,
      };

  /// Returns a set of all equality operators.
  static Set<WhereQueryOperator> get equalityOperators => {
        WhereQueryOperator.equal,
        WhereQueryOperator.arrayContains,
        WhereQueryOperator.arrayContainsAny,
        WhereQueryOperator.inArray,
      };

  /// Returns true if the given [operators] iterable contains any equality
  /// operator.
  static bool hasEqualityOperator(Iterable<WhereQueryOperator> operators) {
    return operators.any((operator) => operator.isEqualityOperator);
  }

  /// Returns true if the given [operators] iterable contains any inequality
  /// operator.
  static bool hasInequalityOperator(Iterable<WhereQueryOperator> operators) {
    return operators.any((operator) => operator.isInequalityOperator);
  }
}

/// Represents the where operation in Codelessly Cloud Database.
///
/// Takes three parameters: a field to filter on, a comparison operator, and a value.
///
/// Reference: https://firebase.google.com/docs/firestore/query-data/queries?hl=en
///
/// TODO: Add support for OR queries.
@JsonSerializable()
class WhereQueryFilter extends QueryFilter with EquatableMixin {
  /// The where operation to perform.
  final WhereQueryOperator operator;

  /// The value to compare against.
  final String value;

  /// Creates a new [WhereQueryFilter] instance, given a [field], an [operator],
  /// and a [value].
  const WhereQueryFilter({
    required super.field,
    required this.operator,
    required this.value,
  });

  /// Creates a copy of this [WhereQueryFilter] instance, given a [field], an
  /// [operator], and a [value].
  WhereQueryFilter copyWith({
    String? field,
    WhereQueryOperator? operator,
    String? value,
  }) =>
      WhereQueryFilter(
        field: field ?? this.field,
        operator: operator ?? this.operator,
        value: value ?? this.value,
      );

  /// Converts a JSON object to a [WhereQueryFilter] instance.
  factory WhereQueryFilter.fromJson(Map<String, dynamic> json) =>
      _$WhereQueryFilterFromJson(json);

  /// Converts this [WhereQueryFilter] instance to a JSON object.
  Map<String, dynamic> toJson() => _$WhereQueryFilterToJson(this);

  @override
  List<Object?> get props => [field, operator, value];
}
