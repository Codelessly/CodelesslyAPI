// Name conformance: how many of the model's field names are Flutter's.
//
//   dart run tool/name_conformance.dart [--flutter /opt/flutter] [--unclassified | --matched | --detail]
//
// Without a flag: the summary tables (docs/design/10-audit-verdict.md, "Name
// conformance, re-measured"). --detail: every field not in (a), with its
// verdict (docs/design/name-conformance.md). --matched: the (a) fields per
// group. --unclassified: fields still to be given a verdict.
//
// Method. Every declared field (a PropDef) of each group below is put in one
// of four classes:
//
//   (a) Flutter's name and meaning: the name is a constructor parameter,
//       public field or getter of one of the Flutter classes the group
//       mirrors (read from the Flutter SDK's source, so it is re-measured
//       against the Flutter in use), and no verdict below says otherwise;
//   (b) a Flutter concept under another name (the verdict names Flutter's);
//   (c) no Flutter counterpart, and general (any app could use it);
//   (d) no Flutter counterpart, and a special case.
//
// Only (a) is decided by the script; (b), (c) and (d) are the verdicts in
// [_verdicts], written by reading each field's declaration. A field that is
// not (a) and has no verdict is "unclassified" and listed with
// --unclassified; the measurement is complete when there are none.
//
// Groups: every node type whose declaration names a Flutter widget (its
// doc starts "Flutter `X`"), each counted on its own (a prop several types
// share counts once per type, as each type is a surface an author writes);
// and the shared groups layout, decoration, text style, motion (Transform),
// hero (Hero), customPaint (CustomPaint), its paint (dart:ui Paint) and its
// draw ops (Canvas, Path).
//
// The output is Markdown.
import 'dart:io';

import 'package:codelessly_api/codelessly_api.dart';

void main(List<String> args) {
  final listA = args.contains('--matched');
  String? option(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final flutter = option('--flutter') ?? '/opt/flutter';
  final index = FlutterIndex([
    '$flutter/packages/flutter/lib/src',
    '$flutter/bin/cache/pkg/sky_engine/lib/ui',
  ]);
  final groups = conformanceGroups();
  final results = [for (final g in groups) g.classify(index)];
  if (listA) {
    for (final r in results) {
      stdout.writeln('${r.group.name}: ${[for (final f in r.fields) if (f.kind == 'a') f.name].join(' ')}');
    }
    return;
  }
  if (args.contains('--unclassified')) {
    final by = <String, List<String>>{};
    for (final r in results) {
      for (final f in r.fields.where((f) => f.kind == null)) {
        (by[f.name] ??= []).add(r.group.name);
      }
    }
    for (final e in by.entries) {
      stdout.writeln('${e.key}: ${e.value.join(' ')}');
    }
    return;
  }
  stdout.write(args.contains('--detail') ? detail(results) : markdown(results, index));
}

// --- Flutter's names ------------------------------------------------------------------

/// The member names of Flutter's classes, read from source: constructor
/// parameters (of every constructor), public fields and getters. A
/// `Class.method` names that method's parameters.
final class FlutterIndex {
  FlutterIndex(List<String> roots) {
    for (final root in roots) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        _index(_stripComments(f.readAsStringSync()));
      }
    }
  }

  final Map<String, String> _bodies = {};

  /// Whether class [name] was found.
  bool has(String name) => _bodies.containsKey(name.split('.').first);

  static String _stripComments(String s) => s
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .split('\n')
      .map((l) {
        final i = l.indexOf('//');
        return i < 0 ? l : l.substring(0, i);
      })
      .join('\n');

  void _index(String src) {
    for (final m in RegExp(r'^(?:abstract |final |base |sealed |interface |mixin )*(?:class|mixin) (\w+)', multiLine: true).allMatches(src)) {
      final open = src.indexOf('{', m.end);
      if (open < 0) continue;
      var depth = 0;
      var i = open;
      for (; i < src.length; i++) {
        final c = src[i];
        if (c == '{') depth++;
        if (c == '}' && --depth == 0) break;
      }
      // The header too: `class X extends Y` is not needed, but a class may be
      // declared twice (an interface and an implementation): keep both.
      _bodies.update(m[1]!, (b) => '$b\n${src.substring(open, i)}', ifAbsent: () => src.substring(open, i));
    }
  }

  final Map<String, Set<String>> _cache = {};

  /// The member names of class [name], or of method `Class.method`'s
  /// parameters.
  Set<String> members(String name) => _cache.putIfAbsent(name, () {
        final dot = name.indexOf('.');
        final cls = dot < 0 ? name : name.substring(0, dot);
        final body = _bodies[cls];
        if (body == null) return const {};
        if (dot >= 0) {
          final method = name.substring(dot + 1);
          final out = <String>{};
          for (final m in RegExp('\\b$method\\s*\\(').allMatches(body)) {
            out.addAll(_params(body, m.end - 1));
          }
          return out;
        }
        final out = <String>{};
        for (final m in RegExp(r'\b(?:this|super)\.(\w+)').allMatches(body)) {
          out.add(m[1]!);
        }
        for (final m in RegExp(r'\bfinal\s+[\w<>?,\s.]+?\s(\w+)\s*;').allMatches(body)) {
          out.add(m[1]!);
        }
        for (final m in RegExp(r'\bget\s+(\w+)').allMatches(body)) {
          out.add(m[1]!);
        }
        // Constructors' own parameters (`required double angle`).
        for (final m in RegExp('(?:const\\s+|factory\\s+)?\\b$cls(?:\\.\\w+)?\\s*\\(').allMatches(body)) {
          out.addAll(_params(body, m.end - 1));
        }
        return out..removeWhere((n) => n.startsWith('_'));
      });

  /// The parameter names of the list opening at [open] (a `(`).
  static Set<String> _params(String s, int open) {
    var depth = 0;
    var i = open;
    for (; i < s.length; i++) {
      final c = s[i];
      if (c == '(' || c == '{' || c == '[' || c == '<') depth++;
      if (c == ')' || c == '}' || c == ']' || c == '>') {
        if (--depth == 0) break;
      }
    }
    final inner = s.substring(open + 1, i.clamp(open + 1, s.length));
    // Split at top-level commas.
    final parts = <String>[];
    var d = 0, start = 0;
    for (var j = 0; j < inner.length; j++) {
      final c = inner[j];
      if (c == '(' || c == '[' || c == '<') d++;
      if (c == ')' || c == ']' || c == '>') d--;
      if (c == ',' && d == 0) {
        parts.add(inner.substring(start, j));
        start = j + 1;
      }
    }
    parts.add(inner.substring(start));
    final out = <String>{};
    for (var p in parts) {
      p = p.replaceAll(RegExp(r'[{}\[\]]'), ' ').split('=').first.trim();
      final m = RegExp(r'(\w+)\s*$').firstMatch(p);
      if (m != null) out.add(m[1]!.replaceFirst(RegExp(r'^(this|super)$'), ''));
      final dotted = RegExp(r'\b(?:this|super)\.(\w+)').firstMatch(p);
      if (dotted != null) out.add(dotted[1]!);
    }
    return out..removeWhere((n) => n.isEmpty || n.startsWith('_'));
  }
}

