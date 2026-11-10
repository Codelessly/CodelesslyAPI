// The code samples of the codelessly_api guide (CodelesslyAPI/docs/guide),
// kept runnable so they stay correct:
//
//   dart run --enable-asserts example/guide.dart
// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:codelessly_api_v2/codelessly_api.dart';

void main() {
  decoding();
  typedProps();
  editing();
  introspection();
  logic();
  scripts();
  breakpoints();
  publish();
  print('ok');
}

// --- Decoding is total ---------------------------------------------------

void decoding() {
  final document = LayoutDocument.fromJson({
    'schema': 2,
    'id': 'L',
    'roots': ['c', 'missing'],
    'nodes': {
      'c': {
        'type': 'canvas',
        'slots': {'body': 't'},
        'layout': {'width': 390, 'height': 844},
      },
      't': {
        'type': 'text',
        'props': {'text': 'Hi', 'maxLines': 'two', 'futureProp': 1},
        'futureKey': true,
      },
      'x': {'type': 'hologram', 'props': {'depth': 3}},
      'junk': 'not a node',
    },
  });

  // A root that names no node is dropped; an entry that isn't a node too.
  assert(document.roots.length == 1 && document.nodes.length == 3);

  // A bad value falls back to the default.
  assert(document['t']!.prop(TextProps.maxLines) == null);

  // Unknown props and keys are kept, and written back.
  assert(document['t']!.props.unknown['futureProp'] == 1);
  assert(document['t']!.extra['futureKey'] == true);

  // An unknown type decodes (spec is null) and round-trips.
  assert(document['x']!.spec == null);
  final again = LayoutDocument.fromJson(jsonDecode(jsonEncode(document.toJson())));
  assert(again.nodes['x'] == document.nodes['x']);
}

// --- Typed props ---------------------------------------------------------

void typedProps() {
  final node = Node.fromJson({
    'type': 'column',
    'props': {'spacing': 12, 'crossAxisAlignment': 'start'},
  }, id: 'col')!;

  final double spacing = node.prop(FlexProps.spacing); // 12.0
  final CrossAxisAlignment cross = node.prop(FlexProps.crossAxisAlignment); // start
  final MainAxisAlignment main = node.prop(FlexProps.mainAxisAlignment); // Flutter's default: start
  assert(spacing == 12 && cross == CrossAxisAlignment.start && main == MainAxisAlignment.start);

  // Encoding is sparse: a value equal to the default isn't written.
  final same = node.withProp(FlexProps.crossAxisAlignment, CrossAxisAlignment.center);
  assert(!(same.toJson()['props'] as Map).containsKey('crossAxisAlignment'));

  // A value is checked against the declaration.
  try {
    node.withProp<Object?>(FlexProps.spacing, 'wide');
    assert(false);
  } on ArgumentError {
    // Not a value of double.
  }
}

// --- Editing -------------------------------------------------------------

void editing() {
  final document = LayoutDocument(
    roots: const ['c'],
    nodes: {
      'c': const Node(id: 'c', type: 'canvas', slots: {'body': 't'}),
      't': const Node(id: 't', type: 'text').withProp(TextProps.text, 'Hi'),
    },
  );

  // Nodes and documents are immutable: an edit is a copy.
  final edited = document.copyWith(nodes: {
    ...document.nodes,
    't': document['t']!.withProp(TextProps.text, 'Hello').copyWith(opacity: 0.5),
  });
  assert(document['t']!.prop(TextProps.text) == 'Hi');
  assert(edited['t']!.prop(TextProps.text) == 'Hello');

  // Value equality tells what changed.
  final changed = [
    for (final id in edited.nodes.keys)
      if (edited[id] != document[id]) id,
  ];
  assert(changed.length == 1 && changed.single == 't');

  // A JSON merge patch over a node (what an interaction state applies).
  final patched = edited['t']!.patched({
    'props': {'text': 'Patched'},
    'visible': false,
  });
  assert(patched.prop(TextProps.text) == 'Patched' && !patched.visible && patched.opacity == 0.5);
}

// --- Introspection -------------------------------------------------------

void introspection() {
  // Every widget type this version declares.
  print('${Widgets.all.length} widget types: ${Widgets.all.take(8).map((s) => s.type).join(', ')}, ...');

  // One declaration: its props, with Flutter's types and defaults.
  final spec = Widgets.of('filledButton')!;
  for (final prop in spec.props) {
    print('  ${spec.type}.${prop.key}: ${prop.type.typeName}${prop.nullable ? '?' : ''} = ${prop.defaultValue}');
  }

  // What a tool needs to build a control for a prop.
  final align = FlexProps.mainAxisAlignment.type;
  assert(align.kind == PropKind.enumeration && align.values.contains('spaceBetween'));
  assert(Widgets.of('column')!.children == ChildModel.list);
  assert(Widgets.of('canvas')!.slots.contains('body'));
}

