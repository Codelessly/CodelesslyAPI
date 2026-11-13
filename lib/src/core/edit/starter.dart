// The runtime docs for a model that writes UI with edit ops: a BASE SET, the
// system prompt, plus a LINK TO THE FULL reference, the `ui_docs` tool, one
// topic at a time. Everything is generated from the declarations (node
// types, props, layout, decoration and text style fields, actions,
// behaviors, scripts, ops) and, for feature areas, from the guide's sections
// (guide_topics.g.dart, written by tool/reference/generate.dart from the same
// templates as docs/reference), so the two cannot drift.
//
// Three pieces, reusable for any base-plus-links reference:
// * [runtimeStarter] assembles the base;
// * [docsTopic] renders one topic page, sized for a tool result;
// * [docsIndex] lists the topics, for the base's last section.
import 'dart:convert';

import '../behavior_fields.dart';
import '../catalog.dart';
import '../json.dart';
import '../props.dart';
import '../scripts.dart';
import '../triggers.dart' show TriggerType;
import '../value_fields.dart';
import '../variables.dart' show VariableType;
import 'edit_ops.dart';
import 'guide_topics.g.dart';
import 'trust.dart';

/// The base node types and the props the base shows for each (in this
/// order; a key the type does not declare is skipped): what a chat card or a
/// small screen uses.
const Map<String, List<String>> starterProps = {
  'canvas': [],
  'column': ['mainAxisAlignment', 'crossAxisAlignment', 'spacing', 'scrollable'],
  'row': ['mainAxisAlignment', 'crossAxisAlignment', 'spacing', 'wrap'],
  'stack': [],
  'box': [],
  'text': ['text', 'style', 'textAlign', 'maxLines'],
  'icon': ['icon', 'color', 'size'],
  'divider': ['thickness', 'color'],
  'spacer': [],
  'filledButton': ['label', 'icon', 'style', 'enabled'],
  'elevatedButton': ['label', 'icon', 'style'],
  'outlinedButton': ['label', 'icon', 'style'],
  'textButton': ['label', 'icon', 'style'],
  'iconButton': ['icon', 'style'],
  'textField': ['initialValue', 'decoration', 'keyboardType', 'obscureText', 'maxLines'],
  'checkbox': ['value', 'activeColor'],
  'switch': ['value', 'activeTrackColor'],
  'radio': ['value', 'groupValue', 'activeColor'],
  'slider': ['value', 'min', 'max', 'divisions', 'activeTrackColor'],
  'dropdown': ['items', 'value', 'hint'],
  'segmentedButton': ['segments', 'selected'],
  'listView': ['scrollDirection', 'spacing', 'scrollable'],
  'gridView': ['crossAxisCount', 'mainAxisSpacing', 'crossAxisSpacing', 'childAspectRatio'],
  'progressBar': ['value', 'max', 'color', 'backgroundColor'],
};

/// The layout, decoration and text style keys the base lists.
const List<String> starterLayout = ['width', 'height', 'padding', 'margin', 'flex', 'align', 'x', 'y', 'constraints', 'aspectRatio'];
const List<String> starterDecoration = ['fills', 'strokes', 'strokeWidth', 'radius', 'effects', 'clip'];
const List<String> starterTextStyle = ['fontSize', 'fontWeight', 'color', 'height', 'letterSpacing', 'fontStyle', 'decoration'];

/// Feature areas `ui_docs` serves beyond the guide's sections: behaviors,
/// grouped.
const Map<String, List<String>> behaviorAreas = {
  'animation': ['animations', 'motion', 'transitions', 'shimmer', 'reveal', 'typewriter', 'particles'],
  'gestures': ['pan', 'draggable', 'dropTarget', 'dismissible', 'transformGesture', 'track', 'reorderHandle', 'inkWell', 'states'],
  'customPaint': ['customPaint', 'strokePath'],
  'scrollEffects': ['sticky', 'floating', 'viewProgress', 'hero', 'flip', 'tilt'],
};

