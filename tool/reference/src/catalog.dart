// The reference as data: every declaration walked into one JSON-able map
// (docs/reference/catalog.json), which the Markdown pages and the JSON
// Schema are rendered from.
import 'dart:convert';
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/validate.dart';

import 'introspect.dart';

/// A declaration that has no documentation, for `_missing_docs.md`.
typedef Missing = ({String area, String name});

final class Catalog {
  Catalog(this.root);

  /// The package root (docs and data are read relative to it).
  final String root;
  final DocIndex docs = DocIndex.instance;
  final List<Missing> missing = [];

  /// Object (model) types by name, filled while walking.
  final Map<String, Json> objectTypes = {};
  final Map<String, PropType> _objectPropTypes = {};

  /// Value types met, by name.
  final Set<String> valueTypes = {};

  /// Enums met, by name.
  final Map<String, List<String>> enums = {};

  late final Json json = _build();

  Json _build() {
    final nodeTypes = <String, Object?>{};
    for (final spec in Widgets.all) {
      nodeTypes[spec.type] = _nodeType(spec);
    }
    final layout = _fields(LayoutFields.all, area: 'layout', models: const ['Layout']);
    final decoration = _fields(DecorationFields.all, area: 'decoration', models: const ['Decoration']);
    final node = _fields(NodeFields.all, area: 'node', models: const ['Node']);
    final behaviors = _fields(BehaviorFields.all, area: 'behavior', models: const ['Behaviors']);
    final triggerFields = _fields(TriggerFields.all, area: 'trigger', models: const ['Trigger']);
    final common = _fields(ActionCommonFields.all, area: 'action', models: const ['ActionDef']);
    final actions = <String, Object?>{};
    for (final a in ActionSpecs.all) {
      final cls = docs.classOfType[a.type];
      final doc = a.doc.isNotEmpty ? DocIndex.clean(a.doc) : (cls == null ? '' : docs.classDocs[cls] ?? '');
      if (doc.isEmpty) missing.add((area: 'action type', name: a.type));
      actions[a.type] = {
        'label': a.label,
        'class': ?cls,
        'doc': doc,
        'fields': _fields(a.fields, area: 'action ${a.type}', models: [?cls]),
      };
    }
    final triggerTypes = [
      for (final t in TriggerType.values)
        {
          'type': t.name,
          'doc': docs.enumDocs['TriggerType']?[t.name] ?? '',
          'group': TriggerType.pointer.contains(t)
              ? 'pointer'
              : TriggerType.input.contains(t)
                  ? 'input'
                  : TriggerType.screen.contains(t)
                      ? 'screen'
                      : 'other',
        },
    ];
    for (final t in triggerTypes) {
      if (t['doc'] == '') missing.add((area: 'trigger type', name: t['type'] as String));
    }
    // Script fields are declared too.
    final scriptFields = _fields(ScriptFields.all, area: 'script', models: const ['ScriptDef']);
    final breakpointFields = _fields(Breakpoint.spec.props, area: 'breakpoint', models: const ['Breakpoint']);

    // Variables and conditions are models without PropDefs: their classes'
    // fields, with the JSON keys checked to round-trip (see _modelFields).
    final variable = _modelFields('Variable', {
      'id': 'v1', 'name': 'count', 'type': 'integer', 'value': 3, 'formula': 'a + 1', 'parameters': ['a'],
      'options': ['a'], 'persist': true,
    });
    final enumsJson = {
      for (final e in (enums.keys.toList()..sort()))
        e: [
          for (final v in enums[e]!) {'value': v, 'doc': docs.enumDocs[e]?[v] ?? ''},
        ],
    };
    for (final e in const ['VariableType', 'ConditionOp', 'WidgetState', 'Join']) {
      enumsJson[e] ??= [
        for (final v in docs.enumValues[e] ?? const <String>[]) {'value': v, 'doc': docs.enumDocs[e]?[v] ?? ''},
      ];
    }
    final formulas = _formulas();
    return {
      'package': 'codelessly_api',
      'version': _version(),
      'schema': kSchemaVersion,
      'document': {
        'keys': [
          {'key': 'schema', 'doc': 'Always 2 (`kSchemaVersion`).'},
          {'key': 'id', 'doc': 'The layout\'s id (optional).'},
          {'key': 'roots', 'doc': 'Canvas ids, in order: the screens of this page.'},
          {'key': 'nodes', 'doc': 'Every node, by id: `{"<id>": {"type": ..., ...}}`. A node\'s id is its key here.'},
          {'key': 'variables', 'doc': 'Variables per scope: `{"<canvas id>" | "page_variables": [variable, ...]}`.'},
          {'key': 'conditions', 'doc': 'Conditions per canvas: `{"<canvas id>": [condition, ...]}`.'},
          {'key': 'scripts', 'doc': 'The layout\'s scripts (JavaScript), a list of script objects.'},
          {'key': 'breakpoints', 'doc': 'The project\'s breakpoints: `[{"id", "name", "minWidth", "width", "height"}]`; absent: the defaults.'},
        ],
        'canvasRouteKeys': [...canvasRouteKeys],
      },
      'node': {
        'structural': [
          {'key': 'type', 'type': 'String', 'doc': 'The node type (a key of `nodeTypes`). Required.'},
          {'key': 'name', 'type': 'String', 'doc': docs.fieldDocs['Node']?['name'] ?? ''},
          {'key': 'key', 'type': 'String', 'doc': docs.fieldDocs['Node']?['key'] ?? ''},
          {'key': 'children', 'type': 'List<String>', 'doc': 'Ordered child ids, for types that take children.'},
          {'key': 'slots', 'type': 'Map<String, String>', 'doc': 'Named children, slot → node id, for types with slots.'},
          {'key': 'layout', 'type': 'Layout', 'doc': 'How the node sizes itself and sits in its parent (see layout).'},
          {'key': 'decoration', 'type': 'Decoration', 'doc': 'Fills, strokes, radius, shadows, blurs, clip (see decoration).'},
          {'key': 'props', 'type': 'Map', 'doc': 'The node type\'s own parameters (see nodeTypes).'},
          {'key': 'bind', 'type': 'Map<String, String>', 'doc': docs.fieldDocs['Node']?['bind'] ?? ''},
          {'key': 'actions', 'type': 'List<Reaction>', 'doc': 'Reactions: `{"trigger": {...}, "actions": [...]}` (see triggers, actions).'},
          {'key': 'component', 'type': 'ComponentLink', 'doc': docs.fieldDocs['Node']?['component'] ?? ''},
        ],
        'fields': node,
      },
      'nodeTypes': nodeTypes,
      'layout': {
        'fields': layout,
        'box': [for (final f in LayoutFields.box) f.key],
        'parentData': [for (final f in LayoutFields.parentData) f.key],
        'undeclared': ['widthFactor', 'heightFactor'],
        'undeclaredDoc': docs.fieldDocs['Layout']?['widthFactor'] ?? '',
        'childFits': _childFits(),
      },
      'decoration': {'fields': decoration},
      'behaviors': {'fields': behaviors},
      'triggers': {'types': triggerTypes, 'fields': triggerFields},
      'actions': {'common': common, 'types': actions, 'nestedChainKeys': [...nestedChainKeysPublic]},
      'bindings': _bindings(),
      'scopes': [...runtimeScopes],
      'variables': {'fields': variable, 'scopes': ['<canvas id>', pageVariablesScope]},
      'conditions': {
        'ops': [
          for (final o in ConditionOp.values)
            {'op': o.name, 'takesRight': o.takesRight, 'doc': docs.enumDocs['ConditionOp']?[o.name] ?? ''},
        ],
        'operandDoc': docs.classDocs['ConditionOperand'] ?? '',
        'comparisonDoc': docs.classDocs['Comparison'] ?? '',
        'junctionDoc': docs.classDocs['Junction'] ?? '',
        'branchDoc': docs.classDocs['ConditionBranch'] ?? '',
        'setDoc': docs.classDocs['PropertySet'] ?? '',
        'conditionDoc': docs.classDocs['Condition'] ?? '',
      },
      'scripts': {'fields': scriptFields},
      'breakpoints': {
        'fields': breakpointFields,
        'defaults': Breakpoints.defaults.toJson().isEmpty
            ? [for (final b in Breakpoints.defaults.list) b.toJson()]
            : Breakpoints.defaults.toJson(),
      },
      'valueTypes': {
        for (final v in (valueTypes.toList()..sort()))
          v: {'forms': valueForms[v] ?? '', 'doc': docs.classDocs[v] ?? ''},
      },
      'objectTypes': {for (final k in (objectTypes.keys.toList()..sort())) k: objectTypes[k]},
      'enums': enumsJson,
      'formulas': formulas,
      'diagnostics': [
        for (final c in Codes.all) {'code': c.name, 'severity': c.severity.name, 'meaning': c.meaning},
      ],
    };
  }