// --- the groups -----------------------------------------------------------------------

/// A group of fields and the Flutter classes it mirrors.
final class Group {
  Group(this.name, this.fields, this.flutter, {this.shared = false});

  /// `node:slider`, `layout`, `drawOp:circle`...
  final String name;
  final List<String> fields;

  /// Flutter classes (or `Class.method`s) whose names count as (a).
  final List<String> flutter;
  final bool shared;

  GroupResult classify(FlutterIndex index) {
    final names = {for (final c in flutter) ...index.members(c)};
    return GroupResult(this, [
      for (final f in fields) _classify(f, names),
    ], missing: [for (final c in flutter) if (!index.has(c)) c]);
  }

  FieldResult _classify(String field, Set<String> names) {
    // A verdict for this group decides; a shared one (`node:*/`,
    // `drawOp:*/`) only for a field whose name is not Flutter's here.
    final own = _verdicts['$name/$field'];
    final prefix = name.contains(':') ? name.substring(0, name.indexOf(':') + 1) : null;
    final verdict = own ?? (names.contains(field) || prefix == null ? null : _verdicts['$prefix*/$field']);
    if (verdict == null) return FieldResult(field, names.contains(field) ? 'a' : null, '');
    return FieldResult(field, verdict[0], verdict.substring(2));
  }
}

final class FieldResult {
  FieldResult(this.name, this.kind, this.note);
  final String name;

  /// `a`, `b`, `c`, `d`; null: unclassified.
  final String? kind;
  final String note;
}

final class GroupResult {
  GroupResult(this.group, this.fields, {this.missing = const []});
  final Group group;
  final List<FieldResult> fields;

  /// Flutter classes not found in the source read.
  final List<String> missing;

  int count(String? kind) => fields.where((f) => f.kind == kind).length;
}

/// The Flutter class a widget declaration names (its doc's first words).
String? flutterOf(WidgetSpec spec) => RegExp(r'^Flutter `([A-Za-z][\w.<>]*)`').firstMatch(spec.doc)?.group(1);

