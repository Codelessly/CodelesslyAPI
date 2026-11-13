// A JSON Schema (2020-12) for a layout document, generated from the
// declarations: node types and their props, layout, decoration, behaviors,
// triggers and actions, each with its type, enum values and bounds;
// unknown keys rejected. Shorthand forms the decoders accept (a trigger as
// its type name, a hero as its tag...) are found by asking each codec.
import 'package:codelessly_api/codelessly_api.dart';

/// What the schema cannot check, which validation does (said in its
/// description and in the reference).
const schemaLimits = [
  'references between nodes (children, slots and roots that name no node, a node with two parents, cycles, unreachable nodes)',
  'layout fields that only some parents read (x/y outside a stack, flex/align outside a row or column) and sizing modes a parent cannot honor',
  'binding paths (keys of "bind") and the names expressions read',
  'action targets (node ids, screens, variables) and the patches interaction states apply',
  'variable values against their type, conditions\' node and path references, breakpoint ids',
  'formulas (the language is the SDK\'s)',
];

final class SchemaBuilder {
  final Map<String, Object?> defs = {};

  Json build() {
    final nodeTypes = [for (final s in Widgets.all) s.type];
    defs['node'] = _node(nodeTypes);
    defs['layout'] = _fields(LayoutFields.all, extra: {
      'widthFactor': {'type': 'number', 'minimum': 0},
      'heightFactor': {'type': 'number', 'minimum': 0},
    });
    defs['decoration'] = _fields(DecorationFields.all);
    defs['trigger'] = {
      'anyOf': [
        {'enum': [for (final t in TriggerType.values) t.name]},
        _fields(TriggerFields.all, required: const ['type']),
      ],
    };
    defs['reaction'] = {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'name': {'type': 'string'},
        'trigger': {r'$ref': '#/\$defs/trigger'},
        'actions': {'type': 'array', 'items': {r'$ref': '#/\$defs/action'}},
      },
      'required': ['trigger'],
      'additionalProperties': false,
    };
    defs['action'] = _action();
    defs['predicate'] = {
      'anyOf': [
        {
          'type': 'object',
          'properties': {
            'left': {r'$ref': '#/\$defs/operand'},
            'op': {'enum': [for (final o in ConditionOp.values) o.name]},
            'right': {r'$ref': '#/\$defs/operand'},
          },
          'required': ['left'],
          'additionalProperties': false,
        },
        for (final j in Join.values)
          {
            'type': 'object',
            'properties': {
              j.name: {'type': 'array', 'items': {r'$ref': '#/\$defs/predicate'}},
            },
            'required': [j.name],
            'additionalProperties': false,
          },
      ],
    };
    defs['operand'] = {
      'anyOf': [
        {'type': ['string', 'number', 'boolean']},
        {'type': 'object', 'properties': {'raw': {}}, 'required': ['raw'], 'additionalProperties': false},
      ],
    };
    defs['variable'] = {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'name': {'type': 'string', 'pattern': r'^[A-Za-z_][A-Za-z0-9_]*$'},
        'type': {'enum': [for (final t in VariableType.values) t.name]},
        'value': {},
        'formula': {'type': 'string'},
        'parameters': {'type': 'array', 'items': {'type': 'string'}},
        'options': {'type': 'array'},
        'persist': {'type': 'boolean'},
      },
      'required': ['name'],
      'additionalProperties': false,
    };
    defs['condition'] = {
      'type': 'object',
      'properties': {
        'id': {'type': 'string'},
        'name': {'type': 'string'},
        'branches': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'when': {r'$ref': '#/\$defs/predicate'},
              'set': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {'node': {'type': 'string'}, 'path': {'type': 'string'}, 'value': {}},
                  'required': ['node', 'path'],
                  'additionalProperties': false,
                },
              },
            },
            'additionalProperties': false,
          },
        },
      },
      'required': ['branches'],
      'additionalProperties': false,
    };
    return {
      r'$schema': 'https://json-schema.org/draft/2020-12/schema',
      r'$id': 'https://codelessly.com/schemas/layout-document.schema.json',
      'title': 'Codelessly layout document (schema 2)',
      'description': 'Generated from the codelessly_api declarations. It rejects unknown node types, unknown keys, '
          'wrong value types and enum values, and numbers out of bounds. It cannot check: ${schemaLimits.join('; ')}. '
          'Run validateDocument (package:codelessly_api/validate.dart) or tool/render/render.sh for those. '
          'It is stricter than the decoders where they read loosely: a number written as text, a color without "#".',
      'type': 'object',
      'properties': {
        'schema': {'const': kSchemaVersion},
        'id': {'type': 'string'},
        'roots': {'type': 'array', 'items': {'type': 'string'}, 'minItems': 1},
        'nodes': {'type': 'object', 'additionalProperties': {r'$ref': '#/\$defs/node'}},
        'variables': {
          'type': 'object',
          'additionalProperties': {'type': 'array', 'items': {r'$ref': '#/\$defs/variable'}},
        },
        'conditions': {
          'type': 'object',
          'additionalProperties': {'type': 'array', 'items': {r'$ref': '#/\$defs/condition'}},
        },
        'scripts': {'type': 'array', 'items': _fields(ScriptFields.all, required: const ['name'])},
        'breakpoints': {'type': 'array', 'items': _fields(Breakpoint.spec.props, required: const ['id'])},
      },
      'required': ['schema', 'roots', 'nodes'],
      'additionalProperties': false,
      r'$defs': {for (final k in (defs.keys.toList()..sort())) k: defs[k]},
    };
  }

  Json _node(List<String> types) {
    final common = <String, Object?>{
      'type': {'enum': types},
      'id': {'type': 'string'},
      'name': {'type': 'string'},
      'key': {'type': 'string'},
      'children': {'type': 'array', 'items': {'type': 'string'}},
      'slots': {'type': 'object', 'additionalProperties': {'type': 'string'}},
      'layout': {r'$ref': '#/\$defs/layout'},
      'decoration': {r'$ref': '#/\$defs/decoration'},
      'props': {'type': 'object'},
      'bind': {'type': 'object', 'additionalProperties': {'type': 'string'}},
      'actions': {'type': 'array', 'items': {r'$ref': '#/\$defs/reaction'}},
      'component': {'type': 'object'},
      'media': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'minWidth': {'type': ['number', 'string']},
            'maxWidth': {'type': ['number', 'string']},
            'orientation': {'enum': ['portrait', 'landscape']},
            'patch': {
              'type': 'object',
              'properties': {
                'props': {'type': 'object'},
                'layout': {'type': 'object'},
                'decoration': {'type': 'object'},
                'visible': {'type': 'boolean'},
                'opacity': {'type': 'number'},
              },
              'additionalProperties': false,
            },
          },
          'required': ['patch'],
          'additionalProperties': false,
        },
      },
      for (final f in NodeFields.all) f.key: _field(f),
      for (final f in BehaviorFields.all) f.key: _field(f),
    };
    return {
      'type': 'object',
      'properties': common,
      'required': ['type'],
      'allOf': [
        for (final s in Widgets.all)
          {
            'if': {
              'properties': {'type': {'const': s.type}},
            },
            'then': {
              'properties': {
                'props': _fields(s.props),
                if (s.children != ChildModel.list) 'children': {'type': 'array', 'maxItems': 0},
                'slots': s.slots.isEmpty
                    ? {'type': 'object', 'maxProperties': 0}
                    : {
                        'type': 'object',
                        'propertyNames': {'enum': s.slots},
                        'additionalProperties': {'type': 'string'},
                      },
                if (s.type == CanvasProps.spec.type) ...{
                  'path': {'type': 'string'},
                  'under': {'type': 'string'},
                  'translucent': {'type': 'boolean'},
                },
              },
            },
          },
      ],
      'unevaluatedProperties': false,
    };
  }

  Json _action() {
    final types = [for (final a in ActionSpecs.all) a.type];
    return {
      'type': 'object',
      'properties': {
        'type': {'enum': types},
        'id': {'type': 'string'},
        for (final f in ActionCommonFields.all)
          f.key: f.key == 'when' ? {r'$ref': '#/\$defs/predicate'} : _field(f),
      },
      'required': ['type'],
      'allOf': [
        for (final a in ActionSpecs.all)
          {
            'if': {
              'properties': {'type': {'const': a.type}},
            },
            'then': {
              'properties': {
                for (final f in a.fields) f.key: _actionField(a, f),
              },
            },
          },
      ],
      'unevaluatedProperties': false,
    };
  }

  Object? _actionField(ActionSpec a, PropDef<Object?> f) {
    if (nestedChainKeysForSchema.contains(f.key) && f.type.kind == PropKind.json) {
      return {'type': 'array', 'items': {r'$ref': '#/\$defs/action'}};
    }
    if (a.type == 'if' && f.key == 'condition') return {r'$ref': '#/\$defs/predicate'};
    return _field(f);
  }

  Json _fields(List<PropDef<Object?>> fields, {Map<String, Object?> extra = const {}, List<String> required = const []}) => {
        'type': 'object',
        'properties': {for (final f in fields) f.key: _field(f), ...extra},
        if (required.isNotEmpty) 'required': required,
        'additionalProperties': false,
      };

  Object? _field(PropDef<Object?> f) => _type(f.type, f.codec, nullable: f.nullable);

  Object? _type(PropType t, PropCodec<Object?>? codec, {bool nullable = false}) {
    Object? s = switch (t.kind) {
      PropKind.boolean => {'type': 'boolean'},
      PropKind.integer => {'type': 'integer', 'minimum': ?t.min, 'maximum': ?t.max},
      PropKind.number => {'type': 'number', 'minimum': ?t.min, 'maximum': ?t.max},
      PropKind.string => {'type': 'string'},
      PropKind.enumeration => _enum(t),
      PropKind.value => _value(t.name),
      PropKind.list => {
          'type': 'array',
          'items': _type(t.item!, codec is ListCodec ? codec.item as PropCodec<Object?> : null),
        },
      PropKind.object => _object(t, codec),
      PropKind.json => t.name.startsWith('Map<') ? {'type': 'object'} : (t.name == 'Reaction' ? {r'$ref': '#/\$defs/reaction'} : {}),
    };
    if (nullable && s is Map && s.isNotEmpty) s = {'anyOf': [s, {'type': 'null'}]};
    return s;
  }

  Json _enum(PropType t) {
    final key = 'enum.${t.name}';
    defs[key] ??= {'enum': t.values};
    return {r'$ref': '#/\$defs/$key'};
  }

  Json _object(PropType t, PropCodec<Object?>? codec) {
    final key = 'model.${t.name}';
    if (!defs.containsKey(key)) {
      defs[key] = {}; // placeholder: models can contain themselves
      defs[key] = _fields(t.fields);
    }
    // Shorthands the codec reads: a string, a boolean, a number.
    final short = <String>[
      if (codec != null) ...[
        if (_reads(codec, 'standard') || _reads(codec, 'tag')) 'string',
        if (_reads(codec, true)) 'boolean',
        if (_reads(codec, 1)) 'number',
      ],
    ];
    if (short.isEmpty) return {r'$ref': '#/\$defs/$key'};
    return {
      'anyOf': [
        {r'$ref': '#/\$defs/$key'},
        {'type': short},
      ],
    };
  }

  static bool _reads(PropCodec<Object?> codec, Object v) {
    try {
      return codec.decode(v) != null;
    } catch (_) {
      return false;
    }
  }

  Json _value(String name) {
    final key = 'value.$name';
    const num = {'type': 'number'};
    defs[key] ??= switch (name) {
      'Color' => {'type': 'string', 'pattern': r'^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$'},
      'EdgeInsets' => {
          'anyOf': [num, {'type': 'array', 'items': num, 'minItems': 4, 'maxItems': 4}],
        },
      'BorderRadius' => {
          'anyOf': [
            num,
            {'type': 'array', 'items': num, 'minItems': 2, 'maxItems': 2},
            {
              'type': 'array',
              'minItems': 4,
              'maxItems': 4,
              'items': {
                'anyOf': [num, {'type': 'array', 'items': num, 'minItems': 2, 'maxItems': 2}],
              },
            },
          ],
        },
      'Alignment' => {
          'anyOf': [
            {'enum': [...Alignment.named.keys]},
            {'type': 'array', 'items': num, 'minItems': 2, 'maxItems': 2},
          ],
        },
      'Offset' || 'Size' => {'type': 'array', 'items': num, 'minItems': 2, 'maxItems': 2},
      'Rect' => {'type': 'array', 'items': num, 'minItems': 4, 'maxItems': 4},
      'BoxConstraints' => {
          'type': 'object',
          'properties': {
            for (final k in const ['minWidth', 'maxWidth', 'minHeight', 'maxHeight']) k: {'type': 'number', 'minimum': 0},
          },
          'additionalProperties': false,
        },
      'AxisSize' => {
          'anyOf': [
            {'type': 'number', 'minimum': 0},
            {
              'type': 'object',
              'properties': {for (final k in const ['fixed', 'fill', 'flexible', 'hug']) k: {'type': 'number', 'minimum': 0}},
              'minProperties': 1,
              'maxProperties': 1,
              'additionalProperties': false,
            },
          ],
        },
      'AxisPosition' => {
          'anyOf': [
            num,
            {
              'type': 'object',
              'properties': {for (final k in const ['start', 'end', 'align', 'relative']) k: num},
              'minProperties': 1,
              'additionalProperties': false,
            },
          ],
        },
      'FontWeight' => {'enum': [100, 200, 300, 400, 500, 600, 700, 800, 900]},
      'FontFeature' => {'type': 'string', 'pattern': r'^[A-Za-z0-9]{4}(\s*=\s*\d+)?$'},
      'IconData' => {
          'anyOf': [
            {'type': 'string', 'minLength': 1},
            {'type': 'object'},
          ],
        },
      _ => {},
    };
    return {r'$ref': '#/\$defs/$key'};
  }
}

/// Action fields that hold nested chains.
const nestedChainKeysForSchema = {'then', 'else', 'actions', 'onSuccess', 'onError', 'cancelActions'};
