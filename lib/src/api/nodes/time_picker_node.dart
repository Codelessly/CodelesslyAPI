import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'time_picker_node.g.dart';

String validateClockTime(String value) {
  if (!RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
    throw FormatException('Expected 24-hour HH:mm clock time', value);
  }
  return value;
}

@JsonSerializable()
@FlutterNode('TimePickerDialog', family: 'material', nodeType: 'timePicker')
class TimePickerNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'timePicker';

  @JsonKey(fromJson: validateClockTime, toJson: validateClockTime)
  @FlutterProp(
    'initialTime',
    type: 'string',
    group: 'State',
    control: 'text',
    required: true,
    bindable: true,
    field: 'value',
  )
  String value;

  @override
  covariant TimePickerProperties properties;

  TimePickerNode.empty()
    : value = '12:00',
      properties = TimePickerProperties(),
      super(
        id: 'timePicker',
        name: 'Time Picker',
        basicBoxLocal: NodeBox(0, 0, 320, 320),
      );

  TimePickerNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required String value,
    required this.properties,
    super.outerBoxLocal,
    super.retainedOuterBoxLocal,
    super.visible,
    super.enabled,
    super.alignment,
    super.padding,
    super.margin,
    super.rotationDegrees,
    super.reactions,
    super.horizontalFit,
    super.verticalFit,
    super.flex,
    super.aspectRatioLock,
    super.constraints,
    super.parentID,
    super.positioningMode,
    super.edgePins,
    super.variables,
    super.multipleVariables,
  }) : value = validateClockTime(value);

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'value': StringFieldAccess(
      'Time',
      '24-hour HH:mm',
      () => value,
      (v) => value = validateClockTime(v),
    ),
    'properties': ObjectFieldAccess<TimePickerProperties>(
      'Properties',
      'Time picker settings',
      () => properties,
      (v) => properties = v,
    ),
  };
  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];
  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'value', value: value),
  ];
  factory TimePickerNode.fromJson(Map json) => _$TimePickerNodeFromJson(json);
  @override
  Map toJson() =>
      _$TimePickerNodeOmitDefaults(this, _$TimePickerNodeToJson(this));
}

@JsonSerializable()
class TimePickerProperties extends CustomProperties with FieldsHolder {
  TimePickerProperties();
  @override
  FieldsMap generateFields() => {...super.generateFields()};
  @override
  List<Object?> get props => [];
  factory TimePickerProperties.fromJson(Map json) =>
      _$TimePickerPropertiesFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TimePickerPropertiesOmitDefaults(
    this,
    _$TimePickerPropertiesToJson(this),
  );
}
