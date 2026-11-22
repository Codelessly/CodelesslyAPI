// A node's line (print_fields.dart): every word the printer writes is
// written, expanded, checked in the document, printed, and read back as the
// same line (docs/design/22-notation-parity.md, section 3).
import 'dart:convert';

import 'package:codelessly_api/codelessly_api.dart';
import 'package:codelessly_api/notation.dart';
import 'package:codelessly_api/src/core/notation/print_fields.dart';
import 'package:test/test.dart';

final _ids = RegExp(r'^(\s*[A-Za-z][A-Za-z0-9.]*)#[A-Za-z_][A-Za-z0-9_]*', multiLine: true);

/// [text] expanded, with no issue.
Json _expand(String text) {
  final r = parseNotation(text, catalog: standardCatalog);
  expect(r.issues, isEmpty, reason: text);
  return r.document;
}

/// [doc] printed, ids written by the expander left out.
String _print(Json doc) => printNotation(doc, catalog: standardCatalog).replaceAllMapped(_ids, (m) => m[1]!);

/// The last node of [type] in [doc].
Json _node(Json doc, String type) => readMap(doc['nodes'])!.values.map(readMap).nonNulls.lastWhere((n) => n['type'] == type);

/// The value at [path] (`props.style.fontSize`, `decoration.fills[0].color`).
Object? _at(Json node, String path) {
  // A binding's key is its whole path.
  if (path.startsWith('bind.')) return readMap(node['bind'])?[path.substring(5)];
  Object? v = node;
  for (final part in path.split('.')) {
    final m = RegExp(r'^([^\[]+)((?:\[\d+\])*)$').firstMatch(part)!;
    v = v is Map ? v[m[1]] : null;
    for (final i in RegExp(r'\[(\d+)\]').allMatches(m[2]!)) {
      v = v is List && v.length > int.parse(i[1]!) ? v[int.parse(i[1]!)] : null;
    }
  }
  return v;
}

/// Writes [text], expands it, expects [path] of the last [type] node to be
/// [value], prints the document and gets [text] back.
void _says(String text, String type, String path, Object? value) {
  final doc = _expand(text);
  expect(_at(_node(doc, type), path), value, reason: '$path of $text');
  expect(_print(doc), text);
}

/// A case: the text, the node type it is checked on, the path and value.
typedef _Case = (String text, String type, String path, Object? value);

void _cases(String group, List<_Case> cases, {String? skip}) {
  for (final (text, type, path, value) in cases) {
    test('$group: ${text.split('\n').last.trim()}', () => _says(text, type, path, value), skip: skip);
  }
}

