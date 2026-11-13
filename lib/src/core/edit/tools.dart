// The two tools a model is given to build and change a UI (`ui_apply`,
// `ui_read`), with JSON Schemas generated from the op declarations
// ([EditOp.specs]) and a catalog, so the schema stays true to what
// [decodeOps] and [applyOps] accept.
import '../behaviors.dart';
import '../catalog.dart';
import '../json.dart';
import '../value_fields.dart';
import 'edit_ops.dart';

/// The `ui_apply` tool's description: what a model reads about the ops.
const String uiApplyDescription =
    'Build or change the UI. The UI is one document: a flat map of nodes by id, each a Flutter-like widget '
    '(type, layout, decoration, props, children). Ops apply in order: '
    'set (create or replace a node, optionally placing it under a parent), '
    'patch (RFC 7396 merge patch on one node; null deletes a key), move, remove, '
    'vars (set or declare variables) and roots (the screens). '
    'Ids are the addresses: choose short readable ids. A node may list children that arrive in later ops. '
    'When building, write top-down: the roots op and the canvas first, then each container before its children, '
    'section by section, so the UI paints as it streams. To change an existing UI, send only the small ops the change needs '
    '(patch a prop instead of re-sending a node). The result lists the ops that were rejected with a code, a path and a '
    'suggestion: fix and resend only those.';

/// The `ui_read` tool's description.
const String uiReadDescription =
    'Read the current UI before changing it: the outline (one row per node: id, type, label, depth, what is bound), '
    'or full nodes by id. Read the outline first; ask for full nodes only for the ones you will change.';

/// The JSON Schema of a node in [catalog] (its `type` one of the catalog's
/// node types; the node keys and the behaviors as declared).
Json nodeSchema(Catalog catalog) => {
      'type': 'object',
      'required': ['type'],
      'properties': {
        'type': {
          'type': 'string',
          'enum': [for (final w in catalog.widgets) w.type],
        },
        'name': {'type': 'string'},
        'children': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'Child ids, in order (they may arrive in later ops).',
        },
        'slots': {
          'type': 'object',
          'additionalProperties': {'type': 'string'},
          'description': 'Slot name → child id (a canvas: body, appBar, bottomNavigationBar, floatingActionButton).',
        },
        'layout': {
          'type': 'object',
          'description': 'Size and placement: ${[for (final f in LayoutFields.all) f.key].join(', ')}.',
        },
        'decoration': {
          'type': 'object',
          'description': 'Paint: ${[for (final f in DecorationFields.all) f.key].join(', ')}.',
        },
        'props': {'type': 'object', 'description': 'The node type\'s own parameters (text, style, spacing...).'},
        'bind': {
          'type': 'object',
          'additionalProperties': {'type': 'string'},
          'description': 'Binding path → expression (`props.text`: `\${user.name}`).',
        },
        'actions': {'type': 'array', 'description': 'Reactions: {"trigger": {"type": "click"}, "actions": [...]}.'},
        'visible': {'type': 'boolean'},
        'opacity': {'type': 'number'},
        'media': {'type': 'array', 'description': 'Rules by screen width: [{"maxWidth": 599, "patch": {...}}].'},
        for (final k in Behaviors.keys) k: <String, Object?>{},
        for (final k in editNodeKeys)
          if (!const {'type', 'name', 'children', 'slots', 'layout', 'decoration', 'props', 'bind', 'actions', 'visible', 'opacity', 'media'}
              .contains(k))
            k: <String, Object?>{},
      },
      'additionalProperties': false,
    };

Json _fieldSchema(EditOpField f) => switch (f.kind) {
      EditFieldKind.string => {'type': 'string'},
      EditFieldKind.integer => {'type': 'integer'},
      EditFieldKind.boolean => {'type': 'boolean'},
      EditFieldKind.object => {'type': 'object'},
      EditFieldKind.strings => {
          'type': 'array',
          'items': {'type': 'string'},
        },
    };

/// The JSON Schema of one op, from its declaration.
Json opSchema(EditOpSpec spec) => {
      'type': 'object',
      'description': spec.doc,
      'required': [for (final f in spec.fields) if (f.required) f.key],
      'properties': {
        for (final f in spec.fields)
          f.key: f.key == 'op'
              ? {'const': spec.op}
              : f.key == 'node'
                  ? {r'$ref': r'#/$defs/Node', 'description': f.doc}
                  : f.key == 'nodes'
                      ? {
                          'type': 'object',
                          'additionalProperties': {r'$ref': r'#/$defs/Node'},
                          'description': f.doc,
                        }
                      : {..._fieldSchema(f), if (f.doc.isNotEmpty) 'description': f.doc},
      },
      if (spec.alternatives.isNotEmpty)
        'anyOf': [
          for (final a in spec.alternatives) {'required': a},
        ],
      'additionalProperties': false,
    };

/// The `ui_apply` tool input's JSON Schema, for [catalog]'s node types.
Json uiApplyInputSchema(Catalog catalog) => {
      'type': 'object',
      'required': ['ops'],
      'properties': {
        'ops': {
          'type': 'array',
          'description': 'The ops, applied in order.',
          'items': {
            'anyOf': [for (final s in EditOp.specs) opSchema(s)],
          },
        },
        'baseRev': {'type': 'integer', 'description': 'The revision you read (from ui_read or the last result).'},
        'atomic': {'type': 'boolean', 'description': 'Apply all ops or none.'},
      },
      r'$defs': {'Node': nodeSchema(catalog)},
      'additionalProperties': false,
    };

/// The `ui_read` tool input's JSON Schema.
const Json uiReadInputSchema = {
  'type': 'object',
  'properties': {
    'ids': {
      'type': 'array',
      'items': {'type': 'string'},
      'description': 'Ids of the nodes to return in full.',
    },
    'outline': {'type': 'boolean', 'description': 'Include the outline (default: when no ids are given).'},
    'variables': {'type': 'boolean', 'description': 'Include the variables.'},
  },
  'additionalProperties': false,
};

/// The two tools, as `{"name", "description", "input_schema"}` (the shape
/// most providers take; rename `input_schema` for one that differs).
List<Json> uiTools(Catalog catalog) => [
      {'name': 'ui_apply', 'description': uiApplyDescription, 'input_schema': uiApplyInputSchema(catalog)},
      {'name': 'ui_read', 'description': uiReadDescription, 'input_schema': uiReadInputSchema},
    ];
