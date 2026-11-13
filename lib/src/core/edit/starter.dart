// The runtime starter: what a model needs to write a UI with edit ops, as
// one compact system prompt, generated from the declarations for the node
// and action types a trust profile allows (docs/design/08 §4: the runtime
// context is ≤ 6k tokens). The op rules, the node shape, layout and
// decoration essentials, the core node types with their most-used props, the
// rules live generations showed models need, and two short `ui_apply` calls
// that apply cleanly (test/edit_starter_test.dart). Everything else is one
// `ui_read {"types": [...]}` away ([describeTypes]).
import 'dart:convert';

import '../catalog.dart';
import '../json.dart';
import '../props.dart';
import '../value_fields.dart';
import '../variables.dart' show VariableType;
import 'edit_ops.dart';
import 'trust.dart';

/// The node types the starter describes, each with the props it shows (in
/// this order; a key the type does not declare is skipped).
const Map<String, List<String>> starterProps = {
  'canvas': [],
  'column': ['mainAxisAlignment', 'crossAxisAlignment', 'spacing', 'scrollable'],
  'row': ['mainAxisAlignment', 'crossAxisAlignment', 'spacing', 'wrap', 'runSpacing'],
  'stack': [],
  'box': [],
  'text': ['text', 'style', 'textAlign', 'maxLines', 'overflow'],
  'icon': ['icon', 'color'],
  'filledButton': ['label', 'icon', 'style'],
  'divider': ['thickness', 'color'],
  'progressBar': ['value', 'max', 'color', 'backgroundColor'],
  'spacer': [],
};

/// The layout, decoration and text style keys it lists.
const List<String> starterLayout = ['width', 'height', 'padding', 'margin', 'flex', 'align', 'x', 'y', 'constraints', 'aspectRatio'];
const List<String> starterDecoration = ['fills', 'strokes', 'strokeWidth', 'radius', 'effects', 'clip'];
const List<String> starterTextStyle = ['fontSize', 'fontWeight', 'color', 'height', 'letterSpacing', 'fontStyle', 'decoration'];