/// Theme and style classes whose fields a node type's props also take
/// (a slider's colors are `SliderThemeData`'s), by node type.
const Map<String, List<String>> _alsoFlutter = {
  'canvas': ['Scaffold'],
  'stack': ['Stack', 'SingleChildScrollView', 'ScrollView'],
  'row': ['Flex', 'Wrap', 'SingleChildScrollView', 'ScrollView'],
  'column': ['Flex', 'Wrap', 'SingleChildScrollView', 'ScrollView'],
  'flex': ['Flex', 'Wrap', 'SingleChildScrollView', 'ScrollView'],
  'text': ['Text', 'RichText', 'SelectableText'],
  'listView': ['ListView', 'BoxScrollView', 'ScrollView', 'Wrap', 'Divider'],
  'gridView': ['GridView', 'BoxScrollView', 'ScrollView', 'SliverGridDelegateWithFixedCrossAxisCount', 'SliverGridDelegateWithMaxCrossAxisExtent'],
  'pageView': ['PageView', 'PageController'],
  'tabBar': ['TabBar', 'TabBarThemeData', 'UnderlineTabIndicator', 'Tab', 'DefaultTabController'],
  'expansionTile': ['ExpansionTile', 'ExpansionTileThemeData'],
  'textField': ['TextField', 'EditableText', 'TextFormField', 'FormField'],
  'checkbox': ['Checkbox', 'CheckboxThemeData'],
  'switch': ['Switch', 'SwitchThemeData'],
  'radio': ['Radio', 'RadioThemeData'],
  'slider': ['Slider', 'SliderThemeData'],
  'dropdown': ['DropdownButton', 'DropdownButtonFormField', 'DropdownMenuItem'],
  'datePicker': ['DatePickerDialog', 'DatePickerThemeData'],
  'timePicker': ['TimePickerDialog', 'TimePickerThemeData', 'MediaQueryData'],
  'dateTimeInput': ['InputDecorator', 'InputDecoration'],
  'segmentedButton': ['SegmentedButton', 'SegmentedButtonThemeData', 'ButtonSegment', 'ButtonStyle'],
  'elevatedButton': ['ElevatedButton', 'ButtonStyleButton'],
  'filledButton': ['FilledButton', 'ButtonStyleButton'],
  'textButton': ['TextButton', 'ButtonStyleButton'],
  'outlinedButton': ['OutlinedButton', 'ButtonStyleButton'],
  'iconButton': ['IconButton'],
  'floatingActionButton': ['FloatingActionButton', 'FloatingActionButtonThemeData', 'Scaffold'],
  'chip': ['Chip', 'RawChip', 'ChipThemeData'],
  'actionChip': ['ActionChip', 'RawChip', 'ChipThemeData'],
  'choiceChip': ['ChoiceChip', 'RawChip', 'ChipThemeData'],
  'filterChip': ['FilterChip', 'RawChip', 'ChipThemeData'],
  'inputChip': ['InputChip', 'RawChip', 'ChipThemeData'],
  'badge': ['Badge', 'BadgeThemeData'],
  'listTile': ['ListTile', 'ListTileThemeData'],
  'appBar': ['AppBar', 'AppBarTheme'],
  'navigationBar': ['NavigationBar', 'NavigationBarThemeData'],
  'bottomNavigationBar': ['BottomNavigationBar', 'BottomNavigationBarThemeData'],
  'divider': ['Divider', 'DividerThemeData'],
  'verticalDivider': ['VerticalDivider', 'DividerThemeData'],
  'circularProgressIndicator': ['CircularProgressIndicator', 'ProgressIndicator', 'ProgressIndicatorThemeData'],
  'activityIndicator': ['CupertinoActivityIndicator'],
  'path': ['CustomPaint', 'Path', 'Paint'],
  'modal': ['showDialog', 'Dialog'],
};

/// The groups measured.
List<Group> conformanceGroups() {
  List<String> keys(List<PropDef<Object?>> defs) => [for (final d in defs) d.key];
  return [
    Group('layout', keys(LayoutFields.all),
        ['Padding', 'SizedBox', 'ConstrainedBox', 'Container', 'AspectRatio', 'Flexible', 'Expanded', 'Positioned', 'Align'],
        shared: true),
    Group('decoration', keys(DecorationFields.all), ['BoxDecoration', 'ShapeDecoration', 'Border', 'BorderSide', 'DecoratedBox', 'ClipRRect'],
        shared: true),
    Group('textStyle', keys(TextStyleFields.all), ['TextStyle'], shared: true),
    Group('motion', keys(MotionFields.all), ['Transform', 'FractionalTranslation'], shared: true),
    Group('hero', keys(HeroTagFields.all), ['Hero'], shared: true),
    Group('customPaint', keys(CustomPaintFields.all), ['CustomPaint', 'FittedBox'], shared: true),
    Group('drawPaint', keys(DrawPaintFields.all), ['Paint'], shared: true),
    for (final op in DrawOpSpecs.all)
      Group('drawOp:${op.op}', [for (final f in [...DrawOpCommonFields.all, ...op.fields]) f.key], _opFlutter[op.op] ?? const [],
          shared: true),
    for (final spec in Widgets.all)
      if (flutterOf(spec) case final String f)
        Group('node:${spec.type}', keys(spec.props), [f.replaceAll('.rich', ''), ...?_alsoFlutter[spec.type]]),
  ];
}

const Map<String, List<String>> _opFlutter = {
  'path': ['Canvas.drawPath', 'Path', 'Path.addPolygon'],
  'line': ['Canvas.drawLine'],
  'rect': ['Canvas.drawRect'],
  'rrect': ['Canvas.drawRRect'],
  'circle': ['Canvas.drawCircle'],
  'oval': ['Canvas.drawOval'],
  'arc': ['Canvas.drawArc'],
  'points': ['Canvas.drawPoints'],
  'paragraph': ['Canvas.drawParagraph', 'TextPainter', 'TextPainter.layout', 'TextSpan'],
  'image': ['Canvas.drawImageRect'],
  'group': ['Canvas'],
  'repeat': [],
};

// --- the verdicts ---------------------------------------------------------------------

