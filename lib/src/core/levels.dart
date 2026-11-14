// The levels of the vocabulary (docs/design/12-agent-first-flutter.md §3).
// A level is a closed set: a document written with level N's vocabulary
// uses nothing from a higher one, and each level adds to the ones below,
// never respelling them. An agent is granted a level; the validator can
// check at one (`ValidateOptions.level`), and the reference is generated
// per level.
//
// The assignment lives here, in one table per kind, not on each
// declaration: it is a statement about the whole vocabulary, read and
// reviewed in one place. `test/levels_test.dart` fails when a declared
// type, action, behavior or trigger is missing from its table.
import 'catalog.dart';
import 'json.dart';

/// A level of the vocabulary, lowest first.
enum Level {
  /// Boxes and layout: what draws any static UI, and one tap that tells the
  /// host.
  core('Core'),

  /// Controls, complete with zero props: each has a size, a look and a
  /// value, and reports `changed`.
  widgets('Widget catalog'),

  /// Variables, bindings, expressions, actions, states, lists over data,
  /// forms, navigation: the UI reacts without the host.
  state('State and behaviour'),

  /// Theme scales, components by reference, responsive rules: the UI
  /// looks like a specific product.
  design('Design systems'),

  /// Motion, gestures, drag and drop, custom paint, scroll effects, charts,
  /// scripting, media.
  full('Full vocabulary'),

  /// Product features built from the levels below: backends, storage,
  /// accounts, payments.
  features('Feature layers');

  const Level(this.title);

  /// Its name in prose ("Widget catalog").
  final String title;

  /// Whether a document at this level may use something of [other].
  bool includes(Level other) => other.index <= index;

  /// The level named [name] (`core`, `widgets`...) or numbered (`0`..`5`).
  static Level? parse(String name) {
    final n = int.tryParse(name);
    if (n != null) return n >= 0 && n < values.length ? values[n] : null;
    for (final l in values) {
      if (l.name == name) return l;
    }
    return null;
  }
}

const _c = Level.core, _w = Level.widgets, _s = Level.state, _d = Level.design, _f = Level.full, _p = Level.features;

/// The level of each node type.
const Map<String, Level> widgetLevels = {
  // Core: structure, layout, text, pictures, scrolling.
  'canvas': _c, 'stack': _c, 'box': _c, 'row': _c, 'column': _c, 'flex': _c, 'text': _c, 'icon': _c, 'spacer': _c,
  'listView': _c, 'gridView': _c, 'divider': _c, 'verticalDivider': _c, 'placeholder': _c, 'singlePlaceholder': _c,
  // Widget catalog: controls and the containers people operate.
  'elevatedButton': _w, 'filledButton': _w, 'textButton': _w, 'outlinedButton': _w, 'iconButton': _w,
  'floatingActionButton': _w, 'textField': _w, 'checkbox': _w, 'switch': _w, 'radio': _w, 'slider': _w,
  'dropdown': _w, 'datePicker': _w, 'timePicker': _w, 'dateTimeInput': _w, 'segmentedButton': _w, 'chip': _w,
  'actionChip': _w, 'choiceChip': _w, 'filterChip': _w, 'inputChip': _w, 'badge': _w, 'listTile': _w,
  'accordion': _w, 'expansionTile': _w, 'tabs': _w, 'tabBar': _w, 'appBar': _w, 'navigationBar': _w,
  'bottomNavigationBar': _w, 'modal': _w, 'circularProgressIndicator': _w, 'activityIndicator': _w,
  'progressBar': _w, 'pageView': _w, 'pagination': _w, 'tableView': _w,
  // Design systems: a component's variants and the place its caller fills.
  'variance': _d, 'slot': _d,
  // Full vocabulary: drawing, data pictures, media, embeds.
  'path': _f, 'signature': _f, 'radialGauge': _f, 'gaugeMeter': _f, 'chart': _f, 'plotChart': _f, 'barChart': _f,
  'lineChart': _f, 'barcode': _f, 'external': _f, 'video': _f, 'embeddedVideo': _f, 'audioPlayer': _f,
  'webView': _f,
};

