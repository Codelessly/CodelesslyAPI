import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

void main() {
  test('date picker golden wire and decoder', () {
    final node = DatePickerNode(
      id: 'd',
      name: 'Date',
      basicBoxLocal: NodeBox(0, 0, 320, 320),
      value: '2024-02-29',
      properties: DatePickerProperties(
        firstDate: '2024-01-01',
        lastDate: '2024-12-31',
      ),
    );
    final wire = node.toJson();
    expect(wire['type'], 'datePicker');
    expect(wire['value'], '2024-02-29');
    expect(wire['properties'], containsPair('firstDate', '2024-01-01'));
    expect(wire['properties'], containsPair('lastDate', '2024-12-31'));
    final decoded = NodeJsonConverter.instance.fromJson(wire) as DatePickerNode;
    expect(decoded.value, '2024-02-29');
    expect(decoded.toJson(), wire);
    expect(
      DatePickerNode.empty().properties.toJson(),
      isNot(contains('firstDate')),
    );
  });

  test('clock picker golden wire and decoder', () {
    final node = TimePickerNode(
      id: 't',
      name: 'Time',
      basicBoxLocal: NodeBox(0, 0, 320, 320),
      value: '23:59',
      properties: TimePickerProperties(),
    );
    final wire = node.toJson();
    expect(wire['type'], 'timePicker');
    expect(wire['value'], '23:59');
    expect(
      (NodeJsonConverter.instance.fromJson(wire) as TimePickerNode).toJson(),
      wire,
    );
  });

  test('rejects malformed dates, invalid range and out-of-range selection', () {
    for (final value in [
      '2023-02-29',
      '2024-13-01',
      '2024-00-01',
      '2024-01-00',
      '2024-1-01',
      '2024-01-01T00:00:00Z',
      '0000-01-01',
    ]) {
      expect(
        () => validateIsoDate(value),
        throwsFormatException,
        reason: value,
      );
      expect(
        () => DatePickerNode.fromJson({
          ...DatePickerNode.empty().toJson(),
          'value': value,
        }),
        throwsFormatException,
        reason: value,
      );
    }
    expect(
      () =>
          DatePickerProperties(firstDate: '2024-02-02', lastDate: '2024-02-01'),
      throwsFormatException,
    );
    expect(
      () => DatePickerNode.fromJson({
        ...DatePickerNode.empty().toJson(),
        'properties': {'firstDate': '2001-01-01', 'lastDate': '2002-01-01'},
      }),
      throwsFormatException,
    );
    final node = DatePickerNode.empty();
    node.value = 'invalid';
    expect(() => node.toJson(), throwsFormatException);
  });

  test(
    'rejects malformed clock strings on input, decoding and serialization',
    () {
      for (final value in [
        '24:00',
        '12:60',
        '1:00',
        '12:01:00',
        '2024-01-01T12:00:00Z',
        '12:00Z',
        ' 12:00',
      ]) {
        expect(
          () => validateClockTime(value),
          throwsFormatException,
          reason: value,
        );
        expect(
          () => TimePickerNode.fromJson({
            ...TimePickerNode.empty().toJson(),
            'value': value,
          }),
          throwsFormatException,
          reason: value,
        );
      }
      final node = TimePickerNode.empty();
      node.value = '24:00';
      expect(() => node.toJson(), throwsFormatException);
    },
  );

  test('combined input round trips all modes and exposes value binding', () {
    for (final entry in {
      'date': '2024-02-29',
      'time': '23:59',
      'dateTime': '2024-02-29T23:59:00Z',
    }.entries) {
      final node = DateTimeInputNode(
        id: 'dt',
        name: 'Input',
        basicBoxLocal: NodeBox(0, 0, 320, 320),
        mode: entry.key,
        value: entry.value,
        properties: DateTimeInputProperties(
          label: 'When',
          firstDate: entry.key == 'time' ? null : '2024-01-01',
          lastDate: entry.key == 'time' ? null : '2024-12-31',
        ),
      );
      final wire = node.toJson();
      expect(wire['type'], 'dateTimeInput');
      expect(wire['mode'], entry.key);
      expect(wire['value'], entry.value);
      expect(
        (NodeJsonConverter.instance.fromJson(wire) as DateTimeInputNode)
            .toJson(),
        wire,
      );
      expect(node.propertyVariables.any((v) => v.name == 'value'), isTrue);
    }
  });

  test('combined input rejects malformed modes, values and date bounds', () {
    final wire = DateTimeInputNode.empty().toJson();
    for (final pair in [
      ('date', '2024-02-30'),
      ('time', '24:00'),
      ('dateTime', '2024-02-29T12:00:00'),
      ('dateTime', '2024-02-30T12:00:00Z'),
      ('other', '2024-01-01'),
    ]) {
      expect(
        () => DateTimeInputNode.fromJson({
          ...wire,
          'mode': pair.$1,
          'value': pair.$2,
        }),
        throwsFormatException,
      );
    }
    expect(
      () => DateTimeInputProperties(
        firstDate: '2025-01-01',
        lastDate: '2024-01-01',
      ),
      throwsFormatException,
    );
    expect(
      () => DateTimeInputNode.fromJson({
        ...wire,
        'mode': 'time',
        'value': '12:00',
        'properties': {'firstDate': '2024-01-01'},
      }),
      throwsFormatException,
    );
    expect(
      () => DateTimeInputNode.fromJson({
        ...wire,
        'mode': 'dateTime',
        'value': '2024-01-01T12:00:00Z',
        'properties': {'firstDate': '2024-01-02'},
      }),
      throwsFormatException,
    );
    final node = DateTimeInputNode.empty()..mode = 'time';
    expect(() => node.toJson(), throwsFormatException);
  });

  test('combined input min/max round trip and enforce each mode', () {
    for (final entry in [
      ('date', '2024-02-29', '2024-01-01', '2024-12-31'),
      ('time', '12:30', '12:30:00', '12:30:59'),
      (
        'dateTime',
        '2024-02-29T12:30:00+02:00',
        '2024-02-29T10:00:00Z',
        '2024-02-29T11:00:00Z',
      ),
    ]) {
      final wire = DateTimeInputNode.empty().toJson()
        ..['mode'] = entry.$1
        ..['value'] = entry.$2
        ..['properties'] = {'min': entry.$3, 'max': entry.$4};
      final node = DateTimeInputNode.fromJson(wire);
      expect(node.toJson()['properties'], {'min': entry.$3, 'max': entry.$4});
      expect(
        node.properties.generateFields().keys,
        containsAll(['min', 'max']),
      );
      expect(
        node.propertyVariables.map((v) => v.name),
        containsAll(['min', 'max']),
      );
      for (final bad in [
        {'min': entry.$4, 'max': entry.$3},
        {'min': entry.$4},
        {
          'max': entry.$1 == 'date'
              ? '2024-01-01'
              : entry.$1 == 'time'
              ? '00:00'
              : '2024-02-29T09:59:59Z',
        },
        {'min': 'invalid'},
      ]) {
        expect(
          () => DateTimeInputNode.fromJson({...wire, 'properties': bad}),
          throwsFormatException,
        );
      }
    }
    final catalog = jsonDecode(
      File('lib/src/api/nodes/date_time_input_node.flutter_catalog.json')
          .readAsStringSync(),
    ) as Map;
    expect(catalog.toString(), contains('properties.min'));
    expect(catalog.toString(), contains('properties.max'));
    final basic = jsonDecode(
      File('lib/src/schema/generated/codelessly_a2ui_catalog.json')
          .readAsStringSync(),
    ) as Map;
    final component = (basic['components'] as Map)['DateTimeInput'] as Map;
    expect(component.toString(), contains('DynamicString'));
    expect(component.toString(), contains('min'));
    expect(component.toString(), contains('max'));
  });

  test('combined BASIC DateTimeInput maps to the distinct ready bridge', () {
    final mappings = jsonDecode(
      File('lib/src/schema/generated/basic_node_mappings.json')
          .readAsStringSync(),
    ) as Map;
    expect((mappings['mappings'] as Map)['DateTimeInput'], {
      'nodeType': 'dateTimeInput',
      'bridgeStatus': 'ready',
    });
  });
}