/// `group/field` (or `node:*/field`, `drawOp:*/field` for every node type
/// or draw op) → its class and why:
/// `b:<Flutter's name> — why`, `c:why`, `d:why`, `a:why` (Flutter's name
/// though the index does not find it, or found in a class the group does
/// not list).
const Map<String, String> _verdicts = {
  // layout
  'layout/squeezable': 'b:Flexible(fit: FlexFit.loose) — a hugging child that may shrink',
  'layout/x': 'b:Positioned(left:/right:) or Align — an AxisPosition (start, end or align) on one axis',
  'layout/y': 'b:Positioned(top:/bottom:) or Align — as x',
  'layout/align': 'b:Align(alignment:) around the child — its place in its slot of a row or column',
  'layout/order': 'c:CSS `order`: children laid out and painted by order, patched per screen size',
  'layout/basis': 'c:CSS `flex-basis` for a wrapping flex',
  // decoration
  'decoration/fills': 'b:BoxDecoration.color / gradient / image — a stack of paints, one list',
  'decoration/strokes': 'b:BoxDecoration.border (BorderSide.color) — a stack of paints for the border',
  'decoration/strokeWidth': 'b:BorderSide.width',
  'decoration/strokeSides': 'b:Border(top:, left:, ...) — which sides are drawn',
  'decoration/strokeCap': "a:Paint.strokeCap's name and meaning (Flutter's BorderSide has no cap: dashed borders need one)",
  'decoration/dashPattern': 'c:dashed borders; Flutter has none',
  'decoration/radius': 'b:BoxDecoration.borderRadius',
  'decoration/effects': 'b:BoxDecoration.boxShadow, BackdropFilter, ImageFiltered — shadows and blurs in one list',
  'decoration/clip': 'b:clipBehavior (Container.clipBehavior, ClipRRect)',
  'decoration/blendMode': 'b:BoxDecoration.backgroundBlendMode',
  'decoration/foregroundFills': 'b:DecoratedBox(position: DecorationPosition.foreground)',
  // text style
  'textStyle/from': 'b:Theme.of(context).textTheme.<name>.merge(...) — a named theme style it starts from',
  'textStyle/tabularFigures': 'b:fontFeatures: [FontFeature.tabularFigures()]',
  // motion
  'motion/translateX': 'b:Transform.translate(offset: Offset(x, 0))',
  'motion/translateY': 'b:Transform.translate(offset: Offset(0, y))',
  'motion/shiftX': 'b:FractionalTranslation(translation: Offset(x, 0))',
  'motion/shiftY': 'b:FractionalTranslation(translation: Offset(0, y))',
  'motion/rotate': 'b:Transform.rotate(angle:) — degrees, not radians',
  'motion/rotateX': 'b:Matrix4.rotationX in Transform(transform:) — degrees',
  'motion/rotateY': 'b:Matrix4.rotationY in Transform(transform:) — degrees',
  'motion/perspective': 'b:Matrix4..setEntry(3, 2, p) in Transform(transform:)',
  'motion/backfaceHidden': 'c:CSS backface-visibility for 3D turns',
  'motion/path': 'c:PathFollow, a pose along a path',
  // hero
  'hero/flies': 'c:a hero that flies in place (no navigation), which Flutter lacks',
  'hero/flightShuttle': 'b:Hero.flightShuttleBuilder — a named look instead of a builder',
  'hero/placeholder': 'b:Hero.placeholderBuilder — a named look instead of a builder',
  'hero/flight': 'c:how an in-place flight moves',
  // custom paint
  'customPaint/viewBox': 'c:SVG viewBox: the ops\' coordinate space',
  'drawPaint/id': 'c:a stable name for editor selection and binding paths',
  'drawPaint/dashPattern': 'c:dashing; Flutter has none (PathMetric.extractPath by hand)',
  'drawPaint/scaleStroke': 'c:SVG vector-effect: non-scaling-stroke',
  'drawOp:*/id': 'c:a stable name for editor selection and binding paths',
  'drawOp:*/when': 'c:drawn only while an expression holds',
  'drawOp:*/hit': 'c:a hit region (pointer reactions get its id)',
  'drawOp:path/d': 'c:SVG path data; Flutter has no SVG path parser',
  'drawOp:path/commands': 'c:the Path builder calls (moveTo, lineTo, cubicTo...) as a list',
  'drawOp:path/trimStart': 'c:the stroked share of the path (PathMetric.extractPath)',
  'drawOp:path/trimEnd': 'c:the stroked share of the path (PathMetric.extractPath)',
  'drawOp:rrect/rect': 'b:Canvas.drawRRect(RRect rrect) — the rect and radius of an RRect, apart',
  'drawOp:rrect/radius': 'b:Canvas.drawRRect(RRect rrect) — the rect and radius of an RRect, apart',
  'drawOp:paragraph/anchor': 'c:which point of the laid-out text sits at offset',
  'drawOp:paragraph/paint': 'b:TextStyle.foreground',
  'drawOp:image/url': 'c:an image by URL (Flutter takes a decoded ui.Image)',
  'drawOp:group/ops': 'c:the ops between save and restore',
  'drawOp:group/translate': 'a:Canvas.translate',
  'drawOp:group/scale': 'a:Canvas.scale',
  'drawOp:group/rotate': "a:Canvas.rotate (radians, as Flutter's)",
  'drawOp:group/transform': 'a:Canvas.transform',
  'drawOp:group/clipRect': 'a:Canvas.clipRect',
  'drawOp:group/clipRRect': 'a:Canvas.clipRRect',
  'drawOp:group/clipPath': 'a:Canvas.clipPath',
  'drawOp:group/opacity': 'b:Canvas.saveLayer(bounds, Paint()..color = alpha)',
  'drawOp:group/blendMode': 'b:Canvas.saveLayer(bounds, Paint()..blendMode)',
  'drawOp:repeat/ops': 'c:the ops drawn per item',
  'drawOp:repeat/each': 'c:a loop over a list',
  'drawOp:repeat/count': 'c:a loop a number of times',
  'drawOp:repeat/as': 'c:the loop item\'s name',
  'drawOp:repeat/indexAs': 'c:the loop index\'s name',
  // node types: shared props
  'node:*/scrollable': 'b:SingleChildScrollView around it (a list: shrinkWrap with NeverScrollableScrollPhysics when false)',
  'node:*/alwaysScroll': 'b:physics: AlwaysScrollableScrollPhysics()',
  'node:*/wrap': 'b:Wrap (the node lays out as one)',
  'node:*/squeezeChildren': 'c:CSS flex-shrink: overflowing children shrink to fit',
  'node:*/fillViewport': 'c:ConstrainedBox(minHeight: viewport) inside a SingleChildScrollView, the documented pattern',
  'node:*/query': 'c:where a list\'s items come from (a data-layer query; the vocabulary belongs to the data library)',
  'node:*/pagination': 'c:loads items page by page',
  'node:*/reorder': 'b:ReorderableListView (onReorder)',
  'node:*/enabled': 'b:a null onPressed / onChanged — a document has no callbacks to leave null',
  'node:*/borderRadius': 'b:shape: RoundedRectangleBorder(borderRadius:)',
  'node:*/compact': 'b:materialTapTargetSize: MaterialTapTargetSize.shrinkWrap with VisualDensity.compact',
  'node:*/variant': 'c:a non-Material look of the control (plain chip, sliding track)',
  'node:*/spacing': 'c:the gap between icon and label (Flutter fixes it)',
  'node:*/textAlign': 'a:Text.textAlign of the label',
  'node:*/avatarSize': 'b:avatarBoxConstraints',
  'node:*/avatarColor': 'c:the avatar\'s background',
  'node:*/notched': 'b:BottomAppBar(shape: CircularNotchedRectangle())',
  'node:*/notchMargin': 'a:BottomAppBar.notchMargin',
  'node:*/selectedLabelTextStyle': 'b:labelTextStyle as a WidgetStateProperty (selected)',
  'node:*/iconColor': 'b:iconTheme / unselectedItemColor',
  'node:*/selectedIconColor': 'b:selectedItemColor / iconTheme (selected)',
  'node:*/selectedIconSize': 'b:selectedIconTheme.size',
  'node:*/value': 'b:initialDate / initialTime',
  'node:*/format': 'c:an intl DateFormat pattern for the shown value',
  'node:*/pickerTheme': 'b:DatePickerThemeData / TimePickerThemeData',
  'node:*/style': 'a:TextField.style (the field\'s text)',
  'node:*/decoration': 'a:TextField.decoration (InputDecoration)',
  'node:*/radius': 'b:shape: RoundedRectangleBorder(borderRadius:)',
  // canvas (Scaffold)
  'node:canvas/scaleMode': 'c:how a design size fits another screen size',
  'node:canvas/blockBack': 'b:PopScope(canPop: false)',
  'node:canvas/breakpoint': 'c:responsive breakpoints',
  'node:canvas/screen': 'c:responsive breakpoints',
  'node:canvas/breakpointMinWidth': 'c:responsive breakpoints',
  'node:canvas/overlay': 'c:a screen drawn above every screen (Navigator overlay)',
  'node:canvas/backdrop': 'c:a screen drawn beneath every screen',
  'node:stack/fit': 'b:FittedBox(fit:) around the stack — a BoxFit for the board; Flutter\'s Stack.fit is a StackFit, another thing under the same name',
  'node:stack/fitAlignment': 'b:FittedBox.alignment',
  // text
  'node:text/runs': 'b:Text.rich(TextSpan(children:)) — ranges over one string instead of spans',
  'node:text/textAlignVertical': "a:TextField.textAlignVertical's name and meaning",
  'node:text/selectable': 'b:SelectableText (another widget)',
  'node:text/scaleDown': 'b:FittedBox(fit: BoxFit.scaleDown)',
  'node:text/countUp': 'd:a number that counts to its new value, with its own clock: a second animation mechanism',
  'node:text/countUpDuration': 'd:countUp\'s timing',
  'node:text/countUpCurve': 'd:countUp\'s timing',
  'node:text/countUpOnShow': 'd:countUp\'s timing',
  // listView
  'node:listView/separator': 'b:ListView.separated(separatorBuilder:)',
  'node:listView/dividerThickness': 'b:Divider.thickness as the separator',
  'node:listView/dividerColor': 'b:Divider.color as the separator',
  'node:listView/dividerIndent': 'b:Divider.indent as the separator',
  'node:listView/dividerEndIndent': 'b:Divider.endIndent as the separator',
  'node:listView/layout': 'c:a list laid out as a list, a stack or a wrap',
  'node:listView/reversePaintOrder': 'c:a layered list painted the other way',
  'node:listView/itemPosition': 'c:where a layered list\'s item sits',
  'node:listView/wrapSpacing': 'b:Wrap.spacing',
  'node:listView/wrapAlignment': 'b:Wrap.alignment',
  'node:listView/wrapCrossAlignment': 'b:Wrap.crossAxisAlignment',
  'node:listView/stretchItems': 'c:CSS align-items: stretch (IntrinsicHeight in Flutter)',
  'node:listView/sections': 'c:items grouped under headers',
  'node:listView/swipeActions': 'c:actions behind a swiped item',
  'node:listView/pullToRefresh': 'b:RefreshIndicator(onRefresh:)',
  'node:listView/stickToEnd': 'c:a chat list that follows new items at the end',
  // gridView
  'node:gridView/minCrossAxisExtent': 'c:CSS repeat(auto-fit, minmax(min, 1fr))',
  'node:gridView/shrinkWrapRows': 'c:rows as tall as their tallest item',
  'node:gridView/masonry': 'c:a masonry grid (not in Flutter\'s SDK)',
  'node:gridView/masonryPlacement': 'c:a masonry grid\'s lane choice',
  // pageView
  'node:pageView/animationDuration': 'b:PageController.animateToPage(duration:)',
  'node:pageView/animationCurve': 'b:PageController.animateToPage(curve:)',
  'node:pageView/pageMotion': 'c:a 3D look for the pages as they scroll',
  'node:pageView/pageMotionBefore': 'c:a 3D look for the pages as they scroll',
  'node:pageView/paintOrder': 'c:which pages draw on top',
  // tabBar
  'node:tabBar/indicatorStyle': 'b:indicator (a Decoration: UnderlineTabIndicator, BoxDecoration)',
  'node:tabBar/indicatorShape': 'b:indicator: ShapeDecoration(shape:)',
  'node:tabBar/indicatorRadius': 'b:indicator: BoxDecoration(borderRadius:)',
  'node:tabBar/content': 'c:what each tab shows (label, icon or both)',
  'node:tabBar/iconDirection': 'c:a tab\'s icon beside its label (Flutter\'s Tab puts it above)',
  'node:tabBar/gap': 'b:Tab.iconMargin',
  // expansionTile
  'node:expansionTile/showDividers': 'b:shape / collapsedShape (the default draws the dividers)',
  // tableView (two_dimensional_scrollables' TableView, not in the SDK read)
  'node:tableView/columns': 'b:TableView.columnBuilder (TableSpan per column)',
  'node:tableView/rowCount': 'a:TableView.rowCount',
  'node:tableView/rowHeight': 'b:rowBuilder → TableSpan(extent: FixedTableSpanExtent)',
  'node:tableView/rowHeightKey': 'c:a row\'s height from its data',
  'node:tableView/headerHeight': 'b:rowBuilder → TableSpan(extent:) of the pinned row',
  'node:tableView/columnWidth': 'b:columnBuilder → TableSpan(extent: FixedTableSpanExtent)',
  'node:tableView/rowHeaderWidth': 'b:columnBuilder → TableSpan(extent:) of the pinned column',
  'node:tableView/fillWidth': 'c:columns share the width left over',
  'node:tableView/pinHeaderRow': 'b:pinnedRowCount',
  'node:tableView/pinHeaderColumn': 'b:pinnedColumnCount',
  'node:tableView/gridLineColor': 'b:TableSpanDecoration(border: TableSpanBorder(...))',
  'node:tableView/gridLineWidth': 'b:TableSpanDecoration(border: TableSpanBorder(...))',
  'node:tableView/stripeColor': 'c:every other row\'s background',
  'node:tableView/headerColor': 'b:TableSpanDecoration(color:) of the pinned spans',
  'node:tableView/cacheExtent': 'a:TableView.cacheExtent',
  'node:tableView/clipBehavior': 'a:TableView.clipBehavior',
  'node:tableView/horizontalPadding': 'b:TableSpan(padding: SpanPadding(leading:, trailing:))',
  'node:tableView/headerBorderColor': 'b:TableSpanDecoration(border:) of the pinned row',
  'node:tableView/headerBorderWidth': 'b:TableSpanDecoration(border:) of the pinned row',
  'node:tableView/rowHoverColor': 'c:a row\'s background under the pointer',
  'node:tableView/selectedRow': 'c:the selected row',
  'node:tableView/selectedRowColor': 'c:the selected row\'s background',
  'node:tableView/selectedRowEdgeColor': 'd:one look of a selected row (an edge at its start)',
  'node:tableView/selectedRowEdgeWidth': 'd:one look of a selected row (an edge at its start)',
  'node:tableView/stretchLastColumn': 'c:the last column takes the width left over',
  // textField
  'node:textField/keyboardDecimal': 'b:keyboardType: TextInputType.numberWithOptions(decimal: true)',
  'node:textField/keyboardSigned': 'b:keyboardType: TextInputType.numberWithOptions(signed: true)',
  'node:textField/focusRingColor': 'b:InputDecoration.focusedBorder',
  'node:textField/focusRingWidth': 'b:InputDecoration.focusedBorder',
  'node:textField/inputFormatter': 'b:inputFormatters (a list of TextInputFormatter)',
  'node:textField/markdown': 'c:Markdown highlighting of the typed text',
  'node:textField/highlightStart': 'd:one styled range of the typed text (a syntax error\'s place)',
  'node:textField/highlightEnd': 'd:one styled range of the typed text',
  'node:textField/highlightStyle': 'd:one styled range of the typed text',
  // checkbox, radio, switch
  'node:checkbox/activeSide': 'b:side as a WidgetStateBorderSide (selected)',
  'node:radio/inactiveColor': 'b:fillColor as a WidgetStateProperty (unselected)',
  'node:switch/controlled': 'c:a switch that only reports a change; reactions set it',
  'node:switch/activeTrackOutlineColor': 'b:trackOutlineColor (WidgetStateProperty, selected)',
  'node:switch/inactiveTrackOutlineColor': 'b:trackOutlineColor (WidgetStateProperty)',
  'node:switch/uniformThumb': 'b:thumbIcon (a set icon keeps the thumb one size)',
  'node:switch/fillTrack': 'b:materialTapTargetSize: MaterialTapTargetSize.shrinkWrap',
  'node:switch/thumbShadows': 'c:a plain toggle\'s look, which Material\'s Switch cannot draw',
  'node:switch/thumbInset': 'c:a plain toggle\'s look',
  'node:switch/activeThumbBorderColor': 'c:a plain toggle\'s look',
  'node:switch/inactiveThumbBorderColor': 'c:a plain toggle\'s look',
  'node:switch/thumbBorderWidth': 'c:a plain toggle\'s look',
  'node:switch/toggleDurationMs': 'c:a plain toggle\'s slide time',
  'node:switch/toggleCurve': 'c:a plain toggle\'s slide curve',
  'node:switch/trackRadius': 'c:a plain toggle\'s look',
  'node:switch/thumbRadius': 'c:a plain toggle\'s look',
  // slider
  'node:slider/thumbBorderWidth': 'c:a drawn thumb\'s look',
  'node:slider/thumbRadius': 'b:RoundSliderThumbShape(enabledThumbRadius:)',
  'node:slider/labelFractionDigits': 'c:decimals of the value in its label',
  'node:slider/deriveOverlayColorFromThumb': 'd:one rule for one look (a bound thumb color tints the overlay)',
  'node:slider/overlayRadius': 'b:RoundSliderOverlayShape(overlayRadius:)',
  'node:slider/thumbCornerRadius': 'c:a drawn thumb\'s look',
  'node:slider/thumbStrokeColor': 'c:a drawn thumb\'s look',
  'node:slider/thumbStrokeWidth': 'c:a drawn thumb\'s look',
  'node:slider/thumbBorderColor': 'c:a drawn thumb\'s look',
  'node:slider/thumbGripColor': 'd:one thumb look (grip lines)',
  'node:slider/thumbGlowColor': 'c:a drawn thumb\'s glow',
  'node:slider/thumbGlowBlur': 'c:a drawn thumb\'s glow',
  'node:slider/thumbGlowSpread': 'c:a drawn thumb\'s glow',
  'node:slider/showThumb': 'b:thumbShape: SliderComponentShape.noThumb',
  'node:slider/tickMarkRadius': 'b:RoundSliderTickMarkShape(tickMarkRadius:)',
  'node:slider/tickMarkStyle': 'b:tickMarkShape (a SliderTickMarkShape)',
  'node:slider/notchEvery': 'c:tick marks at every nth division',
  'node:slider/orientation': 'c:a vertical slider (RotatedBox in Flutter)',
  'node:slider/inverted': 'c:runs from the end',
  'node:slider/fillFromEnd': 'c:the active track from the thumb to the end',
  'node:slider/activeTrackStartOpacity': 'd:one track look (a fade at its start)',
  'node:slider/markerValue': 'd:one track look (a marker at a value)',
  'node:slider/markerColor': 'd:one track look (a marker at a value)',
  'node:slider/markerWidth': 'd:one track look (a marker at a value)',
  'node:slider/markerHeight': 'd:one track look (a marker at a value)',
  'node:slider/selectableMin': 'c:the part of the track the thumb can reach',
  'node:slider/selectableMax': 'c:the part of the track the thumb can reach',
  'node:slider/rulerTicks': 'd:one track look (a ruler)',
  'node:slider/rulerMajorEvery': 'd:one track look (a ruler)',
  'node:slider/rulerTickColor': 'd:one track look (a ruler)',
  'node:slider/rulerMinorTickColor': 'd:one track look (a ruler)',
  // dropdown
  'node:dropdown/itemAlignment': 'b:DropdownMenuItem.alignment',
  'node:dropdown/selectedItemStyle': 'b:selectedItemBuilder',
  'node:dropdown/hintStyle': 'b:hint: Text(style:)',
  'node:dropdown/hoverColor': "a:ThemeData.hoverColor's name and meaning",
  'node:dropdown/splashColor': "a:ThemeData.splashColor's name and meaning",
  'node:dropdown/useDataSource': 'c:items from bound data',
  'node:dropdown/itemLabel': 'c:items from bound data',
  'node:dropdown/itemImage': 'c:an image before each item',
  'node:dropdown/itemImageSize': 'c:an image before each item',
  'node:dropdown/itemImageRadius': 'c:an image before each item',
  'node:dropdown/menuStyle': 'b:DropdownMenu.menuStyle (MenuStyle) — a card menu of its own shape',
  // date and time
  'node:dateTimeInput/mode': 'c:date, time or both',
  'node:dateTimeInput/firstDate': 'a:showDatePicker(firstDate:)',
  'node:dateTimeInput/lastDate': 'a:showDatePicker(lastDate:)',
  'node:dateTimeInput/min': 'b:firstDate (with a time)',
  'node:dateTimeInput/max': 'b:lastDate (with a time)',
  'node:dateTimeInput/bare': 'c:no field around the value',
  'node:dateTimeInput/displayFormat': 'd:an older name of format, read when format is unset: two spellings',
  'node:dateTimeInput/displayText': 'c:text shown instead of the value',
  'node:dateTimeInput/picker': 'c:a dialog or an inline picker',
  // segmented button
  'node:segmentedButton/selectedBackgroundColor': 'b:style: ButtonStyle(backgroundColor: WidgetStateProperty (selected))',
  'node:segmentedButton/selectedForegroundColor': 'b:style: ButtonStyle(foregroundColor: WidgetStateProperty (selected))',
  'node:segmentedButton/segmentHeight': 'b:ButtonStyle.minimumSize / maximumSize',
  'node:segmentedButton/expanded': 'b:expandedInsets',
  'node:segmentedButton/shrinkTapTarget': 'b:ButtonStyle.tapTargetSize: MaterialTapTargetSize.shrinkWrap',
  'node:segmentedButton/trackPadding': 'b:CupertinoSlidingSegmentedControl.padding',
  'node:segmentedButton/selectedShadows': 'c:a track\'s selected segment\'s shadows',
  'node:segmentedButton/slidingThumb': 'b:CupertinoSlidingSegmentedControl (a thumb that slides)',
  // buttons
  'node:filledButton/tonal': 'b:FilledButton.tonal (a named constructor)',
  'node:floatingActionButton/type': 'b:FloatingActionButton.small / .large / .extended (named constructors)',
  'node:floatingActionButton/location': 'b:Scaffold.floatingActionButtonLocation',
  'node:inputChip/deleteIconSize': 'b:deleteIconBoxConstraints',
  // navigation bars
  'node:navigationBar/iconSize': 'b:NavigationBarThemeData.iconTheme (size)',
  'node:bottomNavigationBar/destinations': 'b:items (BottomNavigationBarItem)',
  'node:bottomNavigationBar/selectedIndex': 'b:currentIndex',
  'node:bottomNavigationBar/labelBehavior': 'b:showSelectedLabels / showUnselectedLabels',
  'node:bottomNavigationBar/labelTextStyle': 'b:selectedLabelStyle / unselectedLabelStyle',
  // progress, path
  'node:circularProgressIndicator/startAngle': 'c:where the ring starts (degrees)',
  'node:circularProgressIndicator/sweepAngle': 'c:how much of the circle the ring spans (degrees)',
  'node:path/data': 'c:SVG path data; Flutter has no SVG path parser',
  'node:path/viewBox': 'c:SVG viewBox',
  'node:path/scaleStroke': 'c:SVG vector-effect: non-scaling-stroke',
  'node:path/trimStart': 'c:the stroked share of the path (PathMetric.extractPath)',
  'node:path/trimEnd': 'c:the stroked share of the path (PathMetric.extractPath)',
};