/// The level of each action type.
const Map<String, Level> actionLevels = {
  // Core: tell the host (a session's events, a component's caller, the app's event bus); open a link.
  'componentEvent': _c, 'emitEvent': _c, 'openLink': _c,
  // Widget catalog: what the controls and their surfaces need.
  'showToast': _w, 'confirm': _w, 'openModal': _w, 'closeModal': _w, 'focus': _w, 'editText': _w,
  'copyToClipboard': _w, 'validate': _w,
  // State and behaviour.
  'setVariable': _s, 'setValue': _s, 'if': _s, 'forEach': _s, 'delay': _s, 'navigate': _s, 'scrollTo': _s,
  'paginate': _s, 'callFunction': _s, 'retryFailed': _s,
  // Design systems.
  'setVariant': _d, 'setThemeMode': _d,
  // Full vocabulary.
  'animate': _f, 'controlTrack': _f, 'controlDismissible': _f, 'controlTransform': _f, 'haptic': _f,
  'runScript': _f, 'speak': _f, 'playSound': _f, 'captureScreenshot': _f, 'downloadFile': _f, 'preloadImages': _f,
  'print': _f,
  // Feature layers.
  'callApi': _p, 'setStorage': _p, 'cloudDocuments': _p, 'loadCloudData': _p, 'reloadCloudData': _p,
  'cloudFiles': _p, 'cloudData': _p, 'cloudBatch': _p, 'submitForm': _p, 'auth': _p, 'paywall': _p,
};

/// The level of each behavior (a node key beside `props`).
const Map<String, Level> behaviorLevels = {
  'textDirection': _c, 'defaultTextStyle': _c, 'ignorePointer': _c,
  'tooltip': _w, 'inkWell': _w, 'form': _w, 'radioGroup': _w,
  'states': _s,
  'motion': _f, 'animations': _f, 'transitions': _f, 'shimmer': _f, 'floating': _f, 'hero': _f, 'draggable': _f,
  'dropTarget': _f, 'track': _f, 'dismissible': _f, 'pan': _f, 'reorderHandle': _f, 'reveal': _f,
  'typewriter': _f, 'particles': _f, 'flip': _f, 'tilt': _f, 'transformGesture': _f, 'sticky': _f,
  'viewProgress': _f, 'measure': _f, 'customPaint': _f,
};

/// The level of each trigger type.
const Map<String, Level> triggerLevels = {
  'click': _c,
  'changed': _w, 'changeEnd': _w, 'submitted': _w, 'deleted': _w, 'editingComplete': _w, 'focusGained': _w, 'focusLost': _w,
  'rowTap': _w,
  'load': _s, 'valueChanged': _s, 'backPressed': _s, 'actionError': _s, 'refresh': _s, 'doubleTap': _s,
  'longPress': _s, 'imageLoading': _s, 'imageLoaded': _s, 'imageError': _s,
  'event': _d,
  'hold': _f, 'secondaryClick': _f, 'pointerDown': _f, 'pointerUp': _f, 'hover': _f, 'cursorEnter': _f,
  'cursorExit': _f, 'swipeLeft': _f, 'swipeRight': _f, 'swipeUp': _f, 'swipeDown': _f, 'drag': _f, 'dragEnd': _f,
  'wheel': _f, 'pinch': _f, 'timer': _f, 'frame': _f, 'keyDown': _f, 'keyUp': _f, 'scroll': _f, 'scrollEnd': _f,
  'enterViewport': _f, 'exitViewport': _f, 'dragStart': _f, 'dragCancel': _f, 'dragCompleted': _f, 'drop': _f,
  'dragEnter': _f, 'dragExit': _f, 'dropRejected': _f, 'reorder': _f, 'swipeAction': _f,
};

/// The level of each node key that is not a behavior and not always
/// allowed: a binding, a component call, responsive rules.
const Map<String, Level> nodeKeyLevels = {'bind': _s, 'component': _d, 'media': _d};

/// The level of each top-level document key beyond `schema`, `roots` and
/// `nodes`.
const Map<String, Level> documentKeyLevels = {
  'variables': _s, 'conditions': _s, 'breakpoints': _d, 'scripts': _f,
};

/// The level of each data source type.
const Map<String, Level> dataSourceLevels = {'data': _s, 'cloud': _p, 'api': _p};

/// One thing a document uses, with its level: where it is (a JSON
/// pointer), what it is ("action setVariable") and the node it is on.
final class LevelUse {
  const LevelUse(this.level, this.path, this.what, {this.nodeId});
  final Level level;
  final String path;
  final String what;
  final String? nodeId;

  @override
  String toString() => '$what (${level.name}) at $path';
}