/// The runtime starter (the base set) for [catalog] restricted by
/// [profile] (default [TrustProfile.agent]). [kind] is `card` (an inline
/// card in a chat), `page` or `app` (a small interactive app or game).
/// [docsTool]: the `ui_docs` tool is offered, so the base ends with its
/// index.
String runtimeStarter({Catalog catalog = Catalog.core, TrustProfile? profile, String kind = 'card', bool docsTool = true}) {
  final p = profile ?? TrustProfile.agent;
  final slice = p.restrict(catalog);
  final has = slice.widget;
  final b = StringBuffer();
  b.writeln('You build and edit user interfaces by calling the ui_apply tool with edit ops. A UI is a Codelessly document: '
      'a flat map of nodes by id, each a Flutter widget as data. The app renders it natively while your ops stream in. '
      'You never write code${p.scripts ? ' except small sandboxed scripts' : ''}.');
  b.writeln();
  b.writeln('# Answering');
  b.writeln();
  for (final rule in [
    'Answer with exactly one ui_apply call${docsTool ? ' (first look up what the base below does not cover with ui_docs)' : ''}. '
        'At most one short sentence of text before it; none after.',
    switch (kind) {
      'card' => 'An inline card: one canvas, "layout": {"width": 390, "height": {"hug": 400}}, no fill on the canvas; its body is a '
          'column with the card\'s fill, radius and padding.',
      'app' => 'An app or game: one canvas of 390 × 760 (a fixed height) whose body is a column; state in variables, every '
          'interaction a reaction that changes them, the UI bound to them.',
      _ => 'A page: a canvas of 1440 × 900 whose body is a scrollable column; it must also work at 390 wide (rows that wrap; '
          'media rules: ui_docs "responsive").',
    },
    'Order, so the UI paints as it streams: the roots op, the canvas, then the visible structure top-down (a container, then '
        'its children, section by section). Declare variables and data in a vars op just before the first node that reads them, '
        'not at the start.',
    'The JSON must be balanced: one closing brace per opening brace. Write each op as {"op": ..., "id": ..., "node": {...}}: '
        'everything about the node (layout, props, bind, actions) inside "node".',
    'Every id you list in "children" (or a slot) must be defined by a set op in the same call. Only the types that take '
        '"children" below do. Short readable ids ("title", "opt2Price"); never reuse one.',
    'Give every node a width and a height. Set every text\'s colour explicitly. Colours are "#AARRGGBB".',
    'Text uses the app\'s font: letters, digits and common punctuation only. Arrows, check marks, stars and other symbols '
        'are icon nodes (Material icon names: arrow_forward, flight_takeoff, check, star), not characters.',
    'A button has a visible label with an explicit colour: ${has('filledButton') != null ? 'a filledButton with "label" and '
        '"style": {"backgroundColor", "foregroundColor"}, or ' : ''}a row with a fill and padding whose child is a text.',
    'To change a UI, send the smallest ops: patch the fields that change, move to reorder, remove, set only new nodes. '
        'Never re-send or rebuild what exists.',
    'The tool result lists rejected ops (code, path, expected, suggestion) and pending ids, and says how to fix them: '
        'fix by patching the document as it is (same ids). Never start over with new roots or a new canvas.',
    if (p.scripts)
      'Scripts: prefer a script (a scripts op) to long formulas for multi-step state changes, a puzzle\'s checks or a physics '
          'step; a reaction runs it ({"type": "runScript", "script": "name"}), a formula calls it (script.name(...)). A script '
          'cannot draw: it reads and sets variables (capabilities ${p.scriptCapabilities?.map((c) => c.id).join(', ') ?? 'any'}) '
          'that the UI binds to. ui_docs "scripts".',
  ]) {
    b.writeln('- $rule');
  }
  b.writeln();
  b.writeln('# Ops');
  b.writeln();
  b.writeln('`{"ops": [op, ...]}`, applied in order:');
  b.writeln();
  for (final s in EditOp.specs) {
    if (s.op == ScriptsOp.opName && !p.scripts) continue;
    final fields = [for (final f in s.fields) if (f.key != 'op') '${f.key}${f.required ? '' : '?'}'];
    b.writeln('- `${s.op}` (${fields.join(', ')}): ${firstSentences(s.doc, 2, max: 300)}');
  }
  b.writeln();
  b.writeln('# A node');
  b.writeln();
  b.writeln('`{"type", "layout", "decoration", "props", "children": [ids], "slots": {name: id}, "bind": {path: expression}, '
      '"actions": [reaction], "visible", "opacity", "name"}`.');
  b.writeln();
  b.writeln('| | |');
  b.writeln('|---|---|');
  b.writeln('| layout | ${_keys(LayoutFields.all, starterLayout)}. "width"/"height": a number (fixed), {"hug": n} (fit the content; '
      'n is the size you expect) or {"fill": n} (the free space of a row or column, or the parent\'s width); never a "hug" '
      'key of its own. "padding", "margin": n or [left, top, right, bottom]. "flex": share of free space. "x", "y", '
      '"align": place in a stack. |');
  b.writeln('| decoration | ${_keys(DecorationFields.all, starterDecoration)}. Fill: "fills": [{"color": "#FF2563EB"}] or '
      '[{"type": "linear", "stops": [{"position": 0, "color": ...}, {"position": 1, "color": ...}]}]. Border: "strokes": '
      '[{"color": ...}], "strokeWidth": 1. Corners: "radius": 12. Shadow: "effects": [{"type": "dropShadow", "color": '
      '"#1F000000", "offset": [0, 4], "blurRadius": 12}]. Only types marked "deco" below draw it. |');
  b.writeln('| text | "props": {"text": "...", "style": {${_keys(TextStyleFields.all, starterTextStyle)}}}: "fontWeight" 400 to 900, '
      '"height" a multiple of the size. Named styles and colours of a theme: ui_docs "theme". |');
  b.writeln();
  b.writeln('# Base node types');
  b.writeln();
  b.writeln('| type | takes | props |');
  b.writeln('|---|---|---|');
  for (final e in starterProps.entries) {
    final w = has(e.key);
    if (w == null) continue;
    final takes = switch (w.children) {
      ChildModel.list => w.slots.isEmpty || e.key == 'stack' ? 'children' : 'children (the first is the item)',
      ChildModel.slots => 'slots: ${w.slots.join(', ')}',
      ChildModel.none => 'none',
    };
    final props = [
      for (final k in e.value)
        if (w.prop(k) case final PropDef<Object?> d) '`$k` ${propTypeLabel(d.type)}',
    ];
    b.writeln('| `${w.type}` | $takes${w.decorated ? '; deco' : ''} | ${props.join(', ')} |');
  }
  b.writeln();
  if (has('icon') != null) b.writeln('- An icon is a Material icon name: "icon": "arrow_forward" (a style by suffix: "star_rounded").');
  if (has('filledButton') != null) {
    b.writeln('- A button: {"type": "filledButton", "layout": {"width": {"fill": 358}, "height": 48}, "props": {"label": "Confirm", '
        '"style": {"backgroundColor": "#FF2563EB", "foregroundColor": "#FFFFFFFF", "shape": {"type": "roundedRectangle", '
        '"borderRadius": 10}}}}. Its text is "label" (not "text"); its colours and corners are in "style", not "decoration".');
  }
  if (has('textField') != null) {
    b.writeln('- An input reports its value through its "changed" trigger as \${result}: store it with setVariable. A textField\'s '
        'label and hint: "decoration": {"labelText", "hintText"}; bind "props.initialValue" to a variable for a two-way value.');
  }
  if (has('listView') != null) {
    b.writeln('- A listView (or gridView) repeats its first child per item of its "data" binding: "bind": {"data": "\${flights}"}; '
        'inside, \${item.price} and \${index}. In a card: "scrollable": false and a hug height.');
  }
  b.writeln();
  b.writeln('# State, bindings, reactions');
  b.writeln();
  b.writeln('- Declare: {"op": "vars", "scope": "<canvas id>", "set": {"sel": {"type": "integer", "value": 0}}} '
      '(types: ${[for (final t in VariableType.values) t.name].join(', ')}). Set later: "set": {"sel": 2}.');
  b.writeln('- Bind a field: "bind": {"props.text": "Total £\${total}", '
      '"decoration.fills[0].color": "\${= sel == 0 ? \'#FFEFF6FF\' : \'#FFFFFFFF\'}", "visible": "\${= sel == 1}"}.');
  b.writeln('- React to a tap: "actions": [{"trigger": {"type": "click"}, "actions": [{"type": "setVariable", '
      '"variable": "sel", "value": "1"}]}]. Tell the agent (you) what the person chose: '
      '{"type": "componentEvent", "event": "confirm", "value": {"option": "\${sel}"}}: it arrives as their next message.');
  b.writeln('- Action types: ${[for (final a in slice.actions) a.type].join(', ')}. Triggers beyond "click" and "changed" '
      '(timer, frame, drag...): ui_docs "reactions".');
  b.writeln();
  b.writeln('# Examples');
  b.writeln();
  b.writeln('Build (a card with a selectable list and a labelled button):');
  b.writeln();
  b.writeln('```json');
  b.writeln(jsonEncode(starterBuildExample));
  b.writeln('```');
  b.writeln();
  b.writeln('Change it ("make it say Lisbon and add a note"):');
  b.writeln();
  b.writeln('```json');
  b.writeln(jsonEncode(starterEditExample));
  b.writeln('```');
  if (docsTool) {
    b.writeln();
    b.writeln('# Everything else: ui_docs');
    b.writeln();
    b.write(docsIndex(catalog: catalog, profile: p));
  }
  return b.toString();
}