/// The runtime starter for [catalog] restricted by [profile] (default
/// [TrustProfile.agent]): a system prompt of about 3,500 tokens. [kind] is
/// `card` (an inline card in a chat) or `page`.
String runtimeStarter({Catalog catalog = Catalog.core, TrustProfile? profile, String kind = 'card'}) {
  final slice = (profile ?? TrustProfile.agent).restrict(catalog);
  final b = StringBuffer();
  b.writeln('You build and edit user interfaces by calling the ui_apply tool with edit ops. A UI is a Codelessly document: '
      'a flat map of nodes by id, each a Flutter widget as data. The app renders it natively while your ops stream in. '
      'You never write code.');
  b.writeln();
  b.writeln('# Answering');
  b.writeln();
  for (final rule in [
    'Answer with exactly one ui_apply call. At most one short sentence of text before it; none after.',
    kind == 'card'
        ? 'An inline card: one canvas, "layout": {"width": 390, "height": {"hug": 400}}, no fill on the canvas; its body is a '
            'column with the card\'s fill, radius and padding.'
        : 'A page: a canvas of 1440 × 900 whose body is a scrollable column; it must also work at 390 wide (rows that wrap).',
    'Order, so the UI paints as it streams: the roots op, the canvas, then the visible structure top-down (a container, then '
        'its children, section by section). Declare variables and data in a vars op just before the first node that reads them, '
        'not at the start.',
    'The JSON must be balanced: one closing brace per opening brace. Write each op as {"op": ..., "id": ..., "node": {...}}: '
        'everything about the node (layout, props, bind, actions) inside "node".',
    'Every id you list in "children" (or a slot) must be defined by a set op in the same call. Short readable ids: '
        '"title", "opt2Price". Never reuse an id for another node.',
    'Give every node a width and a height. Set every text\'s colour explicitly. Colours are "#AARRGGBB".',
    'Text uses the app\'s font: letters, digits and common punctuation only. Arrows, check marks, stars and other symbols '
        'are icon nodes (Material icon names: arrow_forward, flight_takeoff, check, star), not characters.',
    'A button needs a visible label with an explicit colour: ${slice.widget('filledButton') != null ? 'a filledButton with "label", or ' : ''}'
        'a row with a fill and padding whose child is a text. A box takes no children.',
    'To change a UI, send the smallest ops: patch the fields that change, move to reorder, remove, set only new nodes. '
        'Never re-send or rebuild what exists.',
    'The tool result lists rejected ops (code, path, expected, suggestion) and pending ids, and says how to fix them: '
        'fix by patching the document as it is (same ids). Never start over with new roots or a new canvas.',
  ]) {
    b.writeln('- $rule');
  }
  b.writeln();
  b.writeln('# Ops');
  b.writeln();
  b.writeln('`{"ops": [op, ...]}`, applied in order:');
  b.writeln();
  for (final s in EditOp.specs) {
    final fields = [for (final f in s.fields) if (f.key != 'op') '${f.key}${f.required ? '' : '?'}'];
    b.writeln('- `${s.op}` (${fields.join(', ')}): ${_firstSentences(s.doc, 3, max: 420)}');
  }
  b.writeln();
  b.writeln('# A node');
  b.writeln();
  b.writeln('`{"type", "layout", "decoration", "props", "children": [ids], "slots": {name: id}, "bind": {path: expression}, '
      '"actions": [reaction], "visible", "opacity", "name"}`.');
  b.writeln();
  b.writeln('## Layout');
  b.writeln();
  b.writeln('Keys: ${_keys(LayoutFields.all, starterLayout)}.');
  b.writeln('- Sizes: "width"/"height" are a number (fixed), {"hug": n} (fit the content; n is the size you expect) or '
      '{"fill": n} (take the free space of a row or column, or the parent\'s width). Never a "hug" or "fill" key of its own.');
  b.writeln('- "padding" and "margin": a number or [left, top, right, bottom]. "flex": the share of free space under a row or '
      'column. "x", "y", "align": a child\'s place in a stack.');
  b.writeln();
  b.writeln('## Decoration');
  b.writeln();
  b.writeln('Keys: ${_keys(DecorationFields.all, starterDecoration)}. A paint: {"color": "#FF2563EB"}, or '
      '{"type": "linear", "stops": [{"position": 0, "color": ...}, {"position": 1, "color": ...}]} '
      '(${_keys(PaintFields.all, const ['type', 'color', 'stops', 'begin', 'end', 'opacity'])}). '
      'A border: "strokes": [{"color": ...}] with "strokeWidth". Corners: "radius": 12. '
      'Shadows: "effects": [{"type": "dropShadow", "color": "#1F000000", "offset": [0, 4], "blurRadius": 12}] '
      '(${_keys(EffectFields.all, const ['type', 'color', 'offset', 'blurRadius', 'spreadRadius'])}).');
  b.writeln();
  b.writeln('## Text style');
  b.writeln();
  b.writeln('"props": {"text": "...", "style": {...}} with ${_keys(TextStyleFields.all, starterTextStyle)} '
      '("fontWeight": 400 to 900; "height": line height as a multiple of the size).');
  b.writeln();
  b.writeln('## State, bindings, reactions');
  b.writeln();
  b.writeln('- Declare: {"op": "vars", "scope": "<canvas id>", "set": {"sel": {"type": "integer", "value": 0}}} '
      '(types: ${[for (final t in VariableType.values) t.name].join(', ')}). Set later: {"op": "vars", "scope": ..., "set": {"sel": 2}}.');
  b.writeln('- Bind a field to an expression: "bind": {"props.text": "Total £\${total}", '
      '"decoration.fills[0].color": "\${= sel == 0 ? \'#FFEFF6FF\' : \'#FFFFFFFF\'}", "visible": "\${= sel == 1}"}.');
  b.writeln('- React to a tap: "actions": [{"trigger": {"type": "click"}, "actions": [{"type": "setVariable", '
      '"variable": "sel", "value": "1"}]}]. Tell the agent (you) what the person chose: '
      '{"type": "componentEvent", "event": "confirm", "value": {"option": "\${sel}"}}: it arrives as their next message.');
  final actions = [for (final a in slice.actions) a.type];
  b.writeln('- Action types: ${actions.join(', ')}.');
  b.writeln();
  b.writeln('# Node types');
  b.writeln();
  for (final e in starterProps.entries) {
    final w = slice.widget(e.key);
    if (w == null) continue;
    final kids = switch (w.children) {
      ChildModel.list => 'children',
      ChildModel.slots => 'slots ${w.slots.join(', ')}',
      ChildModel.none => 'no children',
    };
    final props = [
      for (final k in e.value)
        if (w.prop(k) case final PropDef<Object?> p) '`$k` ${propTypeLabel(p.type)}',
    ];
    b.writeln('- `${w.type}` ($kids${w.decorated ? '; decoration' : ''})${props.isEmpty ? '' : ': ${props.join(', ')}'}.');
  }
  if (slice.widget('icon') != null) b.writeln('- Icon value: {"type": "MATERIAL_ICON", "name": "arrow_forward"}.');
  if (slice.widget('filledButton')?.prop('style')?.type case final PropType t) {
    b.writeln('- A button style: ${_objectKeys(t)}; colours as above.');
  }
  final others = [for (final w in slice.widgets) if (!starterProps.containsKey(w.type)) w.type];
  if (others.isNotEmpty) {
    b.writeln('- Also allowed (call ui_read {"types": [...]} for their props before using one): ${others.join(', ')}.');
  }
  b.writeln();
  b.writeln('# Examples');
  b.writeln();
  b.writeln('Build (a card with a selectable option and a confirm button):');
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
  return b.toString();
}