void main() {
  group('a type', () {
    test('every node type of the catalog is written with a word that reads back as it', () {
      for (final w in standardCatalog.widgets) {
        // A page view's page is made under it as it is read, and a gauge is
        // a stack of its arc and figure: printed as the line that made them,
        // which is the walk's (print.dart), not a line's.
        if (const {'canvas', 'pageView', 'radialGauge'}.contains(w.type) || w.type[0].toUpperCase() == w.type[0]) continue;
        final doc = _expand('Column\n  ${w.type}');
        // Printed with the ids the expander gave (a page view's page is named for it).
        final printed = printNotation(doc, catalog: standardCatalog);
        expect(printed, isNot(contains('{"')), reason: '${w.type} has a tail: $printed');
        expect(_node(_expand(printed), w.type)['type'], w.type, reason: printed);
        expect(printNotation(_expand(printed), catalog: standardCatalog), printed, reason: w.type);
      }
    });

    test('the short names are written where they say no more than the type', () {
      for (final (type, word) in const [
        ('textField', 'Input'),
        ('switch', 'Toggle'),
        ('dropdown', 'Select'),
        ('filledButton', 'Button'),
        ('progressBar', 'Progress'),
        ('outlinedButton', 'Button.outline'),
        ('textButton', 'Button.ghost'),
        ('elevatedButton', 'Button.elevated'),
        ('listView', 'ListView'),
        // A capital is another word: Box is a column, GridView a grid, Badge a pill.
        ('box', 'box'),
        ('gridView', 'gridView'),
        ('badge', 'badge'),
        // LineChart adds a height and a color (design 22, 4.5): a line
        // chart with neither is the catalog's lineChart.
        ('lineChart', 'lineChart'),
      ]) {
        expect(_print(_expand('Column\n  $type')).split('\n')[1].trim(), startsWith(word), reason: type);
      }
    });

    _cases('a button\'s look', [
      ('Column\n  Button.secondary "Later"', 'filledButton', 'props.tonal', true),
      ('Column\n  Button.destructive "Delete"', 'filledButton', 'props.style.backgroundColor', '#FFDC2626'),
    ]);

    test('a text in a named style is that variant; two names of one style print as the later', () {
      for (final v in defaultTextVariants.keys.where((k) => k != 'body')) {
        final printed = _print(_expand('Column\n  Text.$v "x"'));
        final head = RegExp(r'Text\.(\w+)').firstMatch(printed)![1]!;
        expect(defaultTextVariants[head], defaultTextVariants[v], reason: v);
        expect(_print(_expand(printed)), printed);
      }
    });

    _cases('a picture', [
      ('Column\n  Image "https://example.com/a.png"', 'box', 'decoration.fills[0].image.url', 'https://example.com/a.png'),
      ('Column\n  Image "a.png" fit=contain', 'box', 'decoration.fills[0].image.fit', 'contain'),
    ]);
  });

  group('the main string', () {
    _cases('a text', [
      ('Column\n  Text "Hello"', 'text', 'props.text', 'Hello'),
      ('state total=0\nColumn\n  Text "Total: {total}"', 'text', 'props.text', r'Total: ${total}'),
      ('state n=0\nColumn\n  Text "{n * 2} left"', 'text', 'props.text', r'${= n * 2} left'),
      ('state plan="pro"\nColumn\n  Text "{plan == "pro" ? "Pro" : "Free"}"', 'text', 'props.text', r'${= plan == "pro" ? "Pro" : "Free"}'),
      ('Column\n  Text "Say \\"hi\\""', 'text', 'props.text', 'Say "hi"'),
    ]);
    _cases('a label', [
      ('Column\n  Button "Save"', 'filledButton', 'props.label', 'Save'),
      ('state count=0\nColumn\n  Button "Add {count}"', 'filledButton', 'bind.props.label', r'Add ${count}'),
      ('Column\n  Toggle "Wi-Fi"', 'switch', 'props.label', 'Wi-Fi'),
      ('Column\n  Checkbox "Agree"', 'checkbox', 'props.label', 'Agree'),
      ('Column\n  Icon "star"', 'icon', 'props.icon', 'star'),
      ('Column\n  Input "Email"', 'textField', 'props.decoration.labelText', 'Email'),
    ]);
  });

  group('a text\'s style', () {
    _cases('', [
      ('Column\n  Text "x" size=18', 'text', 'props.style.fontSize', 18),
      ('Column\n  Text "x" weight=700', 'text', 'props.style.fontWeight', 700),
      // A style a named one is a word away from is that one: Text.strong is the body at 600.
      ('Column\n  Text.strong "x"', 'text', 'props.style.fontWeight', 600),
      ('Column\n  Text "x" color=#FF2563EB', 'text', 'props.style.color', '#FF2563EB'),
      ('Column\n  Text "x" fontFamily=monospace', 'text', 'props.style.fontFamily', 'monospace'),
      ('Column\n  Text "x" fontFamily="SF Pro"', 'text', 'props.style.fontFamily', 'SF Pro'),
      ('Column\n  Text "x" lineHeight=1.4', 'text', 'props.style.height', 1.4),
      ('Column\n  Text "x" italic', 'text', 'props.style.fontStyle', 'italic'),
      ('Column\n  Text "x" underline', 'text', 'props.style.decoration', 'underline'),
      ('Column\n  Text "x" strike', 'text', 'props.style.decoration', 'lineThrough'),
      ('Column\n  Text "x" decoration=overline', 'text', 'props.style.decoration', 'overline'),
      ('Column\n  Text.title "x" color=#FF2563EB', 'text', 'props.style.fontSize', 20),
      ('Column\n  Text "x" center', 'text', 'props.textAlign', 'center'),
      ('Column\n  Text "x" right', 'text', 'props.textAlign', 'right'),
      ('Column\n  Text "x" maxLines=2 overflow=ellipsis', 'text', 'props.overflow', 'ellipsis'),
    ]);
  });

  group('a row\'s and a column\'s words', () {
    _cases('', [
      ('Column gap=12', 'column', 'props.spacing', 12),
      ('Column\n  Column start', 'column', 'props.mainAxisAlignment', 'start'),
      ('Column\n  Column middle', 'column', 'props.mainAxisAlignment', 'center'),
      ('Column\n  Column end', 'column', 'props.mainAxisAlignment', 'end'),
      ('Column\n  Column between', 'column', 'props.mainAxisAlignment', 'spaceBetween'),
      ('Column\n  Column around', 'column', 'props.mainAxisAlignment', 'spaceAround'),
      ('Column\n  Column evenly', 'column', 'props.mainAxisAlignment', 'spaceEvenly'),
      ('Column\n  Column center', 'column', 'props.crossAxisAlignment', 'center'),
      ('Column\n  Column right', 'column', 'props.crossAxisAlignment', 'end'),
      ('Column\n  Column stretch', 'column', 'props.crossAxisAlignment', 'stretch'),
      ('Column\n  Column scroll', 'column', 'props.scrollable', true),
      ('Column\n  Column clip', 'column', 'props.clipBehavior', 'antiAlias'),
      ('Column\n  Row center', 'row', 'props.mainAxisAlignment', 'center'),
      ('Column\n  Row end', 'row', 'props.mainAxisAlignment', 'end'),
      ('Column\n  Row between', 'row', 'props.mainAxisAlignment', 'spaceBetween'),
      ('Column\n  Row top', 'row', 'props.crossAxisAlignment', 'start'),
      ('Column\n  Row bottom', 'row', 'props.crossAxisAlignment', 'end'),
      ('Column\n  Row stretch', 'row', 'props.crossAxisAlignment', 'stretch'),
      ('Column\n  Row scroll', 'row', 'props.scrollDirection', 'horizontal'),
      ('Column\n  ListView gap=8', 'listView', 'props.spacing', 8),
    ]);
  });

  group('layout', () {
    _cases('', [
      ('Column\n  Text "x" pad=8', 'text', 'layout.padding', 8),
      ('Column\n  Text "x" pad=[4,8,4,8]', 'text', 'layout.padding', [4, 8, 4, 8]),
      ('Column\n  box w=40 h=40', 'box', 'layout.width', 40),
      ('Column\n  Text "x" w=hug', 'text', 'layout.width', {'hug': 0}),
      ('Column center\n  Text "x" w=fill', 'text', 'layout.width', {'fill': 0}),
      ('Column\n  Row\n    Text "x" w=fill', 'text', 'layout.width', {'fill': 0}),
      ('Column\n  Text "x" w={"fill":390}', 'text', 'layout.width', {'fill': 390}),
      ('Column\n  Row h=60\n    box w=40 h=fill', 'box', 'layout.height', {'fill': 0}),
      ('Column\n  Text "x" h={"hug":18}', 'text', 'layout.height', {'hug': 18}),
      ('Column\n  Text "x" w={"flexible":320}', 'text', 'layout.width', {'flexible': 320}),
      ('Column\n  Row\n    Text "x" grow', 'text', 'layout.flex', 1),
      ('Column\n  Row\n    Text "x" grow=2', 'text', 'layout.flex', 2),
      // A text in a row shrinks when its width is not written; this one may not.
      ('Column\n  Row\n    Text "x" w=hug', 'text', 'layout.squeezable', null),
      ('Column\n  Row\n    Text "x"', 'text', 'layout.squeezable', true),
      ('Column\n  Text "x" margin=[0,8,0,8]', 'text', 'layout.margin', [0, 8, 0, 8]),
      ('Column\n  Stack w=200 h=200\n    box w=40 h=40 x=10 y=20', 'box', 'layout.y', 20),
      ('Column\n  Stack w=200 h=200\n    box w=40 h=40 x={"end":16} y={"align":0}', 'box', 'layout.x', {'end': 16}),
      ('Column\n  Row\n    Text "x" align=topCenter', 'text', 'layout.align', 'topCenter'),
      ('Column\n  Text "x" order=2', 'text', 'layout.order', 2),
      ('Column\n  Text "x" basis=280', 'text', 'layout.basis', 280),
      ('Column\n  box h=40 aspectRatio=1.5', 'box', 'layout.aspectRatio', 1.5),
      ('Column\n  Column maxw=720', 'column', 'layout.constraints.maxWidth', 720),
      ('Column\n  Column minHeight=40 maxw=720', 'column', 'layout.constraints.minHeight', 40),
    ]);
  });

  group('decoration', () {
    _cases('', [
      ('Column\n  box w=40 h=40 fill=#FF2563EB', 'box', 'decoration.fills[0].color', '#FF2563EB'),
      ('Column\n  box w=40 h=40 fill=primary', 'box', 'decoration.fills[0].color', 'primary'),
      ('Column\n  box w=40 h=40 gradient=["#FF7C3AED","#FFEC4899"]', 'box', 'decoration.fills[0].stops[1].color', '#FFEC4899'),
      (
        'Column\n  box w=40 h=40 gradient={"colors":["#FF7C3AED","#FFEC4899"],"begin":"topCenter","end":"bottomCenter"}',
        'box',
        'decoration.fills[0].end',
        'bottomCenter',
      ),
      (
        'Column\n  box w=40 h=40 fills=[{"type":"radial","stops":[{"position":0,"color":"#FFFDE68A"},{"position":1,"color":"#FFF97316"}]}]',
        'box',
        'decoration.fills[0].type',
        'radial',
      ),
      ('Column\n  box w=40 h=40 border=#FFE5E7EB', 'box', 'decoration.strokes[0].color', '#FFE5E7EB'),
      ('Column\n  Row border-bottom=#FFE5E7EB', 'row', 'decoration.strokeSides', 'bottom'),
      ('Column\n  box w=40 h=40 border=#FF2563EB strokeWidth=2', 'box', 'decoration.strokeWidth', 2),
      ('Column\n  box w=40 h=40 strokes=[{"color":"#FF2563EB"},{"color":"#FF111827"}]', 'box', 'decoration.strokes[1].color', '#FF111827'),
      ('Column\n  box w=40 h=40 radius=8', 'box', 'decoration.radius', 8),
      ('Column\n  box w=40 h=40 radius=[8,8,0,0]', 'box', 'decoration.radius', [8, 8, 0, 0]),
      (
        'Column\n  box w=40 h=40 effects=[{"type":"dropShadow","color":"#33000000","offset":[0,4],"blurRadius":16}]',
        'box',
        'decoration.effects[0].blurRadius',
        16,
      ),
      ('Column\n  box w=40 h=40 clip=antiAlias', 'box', 'decoration.clip', 'antiAlias'),
      ('Column\n  box w=40 h=40 shape=circle', 'box', 'decoration.shape', 'circle'),
    ]);
  });

  group('props by their own names', () {
    _cases('', [
      ('Column\n  Input "Notes" maxLines=4', 'textField', 'props.maxLines', 4),
      ('Column\n  Input "Email" keyboardType=emailAddress', 'textField', 'props.keyboardType', 'emailAddress'),
      ('Column\n  Select items=["S","M","L"]', 'dropdown', 'props.items', ['S', 'M', 'L']),
      ('Column\n  Icon "star" size=22 color=#FFF59E0B', 'icon', 'props.size', 22),
      ('Column\n  Progress value=0.4', 'progressBar', 'props.value', 0.4),
      ('Column\n  Slider min=0 max=10', 'slider', 'props.max', 10),
      ('Column\n  Checkbox "Agree" value=true', 'checkbox', 'props.value', true),
      ('Column\n  gridView cols=3','gridView', 'props.crossAxisCount', 3),
      ('Column\n  Text "x" style=caption', 'text', 'props.style', 'caption'),
      // A prop bound to a text with values in it.
      ('state k=""\nColumn\n  Text "x" shortcut="Ctrl+{k}"', 'text', 'bind.props.shortcut', r'Ctrl+${k}'),
    ]);
  });

  test('every prop of every node type (a number, a flag, a text, a choice) is written with no tail', () {
    // Named as a word of the notation's: gap (a spacing) and animate (an
    // animation). By their full path once the parser reads one (Keys).
    bool word(String key) => key == 'gap' || key == 'animate';
    // Defaults the parser gives from another prop (a progress bar's max from
    // its value, a grid's row height from mainAxisExtent).
    const coupled = {'progressBar.value', 'progressBar.max', 'gridView.mainAxisExtent'};
    var said = 0;
    for (final w in standardCatalog.widgets) {
      final t = w.type;
      if (const {'canvas', 'pageView', 'radialGauge'}.contains(t) || t[0].toUpperCase() == t[0]) continue;
      final base = _expand('Column\n  $t');
      final id = readMap(base['nodes'])!.entries.firstWhere((e) => readMap(e.value)?['type'] == t).key;
      for (final p in w.props) {
        final Object? v = switch (p.type.kind) {
          PropKind.number || PropKind.integer => 3,
          PropKind.boolean => p.defaultValue != true,
          PropKind.string => 'abc',
          PropKind.enumeration when p.type.values.length > 1 => p.type.values.firstWhere((x) => x != p.defaultValue),
          _ => null,
        };
        if (v == null || word(p.key) || coupled.contains('$t.${p.key}')) continue;
        final doc = readMap(jsonDecode(jsonEncode(base)))!;
        final n = readMap(readMap(doc['nodes'])![id])!;
        n['props'] = {...?readMap(n['props']), p.key: v};
        readMap(doc['nodes'])![id] = n;
        // The line under the column (its id, the one the parser gives, is not written).
        final lines = printNotation(doc, catalog: standardCatalog).split('\n');
        final line = lines[lines.indexWhere((l) => l.startsWith('Column')) + 1];
        expect(line, isNot(contains('{"')), reason: '$t.${p.key}=$v');
        said++;
      }
    }
    expect(said, greaterThan(700));
  });

  group('an Input\'s words', () {
    _cases('', [
      ('Column\n  Input "Email" hint="you@example.com"', 'textField', 'props.decoration.hintText', 'you@example.com'),
      ('Column\n  Input "Email" helper="We never share it"', 'textField', 'props.decoration.helperText', 'We never share it'),
      ('Column\n  Input "Email" error=Required', 'textField', 'props.decoration.errorText', 'Required'),
      // A search field's string is its hint, not a label.
      ('Column\n  Input "" hint=Search icon=search', 'textField', 'props.decoration.prefixIcon.icon', 'search'),
      ('Column\n  Input "Price" prefix=USD', 'textField', 'props.decoration.prefixText', 'USD'),
      ('Column\n  Input "Password" password', 'textField', 'props.obscureText', true),
      ('Column\n  Input "Code" size=15 weight=600 color=#FF111827', 'textField', 'props.style.fontWeight', 600),
      ('Column\n  Input "Code" fontFamily=monospace lineHeight=1.5 letterSpacing=0.5', 'textField', 'props.style.letterSpacing', 0.5),
      // A field of its decoration no word says is written by its path from the props.
      ('Column\n  Input hint=Search decoration.isDense=true', 'textField', 'props.decoration.isDense', true),
    ]);
  });

  group('a button\'s colours', () {
    _cases('', [
      ('Column\n  Button "Save" color=#FF16A34A', 'filledButton', 'props.style.backgroundColor', '#FF16A34A'),
      ('Column\n  Button.outline "Cancel" color=#FFDC2626', 'outlinedButton', 'props.style.foregroundColor', '#FFDC2626'),
      (
        'Column\n  Button "Save" style={"backgroundColor":"#FF16A34A","foregroundColor":"#FFFFFFFF","elevation":2}',
        'filledButton',
        'props.style.elevation',
        2,
      ),
      ('Column\n  IconButton "close" color=#FF6B7280 size=18', 'iconButton', 'props.style.iconSize', 18),
    ]);
  });

  group('the node\'s own fields and behaviors', () {
    _cases('', [
      ('Column\n  Text "x" hidden', 'text', 'visible', false),
      ('Column\n  Text "x" opacity=0.5', 'text', 'opacity', 0.5),
      ('Column\n  Text "x" tooltip="More"', 'text', 'tooltip', 'More'),
      ('state who=""\nColumn\n  Text "x" tooltip="Hi {who}"', 'text', 'tooltip', r'Hi ${who}'),
      ('Column scroll\n  Row sticky', 'row', 'sticky.offset', 0),
      ('Column scroll\n  Row sticky=16', 'row', 'sticky.offset', 16),
      ('Column\n  Toggle "Wi-Fi" readOnly', 'switch', 'ignorePointer', true),
      ('Column\n  box w=40 h=40 drag=cards', 'box', 'draggable.group', 'cards'),
      ('state card=""\nColumn\n  box w=40 h=40 drag=cards(card)', 'box', 'draggable.data', r'${card}'),
      ('Column\n  box w=40 h=40 drop=cards,done', 'box', 'dropTarget.accepts', ['cards', 'done']),
    ]);
  });

  group('bindings', () {
    _cases('', [
      ('state on=false\nColumn\n  Text "x" visible={on}', 'text', 'bind.visible', r'${on}'),
      ('state on=false\nColumn\n  Text "x" visible={!on}', 'text', 'bind.visible', r'${= !on}'),
      ('state on=false\nColumn\n  Text "x" opacity={on ? 1 : 0.5}', 'text', 'bind.opacity', r'${= on ? 1 : 0.5}'),
      ('state name=""\nColumn\n  Text text={upper(name)}', 'text', 'bind.props.text', r'${= upper(name)}'),
      ('state on=false\nColumn\n  Text "x" color={on ? "#FF16A34A" : "#FF6B7280"}', 'text', 'bind.props.style.color', r'${= on ? "#FF16A34A" : "#FF6B7280"}'),
      ('state on=false\nColumn\n  Text "x" size={on ? 18 : 13}', 'text', 'bind.props.style.fontSize', r'${= on ? 18 : 13}'),
      ('state on=false\nColumn\n  Text "x" weight={on ? 700 : 400}', 'text', 'bind.props.style.fontWeight', r'${= on ? 700 : 400}'),
      ('state on=false\nColumn\n  box w=40 h=40 fill={on ? "#FF16A34A" : "#FFE5E7EB"}', 'box', 'decoration.fills[0].color', '#00000000'),
      // (A key is written once: the value under a binding of it by the field's whole value or path.)
      ('state on=false\nColumn\n  box w=40 h=40 fills=[{"color":"#FFE5E7EB"}] fill={on ? "#FF16A34A" : "#FFE5E7EB"}', 'box', 'decoration.fills[0].color', '#FFE5E7EB'),
      ('state on=false\nColumn\n  box w=40 h=40 border={on ? "#FF16A34A" : "#FFE5E7EB"}', 'box', 'bind.decoration.strokes[0].color', r'${= on ? "#FF16A34A" : "#FFE5E7EB"}'),
      ('state on=false\nColumn\n  box w=40 h=40 border=#FFE5E7EB strokeWidth={on ? 2 : 1}', 'box', 'bind.decoration.strokeWidth', r'${= on ? 2 : 1}'),
      ('state on=false\nColumn\n  box w=40 h=40 decoration.radius=8 radius={on ? 8 : 0}','box', 'bind.decoration.radius', r'${= on ? 8 : 0}'),
      ('state shadow=[]\nColumn\n  box w=40 h=40 effects={shadow}', 'box', 'bind.decoration.effects', r'${shadow}'),
      ('state size=40\nColumn\n  box h=40 w={size}', 'box', 'bind.layout.width', r'${size}'),
      ('state at=0\nColumn\n  Stack w=200 h=200\n    box w=40 h=40 x={at}', 'box', 'bind.layout.x', r'${at}'),
      ('state m=0\nColumn\n  Text "x" margin={m}', 'text', 'bind.layout.margin', r'${m}'),
      ('state p=0\nColumn\n  Text "x" pad={p}', 'text', 'bind.layout.padding', r'${p}'),
      ('state share=1\nColumn\n  Row\n    box h=8 grow grow={share}', 'box', 'bind.layout.flex', r'${share}'),
      ('state fav=false\nColumn\n  IconButton "star" selected={fav}', 'iconButton', 'bind.selected', r'${= fav}'),
      ('state done=0\nColumn\n  Progress value={done / 4}', 'progressBar', 'bind.props.value', r'${= done / 4}'),
      ('state limit=10\nColumn\n  Slider max={limit}', 'slider', 'bind.props.max', r'${limit}'),
      ('state mode=""\nColumn\n  Input "Note" hint={mode}', 'textField', 'bind.props.decoration.hintText', r'${mode}'),
      ('state ok=false\nColumn\n  Button "Save" color={ok ? "#FF16A34A" : "#FF9CA3AF"}', 'filledButton', 'bind.props.style.backgroundColor', r'${= ok ? "#FF16A34A" : "#FF9CA3AF"}'),
    ]);
  });

  group('a control\'s variable', () {
    _cases('@name', [
      ('state volume=0.5\nColumn\n  Slider @volume', 'slider', 'bind.props.value', r'${volume}'),
      ('state wifi=false\nColumn\n  Toggle "Wi-Fi" @wifi', 'switch', 'bind.props.value', r'${wifi}'),
      ('state email=""\nColumn\n  Input "Email" @email', 'textField', 'bind.props.initialValue', r'${email}'),
      ('state size=""\nColumn\n  Select @size items=["S","M"]','dropdown', 'bind.props.value', r'${size}'),
      // The binding and the reaction are one word, the events' (design 22, 4.2).
    ]);

    test('the reaction @name writes is the one the events leave out', () {
      final doc = _expand('state volume=0.5\nColumn\n  Slider @volume');
      final nodes = readMap(doc['nodes'])!;
      final id = nodes.keys.firstWhere((k) => readMap(nodes[k])?['type'] == 'slider');
      final context = PrintContext(document: doc, catalog: standardCatalog, options: notationOptionsFor(doc));
      expect(printedBindReaction(id, readMap(nodes[id])!, context), 0);
      final column = nodes.keys.firstWhere((k) => readMap(nodes[k])?['type'] == 'column');
      expect(printedBindReaction(column, readMap(nodes[column])!, context), isNull);
    });
  });

  group('a field by its own name (design 22, 2.1)', () {
    Json doc(Json node) => {
          'schema': 3,
          'roots': ['screen'],
          'nodes': {
            'screen': {'type': 'canvas', 'slots': {'body': 'col'}, 'layout': {'width': 390, 'height': 800}},
            'col': {'type': 'column', 'children': ['n'], 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'crossAxisAlignment': 'start'}},
            'n': node,
          },
        };

    final cases = <(Json, String)>[
      ({'type': 'text', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'text': 'x', 'style': {'fontSize': 13, 'color': '#FF111827', 'letterSpacing': 0.4}}}, 'letterSpacing=0.4'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40, 'columnSpan': 2}}, 'columnSpan=2'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40, 'rowSpan': 2, 'columnStart': 1, 'rowStart': 3}}, 'rowSpan=2 columnStart=1 rowStart=3'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'decoration': {'strokes': [{'color': '#FF000000'}], 'strokeCap': 'round'}}, 'strokeCap=round'),
      ({'type': 'tabBar', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'gap': 3}}, 'props.gap=3'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'decoration': {'strokes': [{'color': '#FF000000'}], 'strokeSides': 'topBottom'}}, 'strokeSides=topBottom'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'decoration': {'strokes': [{'color': '#FF000000'}], 'dashPattern': [6, 4]}}, 'dashPattern=[6,4]'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'decoration': {'strokes': [{'color': '#FF000000'}], 'strokeAlign': 'outside'}}, 'strokeAlign=outside'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'decoration': {'blendMode': 'multiply'}}, 'blendMode=multiply'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40, 'constraints': {'minHeight': 40, 'maxWidth': 720}}}, 'minHeight=40 maxw=720'),
      // A behavior (ignorePointer, floating, inkWell…) is the states family's,
      // written by the keys' names with or without fieldNames: states_test.dart.
      ({'type': 'progressBar', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'max': 1, 'borderRadius': 2, 'color': '#FF2563EB', 'backgroundColor': '#FFE5E7EB', 'animate': true}}, 'props.animate=true'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'bind': {'motion.scale': r'${= on ? 1.1 : 1}'}}, 'motion.scale={on ? 1.1 : 1}'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'bind': {'layout.columnSpan': r'${span}'}}, 'columnSpan={span}'),
      ({'type': 'box', 'layout': {'width': 40, 'height': 40}, 'bind': {'decoration.effects[0].color': r'${glow}'}}, 'effects[0].color={glow}'),
      ({'type': 'textField', 'layout': {'width': {'fill': 0}, 'height': {'hug': 0}}, 'props': {'decoration': {'labelText': 'Search', 'isDense': true}}}, '"Search" decoration.isDense=true'),
      ({'type': 'text', 'layout': {'width': 120, 'height': {'hug': 0}, 'squeezable': true}, 'props': {'text': 'x', 'style': {'fontSize': 13, 'color': '#FF111827'}}}, 'squeezable=true'),
    ];

    for (final (node, word) in cases) {
      test('$word reads back', () {
        final d = doc(node);
        final printed = printNotation(d, catalog: standardCatalog);
        expect(printed, contains(word));
        // No tail (a word's own JSON, inkWell={…}, is no tail).
        expect(printed, isNot(contains(' {"')), reason: printed);
      });
    }
  });
}