/// The base's index of `ui_docs` topics: feature areas, then the node types,
/// action types and behaviors the profile allows beyond the base.
String docsIndex({Catalog catalog = Catalog.core, TrustProfile? profile}) {
  final p = profile ?? TrustProfile.agent;
  final slice = p.restrict(catalog);
  final b = StringBuffer();
  b.writeln('Call ui_docs {"topic": "..."} for a prop table, a minimal example and pitfalls of one topic:');
  b.writeln();
  b.writeln('- Areas: ${[
    for (final e in guideTopics.entries) '"${e.key}" (${e.value.title})',
    for (final a in behaviorAreas.keys) '"$a"',
    '"triggers"',
    if (p.scripts) '"scripts"',
  ].join(', ')}.');
  b.writeln('- Triggers (what starts a reaction; ui_docs "<name>"): ${[for (final x in TriggerType.values) x.name].join(', ')}.');
  b.writeln('- Node types: ${[for (final w in slice.widgets) if (!starterProps.containsKey(w.type)) w.type].join(', ')}; '
      'any base type, for all its props.');
  b.writeln('- Action types (the fields of each): ${[for (final a in slice.actions) a.type].join(', ')}.');
  b.writeln('- Behaviors (node keys): ${[for (final f in BehaviorFields.all) f.key].join(', ')}.');
  return b.toString();
}