// --- Variables and conditions ---------------------------------------------

void logic() {
  final document = LayoutDocument.fromJson({
    'schema': 2,
    'roots': ['home'],
    'nodes': {
      'home': {'type': 'canvas'},
    },
    'variables': {
      'home': [
        {'id': 'v1', 'name': 'count', 'type': 'integer', 'value': 0},
        {'id': 'v2', 'name': 'double', 'type': 'integer', 'formula': 'count * 2'},
      ],
    },
    'conditions': {
      'home': [
        {
          'id': 'c1',
          'branches': [
            {
              'when': {'left': r'${count}', 'op': 'greaterThan', 'right': '5'},
              'set': [
                {'node': 'badge', 'path': 'visible', 'value': true},
              ],
            },
            {
              'set': [
                {'node': 'badge', 'path': 'visible', 'value': false},
              ],
            },
          ],
        },
      ],
    },
  });

  final logic = document.logic;
  final count = logic.variablesOf('home').first;
  assert(count.name == 'count' && count.type == VariableType.integer && count.value == 0);
  assert(logic.variablesOf('home').last.formula == 'count * 2');
  assert(logic.conditionsOf('home').single.branches.length == 2);
}

// --- Scripts ---------------------------------------------------------------

void scripts() {
  const script = ScriptDef(
    id: 's1',
    name: 'loanPayment',
    params: [ScriptParam(name: 'principal'), ScriptParam(name: 'rate', defaultValue: 5)],
    source: 'return principal * rate / 100;',
  );
  assert(script.validate().isEmpty);

  const bad = ScriptDef(id: 's2', name: 'vars', source: 'return 1;', timeoutMs: 0);
  print('script problems: ${bad.validate()}');
  assert(bad.validate().length == 2);
}

// --- Breakpoints -----------------------------------------------------------

void breakpoints() {
  final set = Breakpoints.defaults;
  assert(set.forWidth(390).id == 'mobile');
  assert(set.forWidth(800).id == 'tablet');
  assert(set.forWidth(1440).id == 'desktop');
}

// --- Publish ---------------------------------------------------------------

void publish() {
  final bundle = PublishBundle.fromJson({
    'model': {
      'schema': 2,
      'projectId': 'p',
      'entryLayoutId': 'home',
      'layoutIDMap': {'start': 'home'},
      'layouts': {
        'home': {
          'canvases': [
            {'id': 'home-m', 'name': 'Home · M'},
            {'id': 'home-d', 'name': 'Home · D', 'path': 'home'},
          ],
        },
      },
    },
    'layouts': {
      'home': {
        'schema': 2,
        'id': 'home',
        'roots': ['home-m', 'home-d'],
        'breakpoints': [
          {'canvas': 'home-m', 'breakpoint': 'mobile'},
          {'canvas': 'home-d', 'breakpoint': 'desktop'},
        ],
        'nodes': {
          'home-m': {'type': 'canvas', 'name': 'Home · M', 'layout': {'width': 390, 'height': 844}},
          'home-d': {'type': 'canvas', 'name': 'Home · D', 'layout': {'width': 1440, 'height': 900}},
        },
      },
    },
  });

  final model = bundle.model;
  // A layout is named by its id, a custom id, or one of its canvases' ids.
  assert(model.resolveLayoutId('home') == 'home');
  assert(model.resolveLayoutId('start') == 'home');
  assert(model.resolveLayoutId('home-d') == 'home');
  assert(model.resolveLayoutId('nope') == null);
  // Or by a screen's name, loosely.
  assert(model.layoutIdForScreen('home-·-m') == 'home');

  // The canvas for a width, by the project's breakpoints.
  final layout = bundle.layouts['home']!;
  assert(layout.canvasForWidth(400, model.breakpoints) == 'home-m');
  assert(layout.canvasForWidth(1280, model.breakpoints) == 'home-d');

  // Where a publish is stored.
  assert(PublishSource.publish.modelPath('p') == 'publish/p');
  assert(PublishSource.publish.layoutPath('p', 'home') == 'publish/p/layouts/home');
  assert(PublishSource.preview.modelPath('p') == 'publish_preview/p');
  assert(PublishSource.publish.bundlePath('my-slug') == 'publish/my-slug.json');
}
