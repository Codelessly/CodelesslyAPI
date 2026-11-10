// Builds a small Codelessly layout in code, encodes it to JSON, reads it
// back and inspects it, then wraps it as a publish bundle the Codelessly
// SDK can show (`Codelessly.fromBundle`).
//
//   dart run example/example.dart
import 'dart:convert';

import 'package:codelessly_api_v2/codelessly_api.dart';

void main() {
  // 1. Nodes: a widget type, a layout, and the widget's own props. Props
  //    are Flutter's parameter names with Flutter's defaults.
  final title = const Node(
    id: 'title',
    type: 'text',
    name: 'Title',
    layout: Layout(width: AxisSize.hug(120), height: AxisSize.hug(28)),
    // A bound property: an expression the SDK evaluates while the app runs.
    bind: {'props.text': r'Hello, ${data.name}!'},
  ).withProp(TextProps.text, 'Hello!').withProp(
        TextProps.style,
        const TextStyle(fontSize: 24, fontWeight: 700, color: Color(0xFF111111)),
      );

  final counter = const Node(
    id: 'counter',
    type: 'text',
    layout: Layout(width: AxisSize.hug(80), height: AxisSize.hug(20)),
  ).withProp(TextProps.text, r'Taps: ${count}');

  final button = const Node(
    id: 'button',
    type: 'filledButton',
    layout: Layout(width: AxisSize.hug(120), height: AxisSize.fixed(44)),
    // A reaction: a trigger and the chain of actions it runs.
    actions: [
      Reaction(
        id: 'r1',
        trigger: Trigger(TriggerType.click),
        actions: [
          SetVariableAction(variable: 'count', write: ValueWrite(op: WriteOp.add, value: '1')),
          CallFunctionAction(name: 'onTap', params: {'count': r'${count}'}),
        ],
      ),
    ],
  ).withProp(ButtonProps.label, 'Tap me');

  final column = const Node(
    id: 'column',
    type: 'column',
    children: ['title', 'counter', 'button'],
    layout: Layout(
      width: AxisSize.fill(390),
      height: AxisSize.fill(844),
      padding: EdgeInsets.all(24),
    ),
  )
      // A prop is checked against its declaration: 12 is stored as 12.0.
      .withProp(FlexProps.spacing, 12)
      .withProp(FlexProps.crossAxisAlignment, CrossAxisAlignment.start);

  // A canvas is a screen. Its content is its `body` slot.
  const canvas = Node(
    id: 'home',
    type: 'canvas',
    name: 'Home',
    slots: {'body': 'column'},
    layout: Layout(width: AxisSize.fixed(390), height: AxisSize.fixed(844)),
    decoration: Decoration(fills: [Paint.solid(Color.white)]),
  );

  // 2. A document: canvases (roots) and every node in one flat map.
  final document = LayoutDocument(
    id: 'hello',
    roots: const ['home'],
    nodes: {for (final n in [canvas, column, title, counter, button]) n.id: n},
  );

  // 3. JSON: sparse (defaults are left out) and versioned ("schema": 2).
  final json = document.toJson();
  print(const JsonEncoder.withIndent('  ').convert(json));

  // 4. Decoding is total: it never throws, unknown keys and node types
  //    round-trip, bad values fall back to defaults.
  final decoded = LayoutDocument.fromJson(jsonDecode(jsonEncode(json)));
  assert(decoded.nodes['column'] == column, 'nodes have value equality');
  print('\nparent of title: ${decoded.parentOf('title')}');
  print('column spacing: ${decoded['column']!.prop(FlexProps.spacing)}');
  print('column mainAxisAlignment (Flutter\'s default): ${decoded['column']!.prop(FlexProps.mainAxisAlignment)}');
  print('home subtree: ${decoded.subtree('home').map((n) => n.type).join(' > ')}');

  // 5. Checking a document: every node's type is declared, and every child
  //    exists.
  for (final problem in problemsOf(decoded)) {
    print('problem: $problem');
  }

  // 6. A publish bundle: what the SDK loads. The layout carries the
  //    screen's variables; the model lists the layouts and the entry screen.
  final bundle = bundleOf(document);
  print('\nbundle: ${bundle.model.layouts.length} layout(s), entry ${bundle.model.entryLayoutId}, '
      '${jsonEncode(bundle.toJson()).length} bytes of JSON');
}

/// What's wrong with [document]: node types this version doesn't declare,
/// and children, slots and roots that name no node.
List<String> problemsOf(LayoutDocument document) => [
      for (final root in document.roots)
        if (document[root]?.type != CanvasProps.spec.type) 'root $root is not a canvas',
      for (final node in document.nodes.values) ...[
        if (node.spec == null) '${node.id}: unknown type "${node.type}"',
        for (final child in node.childIds)
          if (document[child] == null) '${node.id}: child $child does not exist',
      ],
    ];

/// [document] published as a project of one layout.
PublishBundle bundleOf(LayoutDocument document, {String projectId = 'example'}) {
  final layout = PublishLayout(
    document: document,
    projectId: projectId,
    variables: {
      for (final canvas in document.roots)
        canvas: [const Variable(id: 'v_count', name: 'count', type: VariableType.integer, value: 0).toJson()],
    },
  );
  return PublishBundle(
    model: PublishModel(
      projectId: projectId,
      entryLayoutId: layout.id,
      layouts: {layout.id: PublishLayoutInfo.of(layout)},
    ),
    layouts: {layout.id: layout},
  );
}