// --- output ---------------------------------------------------------------------------

String markdown(List<GroupResult> results, FlutterIndex index) {
  final out = StringBuffer();
  int total(Iterable<GroupResult> rs, String? k) => rs.fold(0, (s, r) => s + r.count(k));
  int all(Iterable<GroupResult> rs) => rs.fold(0, (s, r) => s + r.fields.length);
  String pct(int n, int d) => d == 0 ? '–' : '${(100 * n / d).round()}%';

  final shared = results.where((r) => r.group.shared).toList();
  final nodes = results.where((r) => !r.group.shared).toList();
  out.writeln('| Group | Fields | (a) | (b) | (c) | (d) | unclassified | (a) of all | (a) of Flutter concepts, (a)/((a)+(b)) |');
  out.writeln('|---|---|---|---|---|---|---|---|---|');
  void row(String name, Iterable<GroupResult> rs) {
    final a = total(rs, 'a'), b = total(rs, 'b');
    out.writeln('| $name | ${all(rs)} | $a | $b | ${total(rs, 'c')} | ${total(rs, 'd')} | ${total(rs, null)} | '
        '${pct(a, all(rs))} | ${pct(a, a + b)} |');
  }

  row('**All**', results);
  row('Node types (${nodes.length})', nodes);
  row('Shared groups', shared);
  final ops = shared.where((r) => r.group.name.startsWith('drawOp:'));
  for (final r in shared.where((r) => !r.group.name.startsWith('drawOp:'))) {
    row(r.group.name, [r]);
  }
  row('draw ops (${ops.length})', ops);
  out.writeln();
  out.writeln('Per node type:');
  out.writeln();
  out.writeln('| Node type | Flutter | Fields | (a) | (b) | (c) | (d) | (a) of all |');
  out.writeln('|---|---|---|---|---|---|---|---|');
  for (final r in nodes) {
    out.writeln('| `${r.group.name.substring(5)}` | `${r.group.flutter.first}` | ${r.fields.length} | ${r.count('a')} | '
        '${r.count('b')} | ${r.count('c')} | ${r.count('d')} | ${pct(r.count('a'), r.fields.length)} |');
  }
  final missing = {for (final r in results) ...r.missing};
  if (missing.isNotEmpty) {
    out.writeln();
    out.writeln('Flutter classes named but not in the Flutter SDK read: ${missing.map((m) => '`$m`').join(', ')}.');
  }
  return out.toString();
}

