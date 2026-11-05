// Every declaration a properties panel reads (widget props, the fields of
// their models, a node's layout and decoration) matches the JSON the
// models really read and write: a sample value for each field, written
// into the model's JSON, decodes and encodes back unchanged. So a panel
// built from the declarations alone edits real values.
import 'package:codelessly_api/codelessly_api.dart';
import 'package:test/test.dart';

/// JSON a model needs before a field can be shown on it (an effect needs a
/// type, a run a valid range, an image paint is only kept on image paints).
Json _base(PropType type, String field) => {
  // Value fields at their defaults (a gradient stop needs its color).
  for (final d in type.fields)
    if (d.defaultValue != null && d.type.kind == PropKind.value) d.key: d.encode(d.defaultValue),
  ..._extra(type, field),
};

Json _extra(PropType type, String field) => switch (type.name) {
  'Effect' => {'type': field == 'type' ? 'innerShadow' : 'dropShadow'},
  'TextRun' => {'start': 0, 'end': 9},
  'Paint' when field == 'image' => {'type': 'image'},
  _ => {},
};

/// A JSON value of [type] that differs from [def]'s default.
Object? sample(PropType type, [PropDef<Object?>? def]) {
  switch (type.kind) {
    case PropKind.boolean:
      return def?.defaultValue == true ? false : true;
    case PropKind.integer:
      final d = def?.defaultValue as int? ?? 0;
      final max = type.max;
      return max != null && d + 3 > max ? (d - 1) : d + 3;
    case PropKind.number:
      final min = type.min, max = type.max;
      if (min != null && max != null) {
        final mid = (min + max) / 2 + (max - min) / 8;
        return mid == def?.defaultValue ? min.toDouble() : mid;
      }
      final d = (def?.defaultValue as num?)?.toDouble() ?? 0;
      return d + 2.5;
    case PropKind.string:
      return 'sample';
    case PropKind.enumeration:
      final d = (def?.defaultValue as Enum?)?.name;
      return type.values.firstWhere((v) => v != d);
    case PropKind.value:
      return switch (type.name) {
        'Color' => '#FF123456',
        'EdgeInsets' => [1, 2, 3, 4],
        'BorderRadius' => 5,
        'Alignment' => [0.5, -0.5],
        'Offset' => [3, 4],
        'BoxConstraints' => {'minWidth': 10, 'maxHeight': 90},
        'IconData' => {'source': 'material', 'name': 'home', 'codepoint': 59530},
        'Size' => [10, 20],
        'FontWeight' => 700,
        'Rect' => [1, 2, 30, 40],
        'AxisSize' => {'fill': 10},
        'AxisPosition' => {'end': 5},
        _ => throw StateError('no sample for value type ${type.name}'),
      };
    case PropKind.list:
      return [sample(type.item!)];
    case PropKind.object:
      // Required fields at their defaults, then one field changed.
      final f = type.fields.first;
      return {..._base(type, f.key), f.key: sample(f.type, f)};
    case PropKind.json:
      return type.name == 'Reaction'
          ? {
              'trigger': {'type': 'click'},
              'actions': [
                {'type': 'openLink', 'url': 'https://example.com'},
              ],
            }
          : {'a': 1};
  }
}

bool _eq(Object? a, Object? b) => a is List && b is List
    ? a.length == b.length && [for (var i = 0; i < a.length; i++) _eq(a[i], b[i])].every((x) => x)
    : jsonEquality.equals(a, b) || a == b;

/// Checks that [def] round-trips a sample through [roundTrip] (the JSON of
/// the model the field is in), and the fields of its object types.
void checkField(
  String where,
  PropDef<Object?> def,
  Object? Function(Json) roundTrip,
  PropType owner,
  Set<String> seen,
) {
  final s = sample(def.type, def);
  final json = {..._base(owner, def.key), def.key: s};
  final back = roundTrip(json);
  expect(back, isA<Map>(), reason: '$where: decoding $json');
  // Same value (models compare by value; defaults inside are dropped).
  final got = (back as Map)[def.key];
  final same = jsonEquality.equals(got, s) || (got != null && _eq(def.decode(got), def.decode(s)));
  expect(same, isTrue, reason: '$where.${def.key}: $s came back as $got');
  checkType('$where.${def.key}', def.type, seen);
}

