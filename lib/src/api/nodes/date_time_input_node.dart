import 'package:json_annotation/json_annotation.dart';

import '../../schema/flutter_prop.dart';
import '../field_access.dart';
import '../mixins.dart';
import '../models/models.dart';
import 'date_picker_node.dart';
import 'nodes.dart';

part 'date_time_input_node.g.dart';

String validateDateTimeMode(String value) {
  if (!const {'date', 'time', 'dateTime'}.contains(value)) {
    throw FormatException('Expected date, time or dateTime mode', value);
  }
  return value;
}

String validateIsoDateTime(String value) {
  final match = RegExp(
    r'^(\d{4}-\d{2}-\d{2})T([01]\d|2[0-3]):[0-5]\d:[0-5]\d(?:\.\d+)?(?:Z|[+-](?:[01]\d|2[0-3]):[0-5]\d)$',
  ).firstMatch(value);
  if (match == null)
    throw FormatException('Expected ISO datetime with timezone', value);
  validateIsoDate(match[1]!);
  if (DateTime.tryParse(value) == null) {
    throw FormatException('Invalid ISO datetime', value);
  }
  return value;
}

String validateDateTimeBound(String mode, String value) {
  if (mode == 'time') {
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$').hasMatch(value)) {
      throw FormatException('Expected HH:mm or HH:mm:ss', value);
    }
    return value;
  }
  return validateDateTimeInputValue(mode, value);
}

int compareDateTimeBounds(String mode, String a, String b) {
  if (mode == 'dateTime') {
    return DateTime.parse(a).toUtc().compareTo(DateTime.parse(b).toUtc());
  }
  if (mode == 'time') {
    int seconds(String value) {
      final parts = value.split(':').map(int.parse).toList();
      return parts[0] * 3600 +
          parts[1] * 60 +
          (parts.length == 3 ? parts[2] : 0);
    }

    return seconds(a).compareTo(seconds(b));
  }
  return a.compareTo(b);
}

String validateDateTimeInputValue(String mode, String value) {
  switch (validateDateTimeMode(mode)) {
    case 'date':
      return validateIsoDate(value);
    case 'time':
      return validateDateTimeBound('time', value);
    case 'dateTime':
      return validateIsoDateTime(value);
  }
  throw FormatException('Invalid mode', mode);
}

