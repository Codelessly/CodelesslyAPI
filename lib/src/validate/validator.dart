// Strict validation of a layout document: everything the lenient decoders
// would silently drop, replace or ignore, reported with a code, a JSON
// pointer and (where the declarations allow) a suggestion. Never throws.
import '../core/action_fields.dart';
import '../core/actions.dart';
import '../core/behavior_fields.dart';
import '../core/behaviors.dart';
import '../core/child_fits.dart';
import '../core/conditions.dart';
import '../core/decoration.dart';
import '../core/json.dart';
import '../core/layout.dart';
import '../core/logic.dart';
import '../core/node.dart';
import '../core/props.dart';
import '../core/media.dart';
import '../core/breakpoints.dart';
import '../core/scripts.dart';
import '../core/triggers.dart';
import '../core/value_fields.dart';
import '../core/variables.dart';
import '../core/widgets/canvas.dart';
import '../core/widgets/flex.dart';
import '../core/values/enums.dart';
import '../standard_catalog.dart';
import 'bind_paths.dart';
import 'diagnostic.dart';
import 'expressions.dart';
import 'values.dart';

/// What a document is checked against beyond itself.
final class ValidateOptions {
  const ValidateOptions({
    this.screens = const {},
    this.variables = const {},
    this.formulas,
    this.breakpoints,
  });

  /// Screen ids (canvas and layout ids) of the other documents of the
  /// project, which navigation may name.
  final Set<String> screens;

  /// Variables declared elsewhere (the app's), which expressions may read.
  final Set<String> variables;

  /// Parses formulas (`${= ...}`); see [FormulaChecker]. Without one,
  /// formulas are only checked for closing braces.
  final FormulaChecker? formulas;

  /// The project's breakpoints when the document doesn't carry them.
  final Breakpoints? breakpoints;
}

/// The keys a layout document reads at its top level.
const Set<String> documentKeys = {
  'schema', 'id', 'roots', 'nodes', LayoutLogic.variablesKey, LayoutLogic.conditionsKey, LayoutDocumentScripts.key, //
  LayoutDocumentBreakpoints.key,
};

/// The variables scope shared by every canvas of a page.
const String pageVariablesScope = 'page_variables';

/// The keys a canvas node reads beyond node fields: its URL path, and how it
/// opens from a link (`ScreenRoute`: `under`, `translucent`).
const Set<String> canvasRouteKeys = {'path', 'under', 'translucent'};

/// Keys of an action that hold nested action chains.
const Set<String> nestedChainKeys = {'then', 'else', 'actions', 'onSuccess', 'onError', 'cancelActions'};

/// Checks [json], a layout document, against the declarations. Never throws.
List<Diagnostic> validateDocument(Object? json, {ValidateOptions options = const ValidateOptions()}) {
  final r = Reporter();
  try {
    _Validator(r, options).document(json);
  } catch (e) {
    r.add(Codes.invalidDocument, '', 'Validation stopped on an unexpected value: ${'$e'.split('\n').first}');
  }
  return r.out;
}

/// Checks several documents of one project (a site's pages): each against
/// the others' screens and node ids. Keys are file names; diagnostics carry
/// them in [Diagnostic.file].
List<Diagnostic> validateProject(Map<String, Object?> documents, {ValidateOptions options = const ValidateOptions()}) {
  final screens = <String>{...options.screens};
  final owner = <String, String>{};
  final out = <Diagnostic>[];
  for (final e in documents.entries) {
    final nodes = readMap(readMap(e.value)?['nodes']) ?? const {};
    for (final id in nodes.keys) {
      final before = owner[id];
      if (before != null) {
        out.add(Diagnostic(Codes.duplicateId, pointer('/nodes', id),
            'Node id "$id" is also used in $before: keep ids unique across a site so reports and steps name one node.', nodeId: id, file: e.key));
      }
      owner[id] = e.key;
      if (readMap(nodes[id])?['type'] == 'canvas') screens.add(id);
    }
  }
  for (final e in documents.entries) {
    final o = ValidateOptions(
        screens: screens, variables: options.variables, formulas: options.formulas, breakpoints: options.breakpoints);
    out.addAll(validateDocument(e.value, options: o).map((d) => d.withFile(e.key)));
  }
  return out;
}

/// A codec over a whole model (layout, decoration), for [readsKey].
final class _ModelCodec<T> extends PropCodec<T> {
  const _ModelCodec(this._in, this._out, this.type);
  final T? Function(Object?) _in;
  final Object? Function(T) _out;
  @override
  final PropType type;
  @override
  T? decode(Object? json) => _in(json);
  @override
  Object? encode(T value) => _out(value);
}

final _layoutCodec = _ModelCodec<Layout>(
    (j) => Layout.fromJson(j), (l) => l.toJson(), PropType.object('Layout', () => LayoutFields.all));
final _decorationCodec = _ModelCodec<Decoration>(
    (j) => Decoration.fromJson(j), (d) => d.toJson(), PropType.object('Decoration', () => DecorationFields.all));

final class _Validator {
  _Validator(this.r, this.options) {
    values = ValueChecker(r, hook: _jsonHook);
  }

  final Reporter r;
  final ValidateOptions options;
  late final ValueChecker values;

  Json nodesJson = const {};
  Map<String, Node> nodes = {};
  Set<String> canvases = {};
  final Map<String, String> canvasOf = {}; // node id → its root canvas
  final Map<String, Set<String>> variablesOf = {}; // scope → names
  Set<String> pageVariables = {};
  Breakpoints breakpoints = Breakpoints.defaults;
  String? currentCanvas;

