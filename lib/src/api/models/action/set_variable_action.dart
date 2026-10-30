import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../mixins.dart';
import '../condition.dart';
import '../variables_model.dart';
import 'action.dart';
import '../../json_defaults.dart';

part 'set_variable_action.g.dart';

/// An action that sets value of a variable.
@JsonSerializable()
class SetVariableAction extends ActionModel
    with Equatable, SerializableMixin
    implements DataOperationInterface {
  /// Variable whose value is to be set.
  final VariableData variable;

  @override
  final String index;

  @override
  final ListOperation listOperation;

  @override
  final String mapKey;

  @override
  final MapOperation mapOperation;

  @override
  final String newValue;

  @override
  final bool toggled;

  @override
  final NumberOperation numberOperation;

  /// Creates a new [SetValueAction].
  SetVariableAction({
    required this.variable,
    this.newValue = '',
    this.toggled = false,
    this.listOperation = ListOperation.replace,
    this.index = '0',
    this.mapOperation = MapOperation.replace,
    this.mapKey = 'key',
    this.numberOperation = NumberOperation.set,
    super.nonBlocking,
    super.enabled,
  }) : super(type: ActionType.setVariable);

  @override
  List<Object?> get props => [
    variable,
    newValue,
    toggled,
    listOperation,
    index,
    mapOperation,
    mapKey,
    numberOperation,
  ];

  /// Duplicates this [SetVariableAction] with given data overrides.
  SetVariableAction copyWith({
    VariableData? variable,
    String? newValue,
    bool? toggled,
    ListOperation? listOperation,
    String? index,
    MapOperation? mapOperation,
    String? mapKey,
    NumberOperation? numberOperation,
  }) => SetVariableAction(
    variable: variable ?? this.variable,
    newValue: newValue ?? this.newValue,
    toggled: toggled ?? this.toggled,
    listOperation: listOperation ?? this.listOperation,
    index: index ?? this.index,
    mapOperation: mapOperation ?? this.mapOperation,
    mapKey: mapKey ?? this.mapKey,
    numberOperation: numberOperation ?? this.numberOperation,
  );

  /// Creates a new [SetVariableAction] instance from a JSON data.
  ///
  /// [newValue] is text; JSON written by hand often gives `true`, `20` or a
  /// list instead, which becomes its text (lists and maps as JSON).
  factory SetVariableAction.fromJson(Map json) {
    final Object? value = json['newValue'];
    if (value == null || value is String) {
      return _$SetVariableActionFromJson(json);
    }
    return _$SetVariableActionFromJson({
      ...json,
      'newValue': value is List || value is Map ? jsonEncode(value) : '$value',
    });
  }

  @override
  Map toJson() =>
      _$SetVariableActionOmitDefaults(this, _$SetVariableActionToJson(this));

  @override
  R? accept<R>(ActionVisitor<R> visitor) =>
      visitor.visitSetVariableAction(this);
}