  String _version() {
    final m = RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(File('$root/pubspec.yaml').readAsStringSync());
    return m?.group(1) ?? '';
  }

  Json _formulas() {
    final f = File('$root/tool/reference/data/formulas.json');
    if (!f.existsSync()) return {'functions': [], 'undocumented': []};
    final j = jsonDecode(f.readAsStringSync()) as Map<String, Object?>;
    for (final u in (j['undocumented'] as List? ?? const [])) {
      missing.add((area: 'formula function', name: '$u'));
    }
    return j;
  }

  Json _nodeType(WidgetSpec spec) {
    final owner = docs.declarations(spec).firstOrNull?.owner;
    final classDoc = owner == null ? '' : docs.classDocs[owner] ?? '';
    final flutter = RegExp(r'^Flutter `([A-Za-z][\w.<>]*)`').firstMatch(spec.doc)?.group(1);
    final doc = [
      if (spec.doc.isNotEmpty) DocIndex.clean(spec.doc),
      if (classDoc.isNotEmpty && classDoc != DocIndex.clean(spec.doc)) classDoc,
    ].join('\n\n');
    return {
      'doc': doc,
      'flutter': ?flutter,
      'children': spec.children.name,
      'slots': spec.slots,
      'decorated': spec.decorated,
      'childFields': [for (final f in spec.childFields) f.key],
      'props': _fields(spec.props, area: 'prop ${spec.type}', prefer: [?owner]),
    };
  }