  void document(Object? json) {
    final m = readMap(json);
    if (m == null) {
      r.add(Codes.invalidDocument, '', 'A layout document is a JSON object: {"schema": 2, "roots": [...], "nodes": {...}}.');
      return;
    }
    if (m['schema'] != 2) {
      r.add(Codes.schemaVersion, '/schema', m['schema'] == null ? 'Add "schema": 2.' : 'This package reads "schema": 2, got ${describe(m['schema'])}.');
    }
    for (final k in m.keys) {
      if (!documentKeys.contains(k)) {
        r.add(Codes.unknownDocumentKey, pointer('', k), 'A layout document has no "$k". It takes: ${documentKeys.join(', ')}.',
            suggestion: nearest(k, documentKeys));
      }
    }
    final rawNodes = m['nodes'];
    if (rawNodes != null && rawNodes is! Map) {
      r.add(Codes.invalidDocument, '/nodes', '"nodes" is an object of id → node, got ${describe(rawNodes)}.');
    }
    nodesJson = readMap(rawNodes) ?? const {};
    for (final e in nodesJson.entries) {
      final n = Node.fromJson(e.value, id: e.key, catalog: standardCatalog);
      if (n == null) {
        r.add(Codes.invalidNode, pointer('/nodes', e.key),
            e.value is Map ? 'A node needs a "type" (one of the node types, such as "column" or "text").' : 'A node is an object, got ${describe(e.value)}.',
            nodeId: e.key);
      } else {
        nodes[e.key] = n;
      }
    }
    canvases = {for (final n in nodes.values) if (n.type == CanvasProps.spec.type) n.id};
    if (m.containsKey(LayoutDocumentBreakpoints.key)) {
      values.checkDef(
          const PropDef<Object?>('breakpoints', Breakpoints.codec, []), m[LayoutDocumentBreakpoints.key], '/breakpoints');
      breakpoints = Breakpoints.fromJson(m[LayoutDocumentBreakpoints.key]);
    } else if (options.breakpoints != null) {
      breakpoints = options.breakpoints!;
    }

    // Roots.
    final rawRoots = m['roots'];
    if (rawRoots is! List) {
      r.add(rawRoots == null ? Codes.noRoots : Codes.invalidDocument, '/roots',
          rawRoots == null ? 'Add "roots": the canvas ids, in order.' : '"roots" is a list of canvas ids, got ${describe(rawRoots)}.');
    }
    final roots = <String>[];
    if (rawRoots is List) {
      if (rawRoots.isEmpty) r.add(Codes.noRoots, '/roots', 'No roots: list the canvas ids.');
      for (var i = 0; i < rawRoots.length; i++) {
        final id = rawRoots[i];
        if (id is! String) {
          r.add(Codes.wrongType, pointer('/roots', i), 'A root is a node id (text), got ${describe(id)}.');
        } else if (!nodes.containsKey(id)) {
          r.add(Codes.danglingRoot, pointer('/roots', i), 'Root "$id" names no node.',
              suggestion: nearest(id, nodes.keys), nodeId: id);
        } else {
          roots.add(id);
          if (nodes[id]!.type != CanvasProps.spec.type) {
            r.add(Codes.rootNotCanvas, pointer('/roots', i), 'Root "$id" is a ${nodes[id]!.type}: only canvases show as screens.', nodeId: id);
          }
        }
      }
    }

    _variables(m);
    _tree(roots);
    for (final e in nodesJson.entries) {
      final n = nodes[e.key];
      if (n == null) continue;
      r.node = e.key;
      currentCanvas = canvasOf[e.key];
      _node(n, readMap(e.value)!, pointer('/nodes', e.key));
    }
    r.node = null;
    _breakpoints();
    _conditions(m);
    _scripts(m);
  }

  // --- variables -------------------------------------------------------------