/// Every topic [docsTopic] answers for [catalog].
List<String> docsTopicNames({Catalog catalog = Catalog.core}) => [
      ...guideTopics.keys,
      ...behaviorAreas.keys,
      'scripts',
      'triggers',
      for (final x in TriggerType.values) x.name,
      for (final w in catalog.widgets) w.type,
      for (final a in catalog.actions) a.type,
      for (final f in BehaviorFields.all) f.key,
    ];

/// One topic page, sized for a tool result (a few hundred tokens): a node
/// type, an action type, a behavior (a node key), "scripts" or a feature
/// area. What [profile] does not allow says so: it is documented, not
/// available.
String docsTopic(String topic, {Catalog catalog = Catalog.core, TrustProfile? profile}) {
  final p = profile ?? TrustProfile.agent;
  final slice = p.restrict(catalog);
  final t = topic.trim();
  if (guideTopics[t] case final g?) return '# ${g.title}\n\n${g.text}\n';
  if (t == 'scripts') return _scriptsTopic(p);
  if (t == 'triggers' || TriggerType.values.any((x) => x.name == t)) return _triggersTopic(t);
  if (behaviorAreas[t] case final keys?) {
    return '# $t\n\nBehaviors: node keys beside "layout" and "props" (ui_docs "<key>" for one).\n\n'
        '${[for (final k in keys) if (_behavior(k) case final f?) _fieldLine(f)].join('\n')}\n';
  }
  final w = catalog.widget(t);
  if (w != null) {
    final b = StringBuffer('# `${w.type}`\n\n');
    if (slice.widget(t) == null) b.writeln('Not available here: this app does not allow this node type. Use another.\n');
    if (w.doc.isNotEmpty) b.writeln('${firstSentences(w.doc, 3, max: 400)}\n');
    b.writeln('- Takes: ${switch (w.children) {
      ChildModel.list => 'children${w.slots.isEmpty ? '' : ' (and slots ${w.slots.join(', ')})'}',
      ChildModel.slots => 'slots ${w.slots.join(', ')} (no children list)',
      ChildModel.none => 'no children',
    }}. Decoration: ${w.decorated ? 'yes' : 'no (fills, strokes and radius are ignored)'}.');
    if (w.events.isNotEmpty) b.writeln('- Triggers it fires: ${[for (final e in w.events) e.key].join(', ')} (the value as \${result}).');
    b.writeln();
    b.writeln('| prop | type | |');
    b.writeln('|---|---|---|');
    for (final f in w.props.take(40)) {
      b.writeln('| `${f.key}` | ${propTypeLabel(f.type)} | ${firstSentences(f.doc, 1, max: 140)} |');
    }
    if (w.props.length > 40) b.writeln('\n${w.props.length - 40} more props not listed.');
    b.writeln();
    b.writeln('Minimal: ${jsonEncode({
          'type': w.type,
          'layout': {'width': {'fill': 358}, 'height': w.children == ChildModel.none ? 48 : {'hug': 120}},
          if (w.children == ChildModel.list) 'children': ['${w.type}Child'],
          if (w.slots.isNotEmpty && w.children == ChildModel.slots) 'slots': {w.slots.first: '${w.type}${_cap(w.slots.first)}'},
        })}');
    return b.toString();
  }
  final a = catalog.action(t);
  if (a != null) {
    final b = StringBuffer('# action `${a.type}`\n\n');
    if (slice.action(t) == null) b.writeln('Not available here: this app does not allow this action type.\n');
    if (a.doc.isNotEmpty) b.writeln('${firstSentences(a.doc, 3, max: 400)}\n');
    b.writeln('| field | type | |');
    b.writeln('|---|---|---|');
    for (final f in a.fields) {
      b.writeln('| `${f.key}` | ${propTypeLabel(f.type)} | ${firstSentences(f.doc, 1, max: 140)} |');
    }
    b.writeln('\nIn a reaction: "actions": [{"trigger": {"type": "click"}, "actions": [{"type": "${a.type}", ...}]}].');
    return b.toString();
  }
  if (_behavior(t) case final f?) {
    final b = StringBuffer('# behavior `${f.key}`\n\nA node key beside "layout" and "props".\n\n${_fieldLine(f)}\n');
    final item = f.type.item;
    final fields = f.type.kind == PropKind.object ? f.type.fields : (item != null && item.kind == PropKind.object ? item.fields : const []);
    if (fields.isNotEmpty) {
      b.writeln('\n| field | type | |\n|---|---|---|');
      for (final x in fields.take(30)) {
        b.writeln('| `${x.key}` | ${propTypeLabel(x.type)} | ${firstSentences(x.doc, 1, max: 140)} |');
      }
    }
    return b.toString();
  }
  return 'No topic "$t". Topics: ${docsTopicNames(catalog: slice).join(', ')}.';
}

