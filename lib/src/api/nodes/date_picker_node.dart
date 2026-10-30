import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'nodes.dart';

part 'date_picker_node.g.dart';

String validateIsoDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) throw FormatException('Expected ISO calendar date', value);
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  if (year < 1 ||
      month < 1 ||
      month > 12 ||
      day < 1 ||
      day > DateTime.utc(year, month + 1, 0).day) {
    throw FormatException('Invalid calendar date', value);
  }
  return value;
}

String? validateOptionalIsoDate(String? value) =>
    value == null ? null : validateIsoDate(value);

@JsonSerializable()
@FlutterNode('CalendarDatePicker', family: 'material', nodeType: 'datePicker')
class DatePickerNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'datePicker';

  @JsonKey(fromJson: validateIsoDate, toJson: validateIsoDate)
  @FlutterProp(
    'initialDate',
    type: 'string',
    group: 'State',
    control: 'text',
    required: true,
    bindable: true,
    field: 'value',
  )
  String value;

  @override
  covariant DatePickerProperties properties;

  DatePickerNode.empty()
    : value = '2000-01-01',
      properties = DatePickerProperties(),
      super(
        id: 'datePicker',
        name: 'Date Picker',
        basicBoxLocal: NodeBox(0, 0, 320, 320),
      );

  DatePickerNode({
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
  }) : value = validateIsoDate(value) {
    properties.validate(value);
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'value': StringFieldAccess('Date', 'ISO calendar date', () => value, (v) {
      properties.validate(v);
      value = validateIsoDate(v);
    }),
    'properties': ObjectFieldAccess<DatePickerProperties>(
      'Properties',
      'Date limits',
      () => properties,
      (v) {
        v.validate(value);
        properties = v;
      },
    ),
  };

  @override
  List<TriggerType> get triggerTypes => [TriggerType.changed];

  @override
  late final List<ValueModel> propertyVariables = [
    ...super.propertyVariables,
    StringValue(name: 'value', value: value),
  ];

  factory DatePickerNode.fromJson(Map json) {
    final node = _$DatePickerNodeFromJson(json);
    node.properties.validate(node.value);
    return node;
  }
  @override
  Map toJson() {
    properties.validate(value);
    return _$DatePickerNodeOmitDefaults(this, _$DatePickerNodeToJson(this));
  }
}

@JsonSerializable()
class DatePickerProperties extends CustomProperties with FieldsHolder {
  @JsonKey(fromJson: validateOptionalIsoDate, toJson: validateOptionalIsoDate)
  @FlutterProp(
    'firstDate',
    type: 'string',
    group: 'Bounds',
    control: 'text',
    field: 'properties.firstDate',
  )
  String? firstDate;
  @JsonKey(fromJson: validateOptionalIsoDate, toJson: validateOptionalIsoDate)
  @FlutterProp(
    'lastDate',
    type: 'string',
    group: 'Bounds',
    control: 'text',
    field: 'properties.lastDate',
  )
  String? lastDate;

  DatePickerProperties({String? firstDate, String? lastDate})
    : firstDate = validateOptionalIsoDate(firstDate),
      lastDate = validateOptionalIsoDate(lastDate) {
    validate();
  }

  void validate([String? value]) {
    final first = validateOptionalIsoDate(firstDate);
    final last = validateOptionalIsoDate(lastDate);
    if (first != null && last != null && first.compareTo(last) > 0 ||
        value != null &&
            ((first != null && validateIsoDate(value).compareTo(first) < 0) ||
                (last != null && validateIsoDate(value).compareTo(last) > 0))) {
      throw FormatException('Date outside firstDate/lastDate bounds', value);
    }
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'firstDate': StringFieldAccess(
      'First Date',
      'Inclusive ISO lower bound',
      () => firstDate ?? '',
      (v) {
        final old = firstDate;
        firstDate = v.isEmpty ? null : v;
        try {
          validate();
        } catch (_) {
          firstDate = old;
          rethrow;
        }
      },
    ),
    'lastDate': StringFieldAccess(
      'Last Date',
      'Inclusive ISO upper bound',
      () => lastDate ?? '',
      (v) {
        final old = lastDate;
        lastDate = v.isEmpty ? null : v;
        try {
          validate();
        } catch (_) {
          lastDate = old;
          rethrow;
        }
      },
    ),
  };
  @override
  List<Object?> get props => [firstDate, lastDate];
  factory DatePickerProperties.fromJson(Map json) {
    final p = _$DatePickerPropertiesFromJson(json);
    p.validate();
    return p;
  }
  @override
  Map<String, dynamic> toJson() {
    validate();
    return _$DatePickerPropertiesOmitDefaults(
      this,
      _$DatePickerPropertiesToJson(this),
    );
  }
}
