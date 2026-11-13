// Every action type's declared fields (action_fields.dart) match the JSON
// the action really reads and writes: a non-default sample for each field,
// written into the action's JSON, decodes and encodes back under the same
// key; and every key an action can write is declared.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

const _common = {'type', 'enabled', 'nonBlocking', 'when'};

/// A nested action chain.
const _chain = [
  {'type': 'delay', 'ms': 7},
];

/// Raw JSON samples for `Codecs.any` fields, by key; each one the action's
/// decoder keeps.
Object? _anySample(String type, String key) => switch (key) {
      'params' || 'baseParams' || 'result' => {'a': 'x'},
      'values' => [
          {'path': 'a', 'value': 1},
        ],
      'onSuccess' || 'onError' || 'then' || 'else' || 'actions' || 'cancelActions' => _chain,
      'steps' => [
          {'type': 'cloudData', 'operation': 'create', 'collection': 'c'},
        ],
      'whereFilters' => [
          {'field': 'a', 'operator': 'equal', 'value': '1'},
        ],
      'orderByFilters' => [
          {'field': 'a', 'sortOrder': 'descending'},
        ],
      'fields' => [
          {'field': 'a', 'value': '1'},
        ],
      'query' => {'collectionPath': 'c'},
      'condition' => {'left': 'a', 'op': 'equalsTo', 'right': 'b'},
      'icon' => {'codepoint': 1},
      'look' => {'a': 1},
      'variables' || 'arguments' || 'validationArguments' || 'props' => {'a': 'x'},
      _ => throw StateError('No Codecs.any sample for $type.$key'),
    };

/// A non-default JSON value for [def].
Object? _sample(String type, PropDef<Object?> def) {
  final codec = def.codec;
  if (identical(codec, Codecs.any)) return _anySample(type, def.key);
  if (identical(codec, Codecs.optionalColor) || identical(codec, Codecs.color)) return '#FF112233';
  if (identical(codec, Codecs.doubles)) return [for (final _ in def.defaultValue! as List) 0.5];
  if (identical(codec, Codecs.strings)) return ['x'];
  if (identical(codec, routeTransitionCodec)) {
    return {
      'preset': 'iosPush',
      'enter': {
        'motion': {'shiftX': 1},
        'curve': 'easeOutCubic',
      },
      'durationMs': 500,
    };
  }
  if (def.type.name == 'Spring') return {'duration': 400, 'bounce': 0.2};
  if (codec is AnimationCurveCodec) return def.defaultValue == AnimationCurve.linear ? 'easeOut' : 'linear';
  if (codec is OptionalEnumCodec) return codec.values.last.name;
  if (codec is EnumCodec) {
    // A write op that keeps its value.
    if (def.key == 'op') return 'add';
    final values = codec.values;
    // A single-value enum (submitForm's offered service) can only be its default.
    return (values.length == 1 ? values.first : values.firstWhere((v) => v != def.defaultValue)).name;
  }
  if (codec is StringCodec || codec is OptionalStringCodec) return 'x';
  if (codec is IntCodec || codec is OptionalIntCodec) return 7;
  if (codec is DoubleCodec || codec is OptionalDoubleCodec) return 0.5;
  if (codec is BoolCodec) return !(def.defaultValue! as bool);
  if (codec is OptionalBoolCodec) return true;
  throw StateError('No sample for $type.${def.key} (${codec.runtimeType})');
}

/// Fields that only show under some other value (an operation): each
/// variant overrides the full sample, and together they show every field.
const Map<String, List<Json>> _variants = {
  // valueType, value... only for write; key not for clear.
  'setStorage': [
    {'operation': 'write'},
    {'operation': 'remove'},
  ],
  // field, valueType, the write only for update; skipIfExists only for add.
  'cloudDocuments': [
    {'operation': 'update'},
    {'operation': 'add'},
  ],
};

Json _full(ActionSpec spec) => {for (final d in spec.fields) d.key: _sample(spec.type, d)};

List<Json> _samples(ActionSpec spec) => [
      for (final v in _variants[spec.type] ?? const [<String, Object?>{}]) {..._full(spec), ...v},
    ];

Json _roundTrip(String type, Json sample) {
  final a = ActionDef.fromJson({'type': type, ...sample});
  expect(a, isNotNull);
  expect(a, isNot(isA<UnknownAction>()));
  return a!.toJson();
}

void main() {
  test('every action type is declared', () {
    final types = ActionDef.types.toList();
    expect(types, isNotEmpty);
    for (final type in types) {
      expect(ActionSpecs.of(type), isNotNull, reason: type);
    }
    expect(ActionSpecs.all.map((s) => s.type).toSet(), types.toSet());
  });

  test('declared keys are unique and not common fields', () {
    for (final spec in ActionSpecs.all) {
      final keys = [for (final d in spec.fields) d.key];
      expect(keys.toSet().length, keys.length, reason: spec.type);
      expect(keys.toSet().intersection(_common), isEmpty, reason: spec.type);
      expect(spec.label, isNotEmpty);
    }
  });

  for (final spec in ActionSpecs.all) {
    group(spec.type, () {
      test('each declared key round-trips a non-default value', () {
        final samples = _samples(spec);
        final outs = [for (final s in samples) _roundTrip(spec.type, s)];
        for (final d in spec.fields) {
          final isAny = identical(d.codec, Codecs.any);
          var shown = false;
          for (var i = 0; i < samples.length && !shown; i++) {
            final value = samples[i][d.key];
            if (!outs[i].containsKey(d.key)) continue;
            // An enum with one value can't differ from its default.
            final def = d.defaultValue == null ? null : d.encode(d.defaultValue);
            final single = d.codec is EnumCodec && (d.codec as EnumCodec).values.length == 1;
            if (!isAny && !single && jsonEquality.equals(value, def)) continue;
            shown = isAny || jsonEquality.equals(outs[i][d.key], value);
          }
          expect(shown, isTrue, reason: '${spec.type}.${d.key}: ${[for (final o in outs) o[d.key]]}');
          // The codec reads the sample back.
          if (!isAny) expect(d.decode(samples.first[d.key]), isNotNull, reason: '${spec.type}.${d.key}');
        }
      });

      test('every key it writes is declared', () {
        final declared = {for (final d in spec.fields) d.key};
        for (final s in _samples(spec)) {
          final keys = _roundTrip(spec.type, s).keys.toSet().difference(_common);
          expect(keys.difference(declared), isEmpty, reason: spec.type);
        }
      });

      test('defaults write nothing but the always-written keys', () {
        // An action with no fields set writes only keys it always writes,
        // each at its declared default.
        final json = _roundTrip(spec.type, const {});
        final byKey = {for (final d in spec.fields) d.key: d};
        for (final e in json.entries) {
          if (_common.contains(e.key)) continue;
          final d = byKey[e.key];
          expect(d, isNotNull, reason: '${spec.type}.${e.key}');
          if (identical(d!.codec, Codecs.any)) continue;
          expect(e.value, d.encode(d.defaultValue), reason: '${spec.type}.${e.key}');
        }
      });
    });
  }
}