/// What [TriggerType]s put in `${result}`, where it is not just the value.
const Map<String, String> _triggerResults = {
  'click': r'${result.x}, ${result.y}: where it landed in the node.',
  'changed': r'${result}: the new value of the input.',
  'drag': r'${result.dx}, ${result.dy} (this move), ${result.x}, ${result.y}; dragEnd when let go (${result.vx}, ${result.vy}: velocity).',
  'timer': r'"intervalMs": 1000 (a number or a formula), "when": a formula that must hold; ${result.tick} counts.',
  'frame': r'every frame while "when" holds: ${result.dt} (ms since the last), ${result.elapsed}, ${result.frame}. For physics and game loops.',
  'valueChanged': r'"variable": the name; runs when it changes.',
  'keyDown': r'"key": "space" or "ctrl+z"; ${result.key}.',
  'swipeLeft': r'also swipeRight, swipeUp, swipeDown: a fling.',
};

String _triggersTopic(String t) {
  final b = StringBuffer('# triggers\n\n');
  b.writeln('A reaction: {"trigger": {"type": "<trigger>", ...}, "actions": [...]} in a node\'s "actions". A screen trigger (load, '
      'timer, frame, keyDown, valueChanged...) goes on the canvas. Trigger fields: "type", "intervalMs", "when", "variable", '
      '"key", "holdMs", "debounceMs".\n');
  if (_triggerResults[t] case final r?) b.writeln('`$t`: $r\n');
  b.writeln('Types: ${[for (final x in TriggerType.values) x.name].join(', ')}.\n');
  for (final e in _triggerResults.entries) {
    if (e.key != t) b.writeln('- `${e.key}`: ${e.value}');
  }
  return b.toString();
}