  void _variables(Json m) {
    final raw = m[LayoutLogic.variablesKey];
    if (raw == null) return;
    final scopes = readMap(raw);
    if (scopes == null) {
      r.add(Codes.invalidVariable, '/variables', '"variables" is an object: canvas id (or "$pageVariablesScope") → a list of variables.');
      return;
    }
    for (final e in scopes.entries) {
      final at = pointer('/variables', e.key);
      if (e.key != pageVariablesScope && !canvases.contains(e.key)) {
        r.add(Codes.unknownScope, at,
            'Variables are keyed by a canvas id of this document or "$pageVariablesScope"; "${e.key}" is neither.',
            suggestion: nearest(e.key, [...canvases, pageVariablesScope]));
      }
      final list = e.value;
      if (list is! List) {
        r.add(Codes.invalidVariable, at, 'A scope\'s variables are a list, got ${describe(list)}.');
        continue;
      }
      final names = variablesOf.putIfAbsent(e.key, () => {});
      for (var i = 0; i < list.length; i++) {
        final p = pointer(at, i);
        final v = readMap(list[i]);
        if (v == null) {
          r.add(Codes.invalidVariable, p, 'A variable is an object {"name", "type", "value"}, got ${describe(list[i])}.');
          continue;
        }
        final name = v['name'];
        if (name is! String || name.isEmpty) {
          r.add(Codes.invalidVariable, p, 'A variable needs a "name".');
          continue;
        }
        if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(name)) {
          r.add(Codes.invalidVariable, pointer(p, 'name'), '"$name" is not a name expressions can read: use letters, digits and _, not starting with a digit.');
        }
        if (!names.add(name)) r.add(Codes.duplicateVariable, pointer(p, 'name'), 'Variable "$name" is declared twice in "${e.key}".');
        const known = {'id', 'name', 'type', 'value', 'formula', 'parameters', 'options', 'persist'};
        for (final k in v.keys) {
          if (!known.contains(k)) {
            r.add(Codes.unknownField, pointer(p, k), 'A variable has no "$k". It takes: ${known.join(', ')}.', suggestion: nearest(k, known));
          }
        }
        final typeName = v['type'] ?? 'text';
        final type = VariableType.values.where((t) => t.name == typeName).firstOrNull;
        if (type == null) {
          r.add(Codes.invalidEnum, pointer(p, 'type'),
              '${describe(typeName)} is not a variable type. Allowed: ${VariableType.values.map((t) => t.name).join(', ')}.',
              suggestion: typeName is String ? nearest(typeName, VariableType.values.map((t) => t.name)) : null);
        } else if (v.containsKey('value') && v['value'] != null && type.coerce(v['value']) == null) {
          r.add(Codes.invalidVariable, pointer(p, 'value'), 'A ${type.name} variable cannot hold ${describe(v['value'])}.');
        } else if (v['value'] is String && type != VariableType.text && type != VariableType.image &&
            type != VariableType.choice && type != VariableType.color) {
          r.add(Codes.looseValue, pointer(p, 'value'), 'A ${type.name} variable\'s value is written as JSON (${type == VariableType.boolean ? 'true' : type == VariableType.list ? '[...]' : type == VariableType.map ? '{...}' : '3'}), not as text.');
        }
        if (v['formula'] != null && v['formula'] is! String) {
          r.add(Codes.wrongType, pointer(p, 'formula'), 'A formula is text (what goes inside \${= ...}).');
        }
      }
    }
    pageVariables = variablesOf[pageVariablesScope] ?? {};
  }

  Set<String> _declared(String? canvas) => {
        ...pageVariables,
        ...?variablesOf[canvas],
        ...options.variables,
        for (final v in variablesOf.values) ...v, // (reported per scope below when misplaced)
      };

  // --- tree --------------------------------------------------------------------

  void _tree(List<String> roots) {
    final parents = <String, List<String>>{};
    for (final n in nodes.values) {
      final at = pointer('/nodes', n.id);
      final raw = readMap(nodesJson[n.id])!;
      final spec = n.spec;
      final children = raw['children'];
      if (children != null) {
        if (children is! List) {
          r.add(Codes.wrongType, pointer(at, 'children'), '"children" is a list of node ids, got ${describe(children)}.', nodeId: n.id);
        } else {
          if (spec != null && spec.children != ChildModel.list && children.isNotEmpty) {
            r.add(Codes.childrenNotAllowed, pointer(at, 'children'),
                spec.children == ChildModel.slots
                    ? 'A ${n.type} takes no "children": it takes slots (${spec.slots.join(', ')}). Put the child under "slots", e.g. {"${spec.slots.first}": "<id>"}.'
                    : 'A ${n.type} takes no children. Wrap it and its neighbours in a row, column or stack instead.',
                nodeId: n.id);
          }
          for (var i = 0; i < children.length; i++) {
            final c = children[i];
            if (c is! String) {
              r.add(Codes.wrongType, pointer(pointer(at, 'children'), i), 'A child is a node id (text), got ${describe(c)}.', nodeId: n.id);
            } else if (!nodes.containsKey(c)) {
              r.add(Codes.danglingChild, pointer(pointer(at, 'children'), i), 'Child "$c" names no node.',
                  suggestion: nearest(c, nodes.keys), nodeId: n.id);
            } else {
              (parents[c] ??= []).add(n.id);
            }
          }
        }
      }
      final slots = raw['slots'];
      if (slots != null) {
        if (slots is! Map) {
          r.add(Codes.wrongType, pointer(at, 'slots'), '"slots" is an object of slot name → node id, got ${describe(slots)}.', nodeId: n.id);
        } else {
          if (spec != null && spec.slots.isEmpty && slots.isNotEmpty) {
            r.add(Codes.slotsNotAllowed, pointer(at, 'slots'),
                'A ${n.type} has no slots.${spec.children == ChildModel.list ? ' Use "children": [...].' : ''}', nodeId: n.id);
          }
          for (final e in slots.entries) {
            final p = pointer(pointer(at, 'slots'), '${e.key}');
            if (spec != null && spec.slots.isNotEmpty && !spec.slots.contains(e.key)) {
              r.add(Codes.unknownSlot, p, 'A ${n.type} has no slot "${e.key}". Its slots: ${spec.slots.join(', ')}.',
                  suggestion: nearest('${e.key}', spec.slots), nodeId: n.id);
            }
            final c = e.value;
            if (c is! String) {
              r.add(Codes.wrongType, p, 'A slot holds a node id (text), got ${describe(c)}.', nodeId: n.id);
            } else if (!nodes.containsKey(c)) {
              r.add(Codes.danglingSlot, p, 'Slot "${e.key}" names no node "$c".', suggestion: nearest(c, nodes.keys), nodeId: n.id);
            } else {
              (parents[c] ??= []).add(n.id);
            }
          }
        }
      }
      // A variance's variants name children too.
      if (n.type == VarianceProps.spec.type) {
        for (final v in n.prop(VarianceProps.variants)) {
          for (final c in readStrings(v['children'])) {
            if (!nodes.containsKey(c)) {
              r.add(Codes.danglingChild, pointer(at, 'props/variants'), 'Variant "${v['id']}" names no node "$c".', nodeId: n.id);
            } else if (!n.children.contains(c)) {
              (parents[c] ??= []).add(n.id);
            }
          }
        }
      }
    }
    for (final e in parents.entries) {
      if (e.value.length > 1) {
        r.add(Codes.multipleParents, pointer('/nodes', e.key),
            'Node "${e.key}" is a child of ${e.value.map((p) => '"$p"').join(' and ')}: a node has one parent. Give each copy its own id.',
            nodeId: e.key);
      }
      if (canvases.contains(e.key)) {
        r.add(Codes.canvasAsChild, pointer('/nodes', e.key), 'Canvas "${e.key}" is a child of "${e.value.first}": canvases are only roots.', nodeId: e.key);
      }
    }
    // Cycles and reachability.
    final reached = <String>{};
    final onPath = <String>{};
    final reported = <String>{};
    void visit(String id, String canvas) {
      if (onPath.contains(id)) {
        if (reported.add(id)) r.add(Codes.cycle, pointer('/nodes', id), 'Node "$id" contains itself.', nodeId: id);
        return;
      }
      if (!reached.add(id)) return;
      canvasOf[id] = canvas;
      onPath.add(id);
      for (final c in nodes[id]!.childIds) {
        if (nodes.containsKey(c)) visit(c, canvas);
      }
      onPath.remove(id);
    }

    for (final root in roots) {
      visit(root, root);
    }
    // Ids interaction states patch are reachable through them.
    final unreached = [for (final id in nodes.keys) if (!reached.contains(id)) id];
    for (final id in unreached) {
      // Report the top of each unreached subtree only.
      final ps = parents[id];
      if (ps != null && ps.any((p) => !reached.contains(p))) continue;
      // A cycle with no entry point.
      if (ps == null || ps.isEmpty) {
        r.add(Codes.unreachableNode, pointer('/nodes', id),
            'Node "$id" is not under any root (nothing lists it as a child or slot), so it is never shown.', nodeId: id);
      }
      final stack = [id];
      while (stack.isNotEmpty) {
        final x = stack.removeLast();
        if (!reached.add(x)) continue;
        stack.addAll(nodes[x]!.childIds.where(nodes.containsKey));
      }
    }
    this.parents = {for (final e in parents.entries) e.key: e.value.first};
  }

  Map<String, String> parents = {};

  // --- one node ------------------------------------------------------------

  void _node(Node n, Json raw, String at) {
    final spec = n.spec;
    if (spec == null) {
      r.add(Codes.unknownNodeType, pointer(at, 'type'),
          '"${n.type}" is not a node type. Types: ${listOf(Widgets.all.map((s) => s.type))}.',
          suggestion: nearest(n.type, Widgets.all.map((s) => s.type)));
    }
    // Keys a node doesn't read are kept in extra.
    final nodeKeys = <String>{
      'id', 'type', 'name', 'key', 'children', 'slots', 'visible', 'opacity', 'layout', 'decoration', 'props', 'bind', //
      'actions', 'component', 'media', ...Behaviors.keys,
    };
    for (final k in n.extra.keys) {
      if (n.type == CanvasProps.spec.type && canvasRouteKeys.contains(k)) continue;
      r.add(Codes.unknownNodeKey, pointer(at, k), _unknownNodeKeyMessage(k, spec),
          suggestion: _whereKeyBelongs(k, spec) ?? nearest(k, nodeKeys));
    }
    for (final k in const ['name', 'key']) {
      if (raw[k] != null && raw[k] is! String) r.add(Codes.wrongType, pointer(at, k), '"$k" is text, got ${describe(raw[k])}.');
    }
    if (raw['id'] != null && raw['id'] != n.id) {
      r.add(Codes.wrongType, pointer(at, 'id'), 'The node\'s id is its key in "nodes" ("${n.id}"); "id": ${describe(raw['id'])} is ignored. Leave it out.');
    }
    for (final f in NodeFields.all) {
      if (raw.containsKey(f.key)) values.checkDef(f, raw[f.key], pointer(at, f.key));
    }
    if (n.type == CanvasProps.spec.type && raw['path'] != null && raw['path'] is! String) {
      r.add(Codes.wrongType, pointer(at, 'path'), 'A canvas "path" is its URL path, as text ("contact").');
    }
    _layout(n, raw['layout'], pointer(at, 'layout'));
    _decoration(n, raw['decoration'], pointer(at, 'decoration'));
    _props(n, raw['props'], pointer(at, 'props'));
    _bind(n, raw['bind'], pointer(at, 'bind'));
    _reactions(n, raw['actions'], pointer(at, 'actions'));
    if (raw.containsKey('media')) _media(n, raw['media'], pointer(at, 'media'));
    for (final def in BehaviorFields.all) {
      if (!raw.containsKey(def.key)) continue;
      if (def.key == BehaviorFields.states.key) {
        _states(n, raw[def.key], pointer(at, def.key));
      } else {
        values.checkDef(def, raw[def.key], pointer(at, def.key));
        _strings(raw[def.key], pointer(at, def.key));
      }
    }
  }

  String _unknownNodeKeyMessage(String k, WidgetSpec? spec) {
    final where = _whereKeyBelongs(k, spec);
    if (where != null) return 'A node has no "$k"; it belongs in "$where".';
    return 'A node has no "$k". Node keys: type, name, children, slots, visible, opacity, layout, decoration, props, bind, actions, and the behaviors ${Behaviors.keys.join(', ')}.';
  }

  /// Where a misplaced key goes: `props.text`, `layout.width`...
  String? _whereKeyBelongs(String k, WidgetSpec? spec) {
    if (spec?.prop(k) != null) return 'props.$k';
    if (LayoutFields.all.any((f) => f.key == k)) return 'layout.$k';
    if (DecorationFields.all.any((f) => f.key == k)) return 'decoration.$k';
    if (k == 'trigger' || k == 'reactions') return 'actions';
    return null;
  }

  void _layout(Node n, Object? json, String at) {
    if (json == null) {
      _sizes(n, null, at);
      return;
    }
    if (json is! Map) {
      r.add(Codes.wrongType, at, '"layout" is an object, got ${describe(json)}.');
      return;
    }
    final m = readMap(json)!;
    _layoutKeys(n, m, at);
    _sizes(n, m, at);
  }

  /// The keys of layout object [m]: known, of the right type, read by the
  /// parent.
  void _layoutKeys(Node n, Json m, String at) {
    final fields = {for (final f in LayoutFields.all) f.key: f};
    for (final e in m.entries) {
      final f = fields[e.key];
      final p = pointer(at, e.key);
      if (f == null) {
        if (readsKey(_layoutCodec, m, e.key)) {
          if (readDouble(e.value) == null) r.add(Codes.wrongType, p, 'Expected a number, got ${describe(e.value)}.');
          continue;
        }
        r.add(Codes.unknownLayoutKey, p, 'layout has no "${e.key}". It takes: ${fields.keys.join(', ')}, widthFactor, heightFactor.',
            suggestion: nearest(e.key, [...fields.keys, 'widthFactor', 'heightFactor']) ??
                (n.spec?.prop(e.key) != null ? 'props.${e.key}' : null));
        continue;
      }
      if (f.key == 'flex' && e.value is num && (e.value as num) < 1) {
        r.add(Codes.outOfRange, p, 'flex is a share of the free space, 1 or more.');
        continue;
      }
      values.checkDef(f, e.value, p);
    }
    // Which parent reads the placement fields.
    final parentId = parents[n.id];
    final parent = parentId == null ? null : nodes[parentId];
    final reads = {for (final f in parent?.spec?.childFields ?? const <PropDef<Object?>>[]) f.key};
    if (m.containsKey('basis') && parent != null && reads.contains('basis') && !parent.props.get(FlexProps.wrap)) {
      r.add(Codes.layoutFieldIgnored, pointer(at, 'basis'),
          'layout.basis (CSS flex-basis) is read only when the parent ${parent.type} wraps ("wrap": true); in a ${parent.type} that does not wrap, size the child with width/height and flex.');
    }
    for (final f in LayoutFields.parentData) {
      if (!m.containsKey(f.key) || reads.contains(f.key)) continue;
      final what = parent == null ? 'a root' : 'a child of a ${parent.type}';
      final readers = switch (f.key) {
        'x' || 'y' => 'a stack (or variance)',
        _ => 'a row, column or flex',
      };
      r.add(Codes.layoutFieldIgnored, pointer(at, f.key),
          'layout.${f.key} is read only by $readers; this node is $what, so it is ignored.');
    }
  }

  /// A node's media rules: at least one condition each (px or breakpoint
  /// names the project has); a patch of the node's own fields, checked as
  /// those fields are.
  void _media(Node n, Object? json, String at) {
    final list = readList(json);
    const example = '[{"maxWidth": 599, "patch": {"props": {"direction": "vertical"}}}]';
    if (list == null) {
      r.add(Codes.invalidMedia, at, '"media" is a list of rules like CSS media queries, e.g. $example; got ${describe(json)}.');
      return;
    }
    final names = [for (final b in breakpoints.list) b.key.isEmpty ? b.id : b.key];
    for (var i = 0; i < list.length; i++) {
      final p = pointer(at, i);
      final m = readMap(list[i]);
      if (m == null) {
        r.add(Codes.invalidMedia, p, 'A media rule is an object {"minWidth"|"maxWidth"|"orientation": ..., "patch": {...}}, got ${describe(list[i])}.');
        continue;
      }
      for (final k in m.keys) {
        if (k == 'patch' || MediaRule.conditionKeys.contains(k)) continue;
        r.add(Codes.invalidMedia, pointer(p, k),
            'A media rule has no "$k". It takes minWidth, maxWidth (px or a breakpoint name: ${names.join(', ')}), orientation (portrait, landscape) and patch.',
            suggestion: nearest(k, [...MediaRule.conditionKeys, 'patch']) ?? switch (k) {
              'largerThan' || 'min' || 'from' => 'minWidth',
              'smallerThan' || 'max' || 'below' => 'maxWidth',
              _ => null,
            });
      }
      if (!m.keys.any(MediaRule.conditionKeys.contains)) {
        r.add(Codes.invalidMedia, p, 'No condition: add minWidth and/or maxWidth (px, or a breakpoint name: ${names.join(', ')}), or orientation.');
      }
      for (final k in const ['minWidth', 'maxWidth']) {
        if (!m.containsKey(k)) continue;
        final v = m[k];
        if (v is num) {
          if (v < 0) r.add(Codes.invalidMedia, pointer(p, k), '"$k" is a width of 0 or more, got $v.');
        } else if (v is String) {
          if (breakpoints.find(v) == null) {
            r.add(Codes.unknownBreakpoint, pointer(p, k), '"$v" is not a breakpoint of the project. Breakpoints: ${names.join(', ')}; or give a width in px.',
                suggestion: nearest(v, names));
          }
        } else {
          r.add(Codes.invalidMedia, pointer(p, k), '"$k" is a width in px (600) or a breakpoint name ("tablet"), got ${describe(v)}.');
        }
      }
      if (m.containsKey('orientation') && m['orientation'] != 'portrait' && m['orientation'] != 'landscape') {
        r.add(Codes.invalidMedia, pointer(p, 'orientation'), '"orientation" is "portrait" or "landscape", got ${describe(m['orientation'])}.');
      }
      final rule = MediaRule.fromJson(m)!;
      final lo = rule.lowest(breakpoints), hi = rule.below(breakpoints);
      if (lo != null && hi != null && (rule.maxWidth is num ? lo > hi : lo >= hi)) {
        r.add(Codes.invalidMedia, p, 'minWidth ${rule.minWidth} is above maxWidth ${rule.maxWidth}: the rule never holds.');
      }
      final patch = m['patch'];
      final pp = pointer(p, 'patch');
      final pm = readMap(patch);
      if (pm == null) {
        r.add(Codes.invalidMedia, pp, 'Add "patch": the node\'s fields at those sizes, shaped like the node ({"props": {...}, "layout": {...}}).');
        continue;
      }
      for (final e in pm.entries) {
        final kp = pointer(pp, e.key);
        switch (e.key) {
          case 'props':
            _props(n, e.value, kp);
          case 'layout':
            if (readMap(e.value) case final Json lm) {
              _layoutKeys(n, lm, kp);
              _sizes(n.patched({'layout': lm}), lm, kp);
            } else {
              r.add(Codes.wrongType, kp, '"layout" is an object, got ${describe(e.value)}.');
            }
          case 'decoration':
            _decoration(n, e.value, kp);
          case 'visible':
            if (e.value is! bool) r.add(Codes.wrongType, kp, '"visible" is true or false, got ${describe(e.value)}.');
          case 'opacity':
            final o = readDouble(e.value);
            if (o == null || o < 0 || o > 1) r.add(Codes.wrongType, kp, '"opacity" is a number from 0 to 1, got ${describe(e.value)}.');
          default:
            r.add(Codes.invalidMedia, kp,
                e.key == 'children'
                    ? 'A media rule does not change "children": to reorder at a size, patch each child\'s layout.order (CSS order) in the child\'s own media rules.'
                    : '"${e.key}" cannot vary by screen size. A patch takes: ${MediaRule.patchKeys.join(', ')}.',
                suggestion: e.key == 'children' ? 'layout.order' : nearest(e.key, MediaRule.patchKeys));
        }
      }
      // A binding of the same field wins over the patch.
      for (final path in _leafPaths(pm, '')) {
        for (final b in n.bind.keys) {
          if (path == b || path.startsWith('$b.') || b.startsWith('$path.')) {
            r.add(Codes.mediaOverridden, pp,
                'The patch sets $path, which "bind" also sets ("$b"): the binding wins at every size. Remove one of them.');
          }
        }
      }
    }
  }

  /// Dotted paths of the leaves of [v] (`props.style.fontSize`).
  static Iterable<String> _leafPaths(Object? v, String at) sync* {
    if (v is Map && v.isNotEmpty) {
      for (final e in v.entries) {
        yield* _leafPaths(e.value, at.isEmpty ? '${e.key}' : '$at.${e.key}');
      }
    } else if (at.isNotEmpty) {
      yield at;
    }
  }

  void _sizes(Node n, Json? m, String at) {
    final parentId = parents[n.id];
    final parent = parentId == null ? null : nodes[parentId];
    final l = n.layout;
    for (final (axis, size) in [('width', l.width), ('height', l.height)]) {
      if (parent != null && m != null && m.containsKey(axis)) {
        var reason = childFitOptions(parent, horizontal: axis == 'width')[size.fit];
        // A filling child with a basis grows to share its line of a wrapping flex.
        final wrapsAlong = parent.props.get(FlexProps.wrap) && (flexAxisOf(parent) == Axis.horizontal) == (axis == 'width');
        if (wrapsAlong && n.layout.basis != null && size.fit == SizeFit.fill) reason = null;
        if (reason != null) {
          r.add(Codes.fitNotAllowed, pointer(at, axis), '${size.fit.name} is not honored here: $reason');
        }
      }
      if (size.isFixed && size.value == 0 && !(m?.containsKey(axis) ?? false) && n.type != 'spacer' && n.type != 'canvas') {
        r.add(Codes.zeroSize, pointer(at, axis),
            'No $axis: a node without "layout.$axis" is fixed at 0 and draws nothing. Give it a size: a number, {"hug": n}, {"fill": n} or {"flexible": n}.');
      }
    }
  }

  void _decoration(Node n, Object? json, String at) {
    if (json == null) return;
    if (json is! Map) {
      r.add(Codes.wrongType, at, '"decoration" is an object, got ${describe(json)}.');
      return;
    }
    final m = readMap(json)!;
    final fields = {for (final f in DecorationFields.all) f.key: f};
    for (final e in m.entries) {
      final f = fields[e.key];
      final p = pointer(at, e.key);
      if (f == null) {
        if (readsKey(_decorationCodec, m, e.key)) continue;
        r.add(Codes.unknownDecorationKey, p, 'decoration has no "${e.key}". It takes: ${fields.keys.join(', ')}.',
            suggestion: nearest(e.key, fields.keys));
        continue;
      }
      values.checkDef(f, e.value, p);
    }
    final spec = n.spec;
    if (spec != null && !spec.decorated) {
      final dropped = [
        for (final k in const ['fills', 'strokes', 'foregroundFills', 'radius'])
          if (m[k] is List ? (m[k] as List).isNotEmpty : m[k] != null) k,
        if ((readList(m['effects']) ?? const []).any((e) => readMap(e)?['type'] is String && '${readMap(e)!['type']}'.contains('Shadow')))
          'shadow effects',
      ];
      if (dropped.isNotEmpty) {
        r.add(Codes.decorationIgnored, at,
            'A ${n.type} has no box decoration: ${dropped.join(', ')} ${dropped.length == 1 ? 'is' : 'are'} ignored (only blur effects apply). Put it in a box/row/column/stack with the decoration, or use the type\'s own style props.');
      }
    }
    if (m['strokes'] == null && (m.containsKey('strokeWidth') || m.containsKey('strokeAlign'))) {
      r.add(Codes.decorationIgnored, at, 'strokeWidth/strokeAlign without "strokes" draw nothing: add "strokes": [{"color": "#FF..."}].');
    }
  }

  void _props(Node n, Object? json, String at) {
    if (json == null) return;
    if (json is! Map) {
      r.add(Codes.wrongType, at, '"props" is an object, got ${describe(json)}.');
      return;
    }
    final spec = n.spec;
    if (spec == null) return;
    final m = readMap(json)!;
    for (final e in m.entries) {
      final def = spec.prop(e.key);
      final p = pointer(at, e.key);
      if (def == null) {
        final where = LayoutFields.all.any((f) => f.key == e.key)
            ? 'layout.${e.key}'
            : DecorationFields.all.any((f) => f.key == e.key)
                ? 'decoration.${e.key}'
                : null;
        r.add(Codes.unknownProp, p,
            'A ${n.type} has no prop "${e.key}"${where == null ? '' : ' (it is $where)'}. Its props: ${spec.props.isEmpty ? '(none)' : listOf(spec.props.map((d) => d.key))}.',
            suggestion: nearest(e.key, spec.props.map((d) => d.key)) ?? where);
        continue;
      }
      values.checkDef(def, e.value, p);
      _strings(e.value, p);
    }
  }

  void _bind(Node n, Object? json, String at) {
    if (json == null) return;
    final m = readMap(json);
    if (m == null) {
      r.add(Codes.wrongType, at, '"bind" is an object of binding path → expression, got ${describe(json)}.');
      return;
    }
    for (final e in m.entries) {
      final p = pointer(at, e.key);
      final problem = bindPathProblem(e.key, n.spec, n.type);
      if (problem != null) {
        r.add(problem.reserved ? Codes.reservedBindPath : Codes.unknownBindPath, p, problem.message, suggestion: problem.suggestion);
      }
      if (e.value is! String) {
        r.add(Codes.wrongType, p, 'A binding is an expression text ("\${name}" or "\${= formula}"), got ${describe(e.value)}.');
        continue;
      }
      final s = e.value as String;
      if (!s.contains(r'${')) {
        r.add(Codes.wrongType, p, 'A binding holds an expression ("\${name}" or "\${= formula}"); "$s" has none. For a constant, set the field itself.');
      }
      _expression(s, p);
    }
  }

  // --- reactions and actions ----------------------------------------------

  void _reactions(Node n, Object? json, String at) {
    if (json == null) return;
    if (json is! List) {
      r.add(Codes.invalidReaction, at, '"actions" is a list of reactions {"trigger": {...}, "actions": [...]}, got ${describe(json)}.');
      return;
    }
    for (var i = 0; i < json.length; i++) {
      final p = pointer(at, i);
      final m = readMap(json[i]);
      if (m == null) {
        r.add(Codes.invalidReaction, p, 'A reaction is an object {"trigger": {"type": "click"}, "actions": [...]}.');
        continue;
      }
      if (!m.containsKey('trigger') && m['type'] is String) {
        r.add(Codes.invalidReaction, p,
            'This is an action, not a reaction: wrap it as {"trigger": {"type": "click"}, "actions": [${'{"type": "${m['type']}", ...}'}]}.');
        continue;
      }
      for (final k in m.keys) {
        if (!const {'id', 'name', 'trigger', 'actions'}.contains(k)) {
          r.add(Codes.unknownField, pointer(p, k), 'A reaction has no "$k". It takes: id, name, trigger, actions.',
              suggestion: nearest(k, const ['id', 'name', 'trigger', 'actions']));
        }
      }
      _trigger(m['trigger'], pointer(p, 'trigger'));
      _chain(m['actions'], pointer(p, 'actions'));
    }
  }

  void _trigger(Object? json, String at) {
    final types = TriggerType.values.map((t) => t.name);
    if (json is String) {
      if (!types.contains(json)) {
        r.add(Codes.unknownTrigger, at, '"$json" is not a trigger type: the reaction is dropped. Types: ${listOf(types)}.',
            suggestion: nearest(json, types));
      }
      return;
    }
    final m = readMap(json);
    if (m == null) {
      r.add(Codes.unknownTrigger, at, 'A reaction needs a trigger: {"type": "click"} (or another trigger type).');
      return;
    }
    final type = m['type'];
    if (type is! String || !types.contains(type)) {
      r.add(Codes.unknownTrigger, pointer(at, 'type'),
          '${describe(type)} is not a trigger type: the reaction is dropped. Types: ${listOf(types)}.',
          suggestion: type is String ? nearest(type, types) : null);
    }
    final fields = {for (final f in TriggerFields.all) f.key: f};
    for (final e in m.entries) {
      final f = fields[e.key];
      if (f == null) {
        r.add(Codes.unknownTriggerKey, pointer(at, e.key), 'A trigger has no "${e.key}". It takes: ${fields.keys.join(', ')}.',
            suggestion: nearest(e.key, fields.keys));
        continue;
      }
      if (f.key != 'type') values.checkDef(f, e.value, pointer(at, e.key));
    }
    if (type == 'valueChanged') {
      final v = m['variable'];
      if (v is! String || v.isEmpty) {
        r.add(Codes.unknownVariable, pointer(at, 'variable'), 'A valueChanged trigger names the variable it watches: "variable": "<name>".');
      } else {
        _variableRef(v, pointer(at, 'variable'));
      }
    }
    for (final k in const ['when', 'runWhen', 'onceKey']) {
      if (m[k] is String) _expression(m[k] as String, pointer(at, k), bareFormula: k != 'onceKey');
    }
  }

  void _chain(Object? json, String at) {
    if (json == null) return;
    if (json is! List) {
      r.add(Codes.invalidReaction, at, 'An action chain is a list of actions, got ${describe(json)}.');
      return;
    }
    for (var i = 0; i < json.length; i++) {
      _action(json[i], pointer(at, i));
    }
  }

  void _action(Object? json, String at) {
    final m = readMap(json);
    if (m == null) {
      r.add(Codes.invalidReaction, at, 'An action is an object {"type": ..., ...}, got ${describe(json)}.');
      return;
    }
    final type = m['type'];
    final spec = type is String ? ActionSpecs.of(type) : null;
    if (spec == null) {
      final types = ActionSpecs.all.map((s) => s.type);
      r.add(Codes.unknownActionType, pointer(at, 'type'),
          '${describe(type)} is not an action type: the runtime skips it. Types: ${listOf(types)}.',
          suggestion: type is String ? nearest(type, types) : null);
      for (final k in nestedChainKeys) {
        if (m[k] is List) _chain(m[k], pointer(at, k));
      }
      return;
    }
    final fields = {for (final f in spec.fields) f.key: f, for (final f in ActionCommonFields.all) f.key: f};
    final read = {...?ActionDef.fromJson(m, catalog: standardCatalog)?.toJson().keys};
    for (final e in m.entries) {
      final p = pointer(at, e.key);
      if (e.key == 'type' || e.key == 'id') continue;
      final f = fields[e.key];
      if (f == null) {
        if (read.contains(e.key)) continue;
        r.add(Codes.unknownActionKey, p,
            'A ${spec.type} action has no "${e.key}". It takes: ${spec.fields.map((f) => f.key).join(', ')} (and enabled, nonBlocking, when).',
            suggestion: nearest(e.key, fields.keys));
        continue;
      }
      if (nestedChainKeys.contains(e.key) && (e.value is List || e.value == null)) {
        _chain(e.value, p);
        continue;
      }
      if (f.key == 'when' || (spec.type == 'if' && f.key == 'condition')) {
        _predicate(e.value, p);
        continue;
      }
      values.checkDef(f, e.value, p);
      _strings(e.value, p);
    }
    _actionRefs(spec.type, m, at);
  }

  void _actionRefs(String type, Json m, String at) {
    // Node targets.
    final node = m['node'];
    if (node is String && node.isNotEmpty && !node.contains(r'${') && !nodes.containsKey(node)) {
      r.add(Codes.unknownTargetNode, pointer(at, 'node'), 'No node "$node" in this document.', suggestion: nearest(node, nodes.keys));
    }
    final anchor = m['anchorNode'];
    if (anchor is String && anchor.isNotEmpty && !anchor.contains(r'${') && !nodes.containsKey(anchor)) {
      r.add(Codes.unknownTargetNode, pointer(at, 'anchorNode'), 'No node "$anchor" in this document.', suggestion: nearest(anchor, nodes.keys));
    }
    if (type == 'navigate' || type == 'openModal') {
      final to = m['to'];
      final mode = m['mode'];
      final needs = type == 'openModal' || (mode != 'pop');
      if (to is String && to.isNotEmpty && !to.contains(r'${')) {
        final known = {...canvases, ...options.screens};
        if (!known.contains(to)) {
          r.add(Codes.unknownScreen, pointer(at, 'to'),
              'No screen "$to": "to" is a canvas id (of this or another document of the project). Canvases: ${known.join(', ')}.',
              suggestion: nearest(to, known));
        }
      } else if (needs && (to == null || to == '')) {
        r.add(Codes.unknownScreen, pointer(at, 'to'), 'A $type${type == 'navigate' ? ' ${mode ?? 'push'}' : ''} needs "to": the canvas id it shows.');
      }
    }
    if (type == 'setVariable' || type == 'animateVariable') {
      final v = m['variable'];
      if (v is String && v.isNotEmpty) {
        _variableRef(v, pointer(at, 'variable'));
      } else {
        r.add(Codes.unknownVariable, pointer(at, 'variable'), 'A $type names its variable: "variable": "<name>".');
      }
    }
    if (type == 'setValue' && m['values'] is List) {
      final target = nodes[m['node']];
      final list = m['values'] as List;
      for (var i = 0; i < list.length; i++) {
        final v = readMap(list[i]);
        final path = v?['path'];
        if (target != null && path is String) {
          final problem = bindPathProblem(path, target.spec, target.type);
          if (problem != null) {
            r.add(Codes.unknownBindPath, pointer(pointer(pointer(at, 'values'), i), 'path'), problem.message, suggestion: problem.suggestion);
          }
        }
      }
    }
  }

  void _variableRef(String v, String at) {
    final root = rootName(v);
    if (root == null) return;
    final declared = _declared(currentCanvas);
    if (!declared.contains(root)) {
      r.add(Codes.unknownVariable, at,
          'No variable "$root" is declared${currentCanvas == null ? '' : ' for canvas "$currentCanvas"'} (declare it under "variables": {"$pageVariablesScope" or "<canvas id>": [{"name": "$root", "type": ..., "value": ...}]}).',
          suggestion: nearest(root, declared));
    }
  }

  void _predicate(Object? json, String at) {
    if (json == null) return;
    final m = readMap(json);
    if (m == null) {
      if (json is String) {
        r.add(Codes.invalidCondition, at,
            'A predicate is an object: {"left": "\${x}", "op": "equalsTo", "right": "1"} or {"and"|"or": [...]}, not text.');
      } else {
        r.add(Codes.invalidCondition, at, 'A predicate is an object, got ${describe(json)}.');
      }
      return;
    }
    for (final j in Join.values) {
      if (m.containsKey(j.name)) {
        final parts = m[j.name];
        if (parts is! List) {
          r.add(Codes.invalidCondition, pointer(at, j.name), '"${j.name}" takes a list of predicates.');
          return;
        }
        for (var i = 0; i < parts.length; i++) {
          _predicate(parts[i], pointer(pointer(at, j.name), i));
        }
        return;
      }
    }
    const keys = {'left', 'op', 'right'};
    for (final k in m.keys) {
      if (!keys.contains(k)) {
        r.add(Codes.invalidCondition, pointer(at, k), 'A comparison has no "$k". It takes: left, op, right (or "and"/"or": [...]).',
            suggestion: nearest(k, [...keys, 'and', 'or']));
      }
    }
    if (!m.containsKey('left')) r.add(Codes.invalidCondition, at, 'A comparison needs "left".');
    final op = m['op'] ?? 'equalsTo';
    final ops = ConditionOp.values.map((o) => o.name);
    if (op is! String || !ops.contains(op)) {
      r.add(Codes.invalidEnum, pointer(at, 'op'), '${describe(op)} is not a condition op. Allowed: ${ops.join(', ')}.',
          suggestion: op is String ? nearest(op, ops) : null);
    }
    for (final k in const ['left', 'right']) {
      final v = m[k];
      if (v is String) {
        _expression(v, pointer(at, k));
      } else if (v is Map && !v.containsKey('raw')) {
        r.add(Codes.invalidCondition, pointer(at, k), 'An operand is text (an expression), a number, a boolean or {"raw": text}.');
      }
    }
  }

  // --- interaction states ---------------------------------------------------

  void _states(Node n, Object? json, String at) {
    final m = readMap(json);
    if (m == null) {
      r.add(Codes.wrongType, at, '"states" is an object: state → {node id → patch}, got ${describe(json)}.');
      return;
    }
    final states = WidgetState.values.map((s) => s.name);
    for (final e in m.entries) {
      final p = pointer(at, e.key);
      if (!states.contains(e.key)) {
        r.add(Codes.unknownField, p, '"${e.key}" is not an interaction state. States: ${states.join(', ')}.', suggestion: nearest(e.key, states));
        continue;
      }
      final targets = readMap(e.value);
      if (targets == null) {
        r.add(Codes.wrongType, p, 'A state maps node ids to patches: {"<node id>": {"decoration": {...}}}.');
        continue;
      }
      for (final t in targets.entries) {
        final tp = pointer(p, t.key);
        final target = nodes[t.key];
        if (target == null) {
          r.add(Codes.unknownTargetNode, tp, 'No node "${t.key}" to patch.', suggestion: nearest(t.key, nodes.keys));
          continue;
        }
        if (t.key != n.id && !_isDescendant(t.key, n.id)) {
          r.add(Codes.unknownTargetNode, tp,
              'A state patches the node itself or nodes inside it; "${t.key}" is not inside "${n.id}".');
        }
        final patch = readMap(t.value);
        if (patch == null) {
          r.add(Codes.wrongType, tp, 'A patch is an object (a JSON merge patch of the node), got ${describe(t.value)}.');
          continue;
        }
        // Check the patched node, reporting only what the patch sets.
        final base = {...readMap(nodesJson[t.key])!};
        // The target's own states and reactions are checked where it is.
        if (!patch.containsKey('states')) base.remove('states');
        if (!patch.containsKey('actions')) base.remove('actions');
        final merged = mergePatch(base, patch);
        final sub = Reporter()..node = n.id;
        final v = _Validator(sub, options)
          ..nodes = nodes
          ..nodesJson = nodesJson
          ..canvases = canvases
          ..parents = parents
          ..pageVariables = pageVariables
          ..currentCanvas = currentCanvas;
        v.variablesOf.addAll(variablesOf);
        final pn = Node.fromJson(merged, id: t.key, catalog: standardCatalog);
        if (pn != null) v._node(pn, merged, '');
        final set = _leafPointers(patch, '');
        for (final d in sub.out) {
          if (d.code == Codes.zeroSize || d.code == Codes.layoutFieldIgnored) continue;
          if (!set.any((s) => d.path.startsWith(s) || s.startsWith(d.path))) continue;
          r.add(d.code, '$tp${d.path}', d.message, suggestion: d.suggestion);
        }
      }
    }
  }

  bool _isDescendant(String id, String ancestor) {
    var p = parents[id];
    while (p != null) {
      if (p == ancestor) return true;
      p = parents[p];
    }
    return false;
  }

  Set<String> _leafPointers(Object? v, String at) {
    final m = readMap(v);
    if (m == null || m.isEmpty) return {at};
    return {for (final e in m.entries) ..._leafPointers(e.value, pointer(at, e.key))};
  }

  // --- conditions, breakpoints, scripts ------------------------------------

  void _conditions(Json m) {
    final raw = m[LayoutLogic.conditionsKey];
    if (raw == null) return;
    final scopes = readMap(raw);
    if (scopes == null) {
      r.add(Codes.invalidCondition, '/conditions', '"conditions" is an object: canvas id → a list of conditions.');
      return;
    }
    for (final e in scopes.entries) {
      final at = pointer('/conditions', e.key);
      currentCanvas = e.key;
      if (!canvases.contains(e.key)) {
        r.add(Codes.unknownScope, at, 'Conditions are keyed by a canvas id of this document; "${e.key}" is not one.',
            suggestion: nearest(e.key, canvases));
      }
      final list = e.value;
      if (list is! List) {
        r.add(Codes.invalidCondition, at, 'A canvas\'s conditions are a list.');
        continue;
      }
      for (var i = 0; i < list.length; i++) {
        final cp = pointer(at, i);
        final c = readMap(list[i]);
        if (c == null) {
          r.add(Codes.invalidCondition, cp, 'A condition is an object {"id", "branches": [...]}.');
          continue;
        }
        for (final k in c.keys) {
          if (!const {'id', 'name', 'branches'}.contains(k)) {
            r.add(Codes.invalidCondition, pointer(cp, k), 'A condition has no "$k". It takes: id, name, branches.');
          }
        }
        final branches = c['branches'];
        if (branches is! List) {
          r.add(Codes.invalidCondition, pointer(cp, 'branches'), 'A condition needs "branches": [{"when": {...}, "set": [...]}, ...].');
          continue;
        }
        for (var b = 0; b < branches.length; b++) {
          final bp = pointer(pointer(cp, 'branches'), b);
          final br = readMap(branches[b]);
          if (br == null) {
            r.add(Codes.invalidCondition, bp, 'A branch is an object {"when": predicate, "set": [...]}.');
            continue;
          }
          for (final k in br.keys) {
            if (!const {'when', 'set'}.contains(k)) {
              r.add(Codes.invalidCondition, pointer(bp, k), 'A branch has no "$k". It takes: when, set.', suggestion: nearest(k, const ['when', 'set']));
            }
          }
          if (br['when'] == null && b < branches.length - 1) {
            r.add(Codes.invalidCondition, bp, 'Only the last branch may omit "when" (it is the else); later branches never run.');
          }
          _predicate(br['when'], pointer(bp, 'when'));
          final set = br['set'];
          if (set is! List) {
            r.add(Codes.invalidCondition, pointer(bp, 'set'), 'A branch needs "set": [{"node", "path", "value"}].');
            continue;
          }
          for (var s = 0; s < set.length; s++) {
            final sp = pointer(pointer(bp, 'set'), s);
            final entry = readMap(set[s]);
            if (entry == null) {
              r.add(Codes.invalidCondition, sp, 'A set entry is {"node": id, "path": binding path, "value": value}.');
              continue;
            }
            for (final k in entry.keys) {
              if (!const {'node', 'path', 'value'}.contains(k)) {
                r.add(Codes.invalidCondition, pointer(sp, k), 'A set entry has no "$k". It takes: node, path, value.',
                    suggestion: nearest(k, const ['node', 'path', 'value']));
              }
            }
            final id = entry['node'];
            final target = id is String ? nodes[id] : null;
            if (target == null) {
              r.add(Codes.unknownTargetNode, pointer(sp, 'node'), 'No node ${describe(id)} in this document.',
                  suggestion: id is String ? nearest(id, nodes.keys) : null);
            } else {
              final path = entry['path'];
              if (path is! String) {
                r.add(Codes.invalidCondition, pointer(sp, 'path'), 'A set entry needs "path": a binding path such as "visible" or "props.text".');
              } else {
                final problem = bindPathProblem(path, target.spec, target.type);
                if (problem != null) {
                  r.add(Codes.unknownBindPath, pointer(sp, 'path'), problem.message, suggestion: problem.suggestion);
                }
              }
            }
            if (entry['value'] is String) _expression(entry['value'] as String, pointer(sp, 'value'));
          }
        }
      }
    }
    currentCanvas = null;
  }

  void _breakpoints() {
    final ids = {for (final b in breakpoints.list) b.id};
    final byScreen = <String, Map<String, String>>{};
    for (final id in canvases) {
      final n = nodes[id]!;
      final at = pointer(pointer('/nodes', id), 'props');
      final bp = n.prop(CanvasProps.breakpoint);
      final screen = n.prop(CanvasProps.screen);
      if (bp.isNotEmpty && !ids.contains(bp)) {
        r.add(Codes.unknownBreakpoint, pointer(at, 'breakpoint'),
            'No breakpoint "$bp". The project\'s breakpoints: ${ids.join(', ')}.', suggestion: nearest(bp, ids), nodeId: id);
      }
      if (screen.isNotEmpty) {
        if (bp.isEmpty) {
          r.add(Codes.screenWithoutBreakpoint, pointer(at, 'breakpoint'),
              'Canvas "$id" is one canvas of screen "$screen" but names no breakpoint: set "breakpoint" to one of ${ids.join(', ')}.',
              nodeId: id);
        } else {
          final other = (byScreen[screen] ??= {})[bp];
          if (other != null) {
            r.add(Codes.duplicateBreakpointCanvas, pointer(at, 'breakpoint'),
                'Canvases "$other" and "$id" of screen "$screen" are both the $bp design.', nodeId: id);
          }
          byScreen[screen]![bp] = id;
        }
      }
    }
    for (final n in nodes.values.where((n) => n.type == VarianceProps.spec.type)) {
      final variants = n.prop(VarianceProps.variants);
      for (var i = 0; i < variants.length; i++) {
        final b = variants[i]['breakpoint'];
        if (b is String && b.isNotEmpty && !ids.contains(b)) {
          r.add(Codes.unknownBreakpoint, pointer(pointer(pointer('/nodes', n.id), 'props/variants'), i),
              'No breakpoint "$b". The project\'s breakpoints: ${ids.join(', ')}.', suggestion: nearest(b, ids), nodeId: n.id);
        }
      }
    }
  }

  void _scripts(Json m) {
    final raw = m[LayoutDocumentScripts.key];
    if (raw == null) return;
    if (raw is! List) {
      r.add(Codes.wrongType, '/scripts', '"scripts" is a list of scripts.');
      return;
    }
    for (var i = 0; i < raw.length; i++) {
      final s = ScriptDef.fromJson(raw[i]);
      if (s == null) {
        r.add(Codes.wrongType, pointer('/scripts', i), 'Not a script: {"name", "source", "params"...}.');
        continue;
      }
      for (final problem in s.validate()) {
        r.add(Codes.wrongType, pointer('/scripts', i), problem.toString());
      }
    }
  }

  // --- expressions ------------------------------------------------------------

  /// Checks the expressions in every string of [json].
  void _strings(Object? json, String at) {
    if (json is String) {
      if (json.contains(r'${')) _expression(json, at);
    } else if (json is List) {
      for (var i = 0; i < json.length; i++) {
        _strings(json[i], pointer(at, i));
      }
    } else if (json is Map) {
      for (final e in json.entries) {
        _strings(e.value, pointer(at, '${e.key}'));
      }
    }
  }

  /// Checks [text]'s `${...}` (or, with [bareFormula], [text] itself as a
  /// formula when it has none).
  void _expression(String text, String at, {bool bareFormula = false}) {
    final scan = scanExpressions(text);
    if (scan.error != null) r.add(Codes.expressionSyntax, at, scan.error!);
    final exprs = [...scan.expressions];
    if (bareFormula && exprs.isEmpty && scan.error == null && text.trim().isNotEmpty) {
      exprs.add((source: text.trim(), formula: true, start: 0));
    }
    final declared = _declared(currentCanvas);
    for (final e in exprs) {
      Iterable<String> roots;
      if (e.formula) {
        final check = options.formulas;
        if (check == null) continue;
        final report = check(e.source);
        if (report.error != null) {
          r.add(Codes.expressionSyntax, at, 'The formula "\${= ${e.source}}" does not parse: ${report.error}.');
          continue;
        }
        roots = report.paths.map(rootName).nonNulls;
      } else {
        roots = [?rootName(e.source)];
      }
      for (final name in roots) {
        if (declared.contains(name) || runtimeScopes.contains(name)) continue;
        r.add(Codes.unknownName, at,
            '"$name" is not a declared variable${currentCanvas == null ? '' : ' of canvas "$currentCanvas"'} nor a runtime scope (${runtimeScopes.join(', ')}).',
            suggestion: nearest(name, [...declared, ...runtimeScopes]));
      }
    }
  }

  /// Free-form JSON whose meaning the validator knows.
  bool _jsonHook(PropDef<Object?>? def, PropType type, Object? json, String path) {
    if (type.name == 'Reaction') {
      _reactions(nodes[r.node] ?? const Node(id: '', type: ''), json, path);
      return true;
    }
    return false;
  }
}