@JsonSerializable()
@FlutterNode('DateTimeInput', family: 'codelessly', nodeType: 'dateTimeInput')
class DateTimeInputNode extends SceneNode
    with CustomPropertiesMixin, FieldsHolder {
  @override
  final String type = 'dateTimeInput';

  @FlutterProp(
    'mode',
    type: 'string',
    group: 'State',
    control: 'text',
    required: true,
    field: 'mode',
  )
  String mode;

  @FlutterProp(
    'value',
    type: 'string',
    group: 'State',
    control: 'text',
    required: true,
    bindable: true,
    field: 'value',
  )
  String value;

  @override
  covariant DateTimeInputProperties properties;

  DateTimeInputNode.empty()
    : mode = 'date',
      value = '2000-01-01',
      properties = DateTimeInputProperties(),
      super(
        id: 'dateTimeInput',
        name: 'Date Time Input',
        basicBoxLocal: NodeBox(0, 0, 320, 320),
      );

  DateTimeInputNode({
    required super.id,
    required super.name,
    required super.basicBoxLocal,
    required String mode,
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
  }) : mode = validateDateTimeMode(mode),
       value = validateDateTimeInputValue(mode, value) {
    properties.validate(mode, value);
  }

  void validate() {
    validateDateTimeInputValue(mode, value);
    properties.validate(mode, value);
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'mode': StringFieldAccess('Mode', 'date, time or dateTime', () => mode, (
      v,
    ) {
      validateDateTimeInputValue(v, value);
      properties.validate(v, value);
      mode = v;
    }),
    'value': StringFieldAccess(
      'Value',
      'Mode-dependent date or time',
      () => value,
      (v) {
        validateDateTimeInputValue(mode, v);
        properties.validate(mode, v);
        value = v;
      },
    ),
    'properties': ObjectFieldAccess<DateTimeInputProperties>(
      'Properties',
      'Label and date bounds',
      () => properties,
      (v) {
        v.validate(mode, value);
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
    if (properties.min != null)
      StringValue(name: 'min', value: properties.min!),
    if (properties.max != null)
      StringValue(name: 'max', value: properties.max!),
  ];

  factory DateTimeInputNode.fromJson(Map json) {
    final node = _$DateTimeInputNodeFromJson(json);
    node.validate();
    return node;
  }

  @override
  Map toJson() {
    validate();
    return _$DateTimeInputNodeOmitDefaults(
      this,
      _$DateTimeInputNodeToJson(this),
    );
  }
}

@JsonSerializable()
class DateTimeInputProperties extends CustomProperties with FieldsHolder {
  @FlutterProp(
    'label',
    type: 'string',
    group: 'Content',
    control: 'text',
    field: 'properties.label',
  )
  String? label;
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

  @FlutterProp(
    'min',
    type: 'string',
    group: 'Bounds',
    control: 'text',
    bindable: true,
    field: 'properties.min',
  )
  String? min;

  @FlutterProp(
    'max',
    type: 'string',
    group: 'Bounds',
    control: 'text',
    bindable: true,
    field: 'properties.max',
  )
  String? max;

  DateTimeInputProperties({
    this.label,
    String? firstDate,
    String? lastDate,
    this.min,
    this.max,
  }) : firstDate = validateOptionalIsoDate(firstDate),
       lastDate = validateOptionalIsoDate(lastDate) {
    validate();
  }

  void validate([String? mode, String? value]) {
    final first = validateOptionalIsoDate(firstDate);
    final last = validateOptionalIsoDate(lastDate);
    if (first != null && last != null && first.compareTo(last) > 0) {
      throw FormatException('Invalid firstDate/lastDate range');
    }
    if (mode != null) {
      final lower = min == null ? null : validateDateTimeBound(mode, min!);
      final upper = max == null ? null : validateDateTimeBound(mode, max!);
      if (lower != null &&
          upper != null &&
          compareDateTimeBounds(mode, lower, upper) > 0) {
        throw FormatException('Invalid min/max range');
      }
      if (value != null) {
        validateDateTimeInputValue(mode, value);
        if ((lower != null && compareDateTimeBounds(mode, value, lower) < 0) ||
            (upper != null && compareDateTimeBounds(mode, value, upper) > 0)) {
          throw FormatException('Value outside min/max bounds', value);
        }
      }
    }
    if (mode == 'time' && (first != null || last != null)) {
      throw FormatException('Date bounds do not apply to time mode');
    }
    if (mode != null && value != null) {
      validateDateTimeInputValue(mode, value);
      if (mode != 'time') {
        final date = value.substring(0, 10);
        if ((first != null && date.compareTo(first) < 0) ||
            (last != null && date.compareTo(last) > 0)) {
          throw FormatException(
            'Date outside firstDate/lastDate bounds',
            value,
          );
        }
      }
    }
  }

  @override
  FieldsMap generateFields() => {
    ...super.generateFields(),
    'label': StringFieldAccess(
      'Label',
      'Input label',
      () => label ?? '',
      (v) => label = v.isEmpty ? null : v,
    ),
    'min': StringFieldAccess(
      'Min',
      'Inclusive mode-dependent lower bound',
      () => min ?? '',
      (v) {
        final old = min;
        min = v.isEmpty ? null : v;
        try {
          validate();
        } catch (_) {
          min = old;
          rethrow;
        }
      },
    ),
    'max': StringFieldAccess(
      'Max',
      'Inclusive mode-dependent upper bound',
      () => max ?? '',
      (v) {
        final old = max;
        max = v.isEmpty ? null : v;
        try {
          validate();
        } catch (_) {
          max = old;
          rethrow;
        }
      },
    ),
    'firstDate': StringFieldAccess(
      'First Date',
      'Inclusive ISO date lower bound',
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
      'Inclusive ISO date upper bound',
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
  List<Object?> get props => [label, firstDate, lastDate, min, max];

  factory DateTimeInputProperties.fromJson(Map json) {
    final properties = _$DateTimeInputPropertiesFromJson(json);
    properties.validate();
    return properties;
  }

  @override
  Map<String, dynamic> toJson() {
    validate();
    return _$DateTimeInputPropertiesOmitDefaults(
      this,
      _$DateTimeInputPropertiesToJson(this),
    );
  }
}