/// Checks each field of [type] (and of the types nested in it) once.
void checkType(String where, PropType type, Set<String> seen) {
  if (type.kind == PropKind.list) return checkType(where, type.item!, seen);
  if (type.kind != PropKind.object || !seen.add(type.name)) return;
  expect(type.fields, isNotEmpty, reason: '$where: ${type.name} declares no fields');
  // The codec of this object type: found on the field that holds it.
  final codec = _codecs[type.name];
  expect(codec, isNotNull, reason: 'no codec registered for ${type.name}');
  for (final f in type.fields) {
    checkField(type.name, f, (j) => codec!(j) as Json?, type, seen);
  }
}

/// Decode-then-encode of each object type, collected from the props that
/// hold them.
final _codecs = <String, Object? Function(Json)>{};

void _collect(PropCodec<Object?> codec) {
  final t = codec.type;
  if (codec is ListCodec) return _collect(codec.item);
  if (t.kind == PropKind.object && !_codecs.containsKey(t.name)) {
    _codecs[t.name] = (j) {
      final v = codec.decode(j);
      return v == null ? null : codec.encode(v);
    };
    for (final f in t.fields) {
      _collect(f.codec);
    }
  }
}

Iterable<PropDef<Object?>> get _everyTopDef sync* {
  for (final s in Widgets.all) {
    yield* s.props;
  }
  yield* LayoutFields.all;
  yield* DecorationFields.all;
  yield* NodeFields.all;
}

void main() {
  for (final d in _everyTopDef) {
    _collect(d.codec);
  }

  test('every widget prop round-trips a sample value through its codec', () {
    final seen = <String>{};
    for (final spec in Widgets.all) {
      for (final p in spec.props) {
        checkField(
          spec.type,
          p,
          (j) {
            final v = p.decode(j[p.key]);
            return v == null ? null : {p.key: p.encode(v)};
          },
          const PropType.json(),
          seen,
        );
      }
    }
  });

  test('a node\'s layout fields are its layout JSON', () {
    final seen = <String>{};
    for (final f in LayoutFields.all) {
      checkField('layout', f, (j) => Layout.fromJson(j).toJson(), const PropType.json(), seen);
    }
    expect(
      {for (final f in LayoutFields.all) f.key},
      containsAll(
        Layout.fromJson(const {
          'width': {'fill': 1}, 'height': 2, 'flex': 2, 'squeezable': true, 'constraints': {'minWidth': 1}, //
          'margin': 1, 'padding': 1, 'x': {'end': 1}, 'y': {'end': 1}, 'align': [0, 0], 'rotation': 1, 'aspectRatio': 1,
        }).toJson().keys,
      ),
    );
  });

  test('a node\'s decoration fields are its decoration JSON', () {
    final seen = <String>{};
    const strokes = [
      {'color': '#FF000000'},
    ];
    for (final f in DecorationFields.all) {
      checkField(
        'decoration',
        f,
        (j) {
          // Stroke settings are only kept with strokes.
          final json = j.containsKey('strokes') ? j : {...j, 'strokes': strokes};
          return Decoration.fromJson(json).toJson();
        },
        const PropType.json(),
        seen,
      );
    }
  });

  test('node fields', () {
    for (final f in NodeFields.all) {
      final s = sample(f.type, f);
      final n = Node.fromJson({'id': 'a', 'type': 'box', f.key: s})!;
      expect(n.toJson()[f.key], s);
    }
  });

  test('every object type a panel can reach declares fields its model keeps', () {
    final seen = <String>{};
    for (final d in _everyTopDef) {
      checkType(d.key, d.type, seen);
    }
    expect(seen, containsAll(['TextStyle', 'Paint', 'Effect', 'ButtonStyle', 'InputDecoration', 'ChartSeries']));
  });

  test('types name Flutter types', () {
    expect(TextProps.style.type.name, 'TextStyle');
    expect(FlexProps.mainAxisAlignment.type.values, contains('spaceBetween'));
    expect(DecorationFields.fills.type.typeName, 'List<Paint>');
    expect(LayoutFields.margin.type.name, 'EdgeInsets');
    expect(CheckboxProps.activeColor.nullable, isTrue);
  });
}