/// The starter's build example: a `ui_apply` input that applies with no
/// error or warning under [TrustProfile.agent] and strict validation.
const Json starterBuildExample = {
  'ops': [
    {'op': 'roots', 'roots': ['trip']},
    {
      'op': 'set',
      'id': 'trip',
      'node': {
        'type': 'canvas',
        'slots': {'body': 'card'},
        'layout': {'width': 390, 'height': {'hug': 220}},
      },
    },
    {
      'op': 'set',
      'id': 'card',
      'node': {
        'type': 'column',
        'children': ['head', 'opt0', 'go'],
        'layout': {'width': {'fill': 390}, 'height': {'hug': 220}, 'padding': 16},
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
        'props': {'icon': {'type': 'MATERIAL_ICON', 'name': 'arrow_forward'}, 'color': '#FF6B7280'},
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
      },
    },
    {
      'op': 'set',
      'id': 'opt0',
      'node': {
        'type': 'text',
        'layout': {'width': {'fill': 358}, 'height': {'hug': 22}},
        'props': {'text': '07:10 · Direct · £148', 'style': {'fontSize': 16, 'color': '#FF111827'}},
        'bind': {'props.style.fontWeight': r'${= sel == 0 ? 700 : 400}'},
        'actions': [
          {
            'trigger': {'type': 'click'},
            'actions': [
              {'type': 'setVariable', 'variable': 'sel', 'value': '0'},
            ],
          },
        ],
      },
    },
    {
      'op': 'set',
      'id': 'go',
      'node': {
        'type': 'row',
        'children': ['goText'],
        'layout': {'width': {'fill': 358}, 'height': 46},
        'props': {'mainAxisAlignment': 'center', 'crossAxisAlignment': 'center'},
        'decoration': {
          'fills': [{'color': '#FF2563EB'}],
          'radius': 10,
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
    {
      'op': 'set',
      'id': 'goText',
      'node': {
        'type': 'text',
        'layout': {'width': {'hug': 120}, 'height': {'hug': 20}},
        'props': {'text': 'Confirm', 'style': {'fontSize': 15, 'fontWeight': 700, 'color': '#FFFFFFFF'}},
      },
    },
  ],
};

/// The starter's edit example, on [starterBuildExample]'s document.
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
              if (w.doc.isNotEmpty) 'doc': _firstSentences(w.doc, 2),
              'props': {
                for (final p in w.props)
                  p.key: '${propTypeLabel(p.type)}${p.doc.isEmpty ? '' : ': ${_firstSentences(p.doc, 1)}'}',
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
        'EdgeInsets' => 'number | [l, t, r, b]',
        'BorderRadius' => 'number',
        'IconData' => 'icon',
        'Alignment' => '[x, y] (-1..1)',
        _ => t.name,
      },
  };
}

String _objectKeys(PropType? t) => t == null ? '{}' : '{${[for (final f in t.fields) f.key].take(10).join(', ')}}';

String _keys(List<PropDef<Object?>> all, List<String> wanted) {
  final have = {for (final f in all) f.key};
  return [for (final k in wanted) if (have.contains(k)) '"$k"'].join(', ');
}

String _firstSentences(String text, int n, {int max = 260}) {
  final parts = text.replaceAll('\n', ' ').split(RegExp(r'(?<=[.:])\s+(?=[A-Z`(])'));
  final s = parts.take(n).join(' ').trim();
  return s.length > max ? '${s.substring(0, max - 3)}...' : s;
}