/// Everything in [document] (a layout document's JSON) above [above], in
/// document order; with [above] null, everything that has a level. A type,
/// action or trigger the tables do not know has no level and is not
/// listed (unknown types are the validator's to report).
List<LevelUse> levelUses(Object? document, {Level? above}) {
  final out = <LevelUse>[];
  void use(Level? level, String path, String what, [String? node]) {
    if (level == null) return;
    if (above != null && above.includes(level)) return;
    out.add(LevelUse(level, path, what, nodeId: node));
  }

  final doc = readMap(document);
  if (doc == null) return out;
  for (final k in doc.keys) {
    final v = doc[k];
    if (v == null || (v is Map && v.isEmpty) || (v is List && v.isEmpty)) continue;
    use(documentKeyLevels[k], '/$k', 'document key "$k"');
  }
  final nodes = readMap(doc['nodes']) ?? const {};
  for (final e in nodes.entries) {
    final n = readMap(e.value);
    if (n == null) continue;
    final id = e.key;
    final base = '/nodes/${_escape(id)}';
    use(widgetLevels[readString(n['type'])], '$base/type', 'type ${n['type']}', id);
    for (final k in n.keys) {
      use(nodeKeyLevels[k] ?? behaviorLevels[k], '$base/$k', k == 'bind' ? 'a binding' : 'node key "$k"', id);
    }
    _values(n['props'], '$base/props', id, use);
    _values(n['layout'], '$base/layout', id, use);
    _values(n['decoration'], '$base/decoration', id, use);
    _reactions(n['actions'], '$base/actions', id, use);
  }
  return out;
}

/// The highest level [document] uses ([Level.core] for an empty one).
Level levelOf(Object? document) {
  var top = Level.core;
  for (final u in levelUses(document)) {
    if (u.level.index > top.index) top = u.level;
  }
  return top;
}

typedef _Use = void Function(Level? level, String path, String what, [String? node]);

const _chainKeys = {'then', 'else', 'actions', 'onSuccess', 'onError', 'cancelActions'};

void _reactions(Object? list, String path, String id, _Use use) {
  if (list is! List) return;
  for (var i = 0; i < list.length; i++) {
    final r = readMap(list[i]);
    if (r == null) continue;
    final t = readMap(r['trigger']);
    final type = readString(t?['type']);
    use(triggerLevels[type], '$path/$i/trigger', 'trigger $type', id);
    _chain(r['actions'], '$path/$i/actions', id, use);
  }
}

void _chain(Object? list, String path, String id, _Use use) {
  if (list is! List) return;
  for (var i = 0; i < list.length; i++) {
    final a = readMap(list[i]);
    if (a == null) continue;
    final type = readString(a['type']);
    use(actionLevels[type], '$path/$i', 'action $type', id);
    for (final k in _chainKeys) {
      _chain(a[k], '$path/$i/$k', id, use);
    }
    for (final k in a.keys) {
      if (!_chainKeys.contains(k) && k != 'type') _values(a[k], '$path/$i/$k', id, use);
    }
  }
}

/// Expressions written inside values: reading state is level 2.
void _values(Object? v, String path, String id, _Use use) {
  if (v is String) {
    if (v.contains(r'${')) use(Level.state, path, 'an expression', id);
  } else if (v is Map) {
    for (final e in v.entries) {
      _values(e.value, '$path/${_escape('${e.key}')}', id, use);
    }
  } else if (v is List) {
    for (var i = 0; i < v.length; i++) {
      _values(v[i], '$path/$i', id, use);
    }
  }
}

String _escape(String s) => s.replaceAll('~', '~0').replaceAll('/', '~1');

/// [catalog] cut down to [level]: the node types, actions and data sources
/// of that level and below. A type the tables do not list (a plugin's) is
/// kept only at [Level.features].
Catalog catalogAtLevel(Catalog catalog, Level level) {
  bool ok(Level? l) => l == null ? level == Level.features : level.includes(l);
  return Catalog(
    id: catalog.id.isEmpty ? level.name : '${catalog.id}@${level.name}',
    widgets: [for (final w in catalog.widgets) if (ok(widgetLevels[w.type])) w],
    actions: [for (final a in catalog.actions) if (ok(actionLevels[a.type])) a],
    dataSources: [for (final d in catalog.dataSources) if (ok(dataSourceLevels[d.type])) d],
    formulas: level.includes(Level.state) ? catalog.formulas : const [],
    instructions: catalog.instructions,
  );
}

/// [Catalog.atLevel].
extension CatalogLevels on Catalog {
  /// This catalog cut down to [level] ([catalogAtLevel]).
  Catalog atLevel(Level level) => catalogAtLevel(this, level);
}
