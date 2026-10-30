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

  test(
    'combined BASIC DateTimeInput stays deferred without a faithful bridge',
    () {
      final mappings = jsonDecode(
        File('lib/src/schema/generated/basic_node_mappings.json')
            .readAsStringSync(),
      ) as Map;
      expect((mappings['mappings'] as Map)['DateTimeInput'], {
        'nodeType': null,
        'bridgeStatus': 'deferred',
      });
    },
  );
}