String _scriptsTopic(TrustProfile p) {
  final caps = p.scriptCapabilities ?? ScriptCapability.values.toSet();
  return '''# scripts

${p.scripts ? '' : 'Not available here: this app does not allow scripts. Use formulas, variables and reactions.\n\n'}Sandboxed JavaScript the document keeps in its "scripts" list, written with the scripts op:
{"op": "scripts", "set": {"place": {"params": ["cell", "digit"], "source": "const b = vars.get('board'); b[cell] = digit; vars.set('board', b); return b;", "capabilities": ["variables.read", "variables.write"]}}}.

- What it returns at its top level is its result. Params are variables in its source.
- vars.get(name), vars.set(name, value) (with the capabilities variables.read / variables.write) read and set the
  document's variables; the UI updates through what binds to them. A script cannot draw or touch nodes.
- Capabilities allowed here: ${[for (final c in caps) '${c.id} (${c.label})'].join(', ')}.
- A reaction runs it: {"type": "runScript", "script": "place", "arguments": {"cell": "\${index}", "digit": "\${result}"}}.
- A formula calls it: "\${= script.isSolved(board)}" (keep those pure: no vars.set).
- Limits: ${ScriptDef.defaultTimeoutMs} ms of computing (timeoutMs up to ${ScriptDef.maxTimeoutMs}), ${ScriptDef.defaultMemoryLimitMb} MB; no network, files or timers.
- Names: JavaScript identifiers, not ${ScriptDef.reservedNames.join(', ')}.
''';
}

PropDef<Object?>? _behavior(String key) {
  for (final f in BehaviorFields.all) {
    if (f.key == key) return f;
  }
  return null;
}

String _fieldLine(PropDef<Object?> f) => '- `${f.key}`: ${propTypeLabel(f.type)}${f.doc.isEmpty ? '' : '. ${firstSentences(f.doc, 2, max: 240)}'}';