/// Every field not in (a), by class then group, with its verdict.
String detail(List<GroupResult> results) {
  final out = StringBuffer();
  const titles = {
    'b': '(b) A Flutter concept under another name',
    'd': '(d) No Flutter counterpart, a special case',
    'c': '(c) No Flutter counterpart, general',
    'a': '(a) Flutter\'s name, found outside the classes the group lists',
  };
  for (final kind in ['b', 'd', 'c', 'a']) {
    final rows = [
      for (final r in results)
        for (final f in r.fields)
          if (f.kind == kind && (kind != 'a' || f.note.isNotEmpty)) (r.group.name, f),
    ];
    out
      ..writeln('## ${titles[kind]} (${rows.length})')
      ..writeln()
      ..writeln(kind == 'b' ? '| Group | Field | Flutter | Note |' : '| Group | Field | Why |')
      ..writeln(kind == 'b' ? '|---|---|---|---|' : '|---|---|---|');
    for (final (g, f) in rows) {
      if (kind == 'b') {
        final i = f.note.indexOf(' — ');
        final flutter = i < 0 ? f.note : f.note.substring(0, i);
        final note = i < 0 ? '' : f.note.substring(i + 3);
        out.writeln('| `$g` | `${f.name}` | `$flutter` | $note |');
      } else {
        out.writeln('| `$g` | `${f.name}` | ${f.note} |');
      }
    }
    out.writeln();
  }
  return out.toString();
}