  List<Json> _fields(List<PropDef<Object?>> defs,
      {required String area, Iterable<String> prefer = const [], Iterable<String> models = const []}) {
    return [
      for (final d in defs) _field(d, area: area, prefer: prefer, models: models),
    ];
  }

  Json _field(PropDef<Object?> def, {required String area, Iterable<String> prefer = const [], Iterable<String> models = const []}) {
    final doc = docs.docOf(def, prefer: prefer, models: models);
    if (doc.isEmpty) missing.add((area: area, name: '${docs.nameOf(def, prefer: prefer)} (`${def.key}`)'));
    final t = def.type;
    Object? dflt;
    try {
      dflt = def.defaultValue == null ? null : def.codec.encode(def.defaultValue);
    } catch (_) {
      dflt = '${def.defaultValue}';
    }
    return {
      'key': def.key,
      'type': t.typeName,
      'kind': t.kind.name,
      'default': dflt,
      'nullable': def.nullable,
      ..._typeInfo(t),
      'doc': doc,
    };
  }

  /// What a field's type needs beyond its name: enum, bounds, item, object.
  Json _typeInfo(PropType t) {
    switch (t.kind) {
      case PropKind.enumeration:
        enums[t.name] = t.values;
        return {'enum': t.name, if (t.values.length <= 12) 'values': t.values};
      case PropKind.integer || PropKind.number:
        return {'min': ?t.min, 'max': ?t.max};
      case PropKind.value:
        valueTypes.add(t.name);
        return {};
      case PropKind.list:
        return {'item': t.item!.typeName, 'itemKind': t.item!.kind.name, ...{for (final e in _typeInfo(t.item!).entries) 'item_${e.key}': e.value}};
      case PropKind.object:
        _object(t);
        return {'object': t.name};
      default:
        return {};
    }
  }

  void _object(PropType t) {
    if (objectTypes.containsKey(t.name)) return;
    objectTypes[t.name] = {}; // placeholder: types can contain themselves
    _objectPropTypes[t.name] = t;
    objectTypes[t.name] = {
      'doc': docs.classDocs[t.name] ?? '',
      'fields': _fields(t.fields, area: 'field of ${t.name}', prefer: ['${t.name}Fields'], models: [t.name]),
    };
  }

  /// A model's fields by its class (no PropDefs): name, Dart type, doc;
  /// [sample] proves which keys its JSON reads (they round-trip).
  List<Json> _modelFields(String cls, Json sample) {
    final fields = docs.fieldDocs[cls] ?? const {};
    final roundTrip = switch (cls) {
      'Variable' => Variable.fromJson(sample)?.toJson() ?? const {},
      _ => const <String, Object?>{},
    };
    return [
      for (final k in sample.keys)
        if (roundTrip.containsKey(k)) {'key': k, 'doc': fields[k] ?? '', 'example': sample[k]},
    ];
  }

  /// Which width/height modes each parent allows, from the parents' rules.
  List<Json> _childFits() {
    final parents = <(String, Json)>[
      ('row', {}),
      ('column', {}),
      ('row', {'wrap': true}),
      ('column', {'scrollable': true}),
      ('row', {'scrollable': true, 'scrollDirection': 'horizontal'}),
      ('stack', {}),
      ('canvas', {}),
      ('listView', {}),
      ('listView', {'itemExtent': 80}),
      ('gridView', {}),
      ('pageView', {}),
    ];
    return [
      for (final (type, props) in parents)
        {
          'parent': type,
          'props': props,
          for (final axis in const ['width', 'height'])
            axis: {
              for (final e in childFitOptions(Node.fromJson({'type': type, 'props': props}, catalog: standardCatalog)!, horizontal: axis == 'width').entries)
                e.key.name: e.value,
            },
        },
    ];
  }

  Json _bindings() {
    final constants = <Json>[];
    for (final e in const [
      ('visible', 'visible'), ('opacity', 'opacity'), ('selected', 'selected'), ('disabled', 'disabled'), ('data', 'data'), //
      ('width', 'layout.width'), ('height', 'layout.height'), ('flex', 'layout.flex'), ('rotation', 'layout.rotation'),
      ('margin', 'layout.margin'), ('padding', 'layout.padding'), ('x', 'layout.x'), ('y', 'layout.y'),
      ('radius', 'decoration.radius'), ('strokeWidth', 'decoration.strokeWidth'), ('scale', 'scale'),
      ('textDirection', 'textDirection'),
    ]) {
      constants.add({'path': e.$2, 'doc': docs.staticDocs['BindPaths']?[e.$1] ?? ''});
    }
    return {'constants': constants, 'doc': docs.classDocs['BindPaths'] ?? ''};
  }
}

/// The nested chain keys (validator's), public for the catalog.
const nestedChainKeysPublic = {'then', 'else', 'actions', 'onSuccess', 'onError', 'cancelActions'};