String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// The base's build example: a `ui_apply` input that applies with no error
/// or warning under [TrustProfile.agent] and strict validation, with a
/// selectable list and a labelled button.
const Json starterBuildExample = {
  'ops': [
    {'op': 'roots', 'roots': ['trip']},
    {
      'op': 'set',
      'id': 'trip',
      'node': {
        'type': 'canvas',
        'slots': {'body': 'card'},
        'layout': {'width': 390, 'height': {'hug': 260}},
      },
    },
    {
      'op': 'set',
      'id': 'card',
      'node': {
        'type': 'column',
        'children': ['head', 'list', 'go'],
        'layout': {'width': {'fill': 390}, 'height': {'hug': 260}, 'padding': 16},
        'props': {'crossAxisAlignment': 'stretch', 'spacing': 12},
        'decoration': {
          'fills': [{'color': '#FFFFFFFF'}],
          'radius': 16,
        },
      },
    },
    {
      'op': 'set',
      'id': 'head',
      'node': {
        'type': 'row',
        'children': ['from', 'arrow', 'to'],
        'layout': {'width': {'fill': 358}, 'height': {'hug': 26}},
        'props': {'crossAxisAlignment': 'center', 'spacing': 6},
      },
    },
    {
      'op': 'set',
      'id': 'from',
      'node': {
        'type': 'text',
        'layout': {'width': {'hug': 70}, 'height': {'hug': 26}},
        'props': {'text': 'London', 'style': {'fontSize': 20, 'fontWeight': 700, 'color': '#FF111827'}},
      },
    },
    {
      'op': 'set',
      'id': 'arrow',
      'node': {
        'type': 'icon',
        'layout': {'width': 20, 'height': 20},
        'props': {'icon': 'arrow_forward', 'color': '#FF6B7280'},
      },
    },
    {
      'op': 'set',
      'id': 'to',
      'node': {
        'type': 'text',
        'layout': {'width': {'hug': 70}, 'height': {'hug': 26}},
        'props': {'text': 'Porto', 'style': {'fontSize': 20, 'fontWeight': 700, 'color': '#FF111827'}},
      },
    },
    {
      'op': 'vars',
      'scope': 'trip',
      'set': {
        'sel': {'type': 'integer', 'value': 0},
        'flights': {
          'type': 'list',
          'value': [
            {'time': '07:10', 'price': '£148'},
            {'time': '13:45', 'price': '£122'},
          ],
        },
      },
    },
    {
      'op': 'set',
      'id': 'list',
      'node': {
        'type': 'listView',
        'children': ['item'],
        'layout': {'width': {'fill': 358}, 'height': {'hug': 100}},
        'props': {'scrollable': false, 'spacing': 8},
        'bind': {'data': r'${flights}'},
      },
    },
    {
      'op': 'set',
      'id': 'item',
      'node': {
        'type': 'row',
        'children': ['itemTime', 'itemPrice'],
        'layout': {'width': {'fill': 358}, 'height': 46, 'padding': [12, 0, 12, 0]},
        'props': {'mainAxisAlignment': 'spaceBetween', 'crossAxisAlignment': 'center'},
        'decoration': {
          'fills': [{'color': '#FFF3F4F6'}],
          'radius': 10,
        },
        'bind': {'decoration.fills[0].color': r"${= index == sel ? '#FFDBEAFE' : '#FFF3F4F6'}"},
        'actions': [
          {
            'trigger': {'type': 'click'},
            'actions': [
              {'type': 'setVariable', 'variable': 'sel', 'value': r'${index}'},
            ],
          },
        ],
      },
    },
    {
      'op': 'set',
      'id': 'itemTime',
      'node': {
        'type': 'text',
        'layout': {'width': {'hug': 60}, 'height': {'hug': 20}},
        'props': {'text': r'${item.time}', 'style': {'fontSize': 15, 'color': '#FF111827'}},
      },
    },
    {
      'op': 'set',
      'id': 'itemPrice',
      'node': {
        'type': 'text',
        'layout': {'width': {'hug': 50}, 'height': {'hug': 20}},
        'props': {'text': r'${item.price}', 'style': {'fontSize': 15, 'fontWeight': 700, 'color': '#FF111827'}},
      },
    },
    {
      'op': 'set',
      'id': 'go',
      'node': {
        'type': 'filledButton',
        'layout': {'width': {'fill': 358}, 'height': 48},
        'props': {
          'label': 'Confirm',
          'style': {
            'backgroundColor': '#FF2563EB',
            'foregroundColor': '#FFFFFFFF',
            'shape': {'type': 'roundedRectangle', 'borderRadius': 10},
          },
        },
        'actions': [
          {
            'trigger': {'type': 'click'},
            'actions': [
              {'type': 'componentEvent', 'event': 'confirm', 'value': {'option': r'${sel}'}},
            ],
          },
        ],
      },
    },
  ],
};

/// The base's edit example, on [starterBuildExample]'s document.
const Json starterEditExample = {
  'ops': [
    {'op': 'patch', 'id': 'to', 'patch': {'props': {'text': 'Lisbon'}}},
    {
      'op': 'set',
      'id': 'note',
      'parent': 'card',
      'index': 2,
      'node': {
        'type': 'text',
        'layout': {'width': {'fill': 358}, 'height': {'hug': 18}},
        'props': {'text': 'Prices include one bag.', 'style': {'fontSize': 13, 'color': '#FF6B7280'}},
      },
    },
  ],
};

/// What `ui_read {"types": [...]}` answers: each node type's children and
/// slots, whether it takes a decoration, and its props (type and doc).
Json describeTypes(Catalog catalog, Iterable<String> types) => {
      for (final t in types)
        t: switch (catalog.widget(t)) {
          null => {'error': 'Not a node type here. Types: ${[for (final w in catalog.widgets) w.type].join(', ')}.'},
          final w => {
              'children': w.children.name,
              if (w.slots.isNotEmpty) 'slots': w.slots,
              'decoration': w.decorated,
              if (w.doc.isNotEmpty) 'doc': firstSentences(w.doc, 2),
              'props': {
                for (final p in w.props)
                  p.key: '${propTypeLabel(p.type)}${p.doc.isEmpty ? '' : ': ${firstSentences(p.doc, 1)}'}',
              },
            },
        },
    };

/// A prop type as a model writes it: `start|end|center`, `number`,
/// `"#AARRGGBB"`, `TextStyle {fontSize, color...}`.
String propTypeLabel(PropType t) {
  if (t.values.isNotEmpty) return t.values.length > 8 ? '${t.values.take(8).join('|')}|...' : t.values.join('|');
  return switch (t.kind) {
    PropKind.boolean => 'bool',
    PropKind.integer => 'int',
    PropKind.number => 'number',
    PropKind.string => 'text',
    PropKind.list => '[${t.item == null ? '...' : propTypeLabel(t.item!)}]',
    PropKind.object => '${t.name} ${_objectKeys(t)}',
    _ => switch (t.name) {
        'Color' => '"#AARRGGBB"',
        'EdgeInsets' => 'n | [l, t, r, b]',
        'BorderRadius' => 'number',
        'IconData' => 'icon name',
        'Alignment' => '[x, y]',
        _ => t.name,
      },
  };
}

String _objectKeys(PropType? t) => t == null ? '{}' : '{${[for (final f in t.fields) f.key].take(8).join(', ')}}';

String _keys(List<PropDef<Object?>> all, List<String> wanted) {
  final have = {for (final f in all) f.key};
  return [for (final k in wanted) if (have.contains(k)) '"$k"'].join(', ');
}

/// The first [n] sentences of [text], at most [max] characters.
String firstSentences(String text, int n, {int max = 260}) {
  final parts = text.replaceAll('\n', ' ').split(RegExp(r'(?<=[.:])\s+(?=[A-Z`(])'));
  final s = parts.take(n).join(' ').trim();
  return s.length > max ? '${s.substring(0, max - 3)}...' : s;
}
