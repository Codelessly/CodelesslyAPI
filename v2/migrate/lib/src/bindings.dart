// v1 binding keys (`BaseNode.variables`: a v1 property name → a variable
// path or formula) → v2 binding paths (DESIGN.md §5.1).
import 'package:codelessly_api/codelessly_api.dart';

/// The v2 binding path of v1 binding [key] on node [n] (migrated to v2 type
/// [v2Type]), or null when v2 has no path for it (the binding is then kept
/// under its v1 key and reported).
String? v2BindPath(BaseNode n, String v2Type, String key) {
  // A gradient stop of a paint by id (`fill-g1-stop-0`,
  // `stroke-paint-g1-stop-position-1`, `foreground-g1-stop-2`).
  if (_paintStop.firstMatch(key) case final RegExpMatch m) {
    final list = switch (m[1]) { 'fill' => 'fills', 'stroke-paint' => 'strokes', _ => 'foregroundFills' };
    return 'decoration.$list.${m[2]}.stops[${m[4]}].${m[3] == null ? 'color' : 'position'}';
  }
  // Per-paint, per-effect and per-stop keys.
  for (final (prefix, path) in _prefixed) {
    if (key.startsWith(prefix) && key.length > prefix.length) {
      return path(key.substring(prefix.length));
    }
  }
  if (key.startsWith('motion.')) {
    final field = key.substring('motion.'.length);
    return 'motion.${_motionFields[field] ?? field}';
  }
  // A drag track's settings and geometry (`track.x2`, `dragTrack.endAngle`)
  // and the value it's drawn at (`track.value`).
  for (final prefix in const ['track.', 'dragTrack.']) {
    if (key.startsWith(prefix) && key.length > prefix.length) {
      final field = key.substring(prefix.length);
      return 'drag.track.${_trackFields[field] ?? field}';
    }
  }
  // A transform gesture's pose from data, and its switch.
  if (key.startsWith('transform.') && key.length > 'transform.'.length) {
    return 'transformGesture.${key.substring('transform.'.length)}';
  }
  if (key == 'flip.flipped') return key;
  // A shared element's tag (`pass-${item.id}`).
  if (key == 'heroTag') return 'hero.tag';
  // A one-shot effect's cue and delay, by its name; the particles' cue.
  if (key.startsWith('animations.')) {
    for (final (suffix, field) in const [('.playKey', 'playKey'), ('.delayMs', 'delay')]) {
      if (!key.endsWith(suffix)) continue;
      final name = key.substring('animations.'.length, key.length - suffix.length);
      final i = n.effectAnimations.indexWhere((e) => e.name == name);
      if (i >= 0) return 'effectAnimations[$i].$field';
    }
  }
  if (key == 'particles.playKey' && n.particles != null) return key;
  // A pulse is a loop after the node's loop animation.
  if (key == 'pulsePhase' || key == 'pulseDelayMs') {
    return 'loops[${n.loopAnimation == null ? 0 : 1}].${key == 'pulsePhase' ? 'phase' : 'lag'}';
  }
  final isText = n is TextNode;
  // The type's own cases first: the same v1 name means different things
  // per type.
  final own = (_byType[n.type] ?? const {})[key];
  if (own != null) return own;
  if (isText) {
    if (_textKeys[key] case final String p) return p;
  }
  if (key == 'fill') return isText ? 'props.style.color' : 'decoration.fills[0]';
  // A core node's interaction state a binding turns on; a widget's own
  // `selected` prop otherwise.
  if (key == 'selected' || key == 'disabled') return _coreTypes.contains(v2Type) ? key : 'props.$key';
  if (_common[key] case final String p) return p;
  if (_collections.contains(v2Type) && key == 'data') return 'data';
  // A widget type's own property: v2 declares it under v1's name (the
  // group ports kept Flutter's names, which v1 used too).
  if (!_coreTypes.contains(v2Type) && RegExp(r'^[a-zA-Z][a-zA-Z0-9]*$').hasMatch(key)) return 'props.$key';
  return null;
}

final RegExp _paintStop = RegExp(r'^(fill|stroke-paint|foreground)-(.+?)-stop-(position-)?(\d+)$');

final List<(String, String Function(String))> _prefixed = [
  ('fill-image-', (id) => 'decoration.fills.$id.image.url'),
  ('fill-stop-position-', (i) => 'decoration.fills[0].stops[$i].position'),
  ('fill-stop-', (i) => 'decoration.fills[0].stops[$i].color'),
  ('fill-', (id) => 'decoration.fills.$id'),
  ('stroke-paint-', (id) => 'decoration.strokes.$id'),
  ('effect-visible-', (id) => 'decoration.effects.$id.visible'),
  ('shadow-color-', (id) => 'decoration.effects.$id.color'),
  ('notch-offset-', (i) => 'decoration.notches[$i].offset'),
];

const _motionFields = {'durationMs': 'duration', 'delayMs': 'delay'};

const _trackFields = {'settleMs': 'settle', 'snapMs': 'snap', 'fineHoldMs': 'fineHold'};

final RegExp _number = RegExp(r'^-?(\d+\.?\d*|\.\d+)$');

const _collections = {'listView', 'gridView', 'pageView', 'tableView'};

/// Types whose props are declared by the core (no per-type properties
/// beyond the tables here).
const _coreTypes = {'canvas', 'stack', 'box', 'row', 'column', 'text', 'icon', 'spacer', 'variance'};

/// Keys every type shares.
const Map<String, String> _common = {
  'visible': 'visible',
  'opacity': 'opacity',
  'width': 'layout.width',
  'height': 'layout.height',
  'flex': 'layout.flex',
  'rotation': 'layout.rotation',
  'rotationDegrees': 'layout.rotation',
  'margin': 'layout.margin',
  'padding': 'layout.padding',
  // v1 moved the node by the difference from its design position; v2 binds
  // its position.
  'x': 'layout.x',
  'y': 'layout.y',
  // A fraction of the parent (v1's fractional freeform placement).
  'positionX': 'layout.x.fraction',
  'positionY': 'layout.y.fraction',
  'stroke': 'decoration.strokes[0]',
  'strokeWeight': 'decoration.strokeWidth',
  'cornerRadius': 'decoration.radius',
  'effectsVisible': 'decoration.effects.*.visible',
  'effectsColor': 'decoration.effects.*.color',
  'effectsOffsetX': 'decoration.effects.*.offset.dx',
  'effectsOffsetY': 'decoration.effects.*.offset.dy',
  'effectsBlur': 'decoration.effects.*.blurRadius',
  'effectsSpread': 'decoration.effects.*.spreadRadius',
  'notchOffset': 'decoration.notches.*.offset',
  'drawScale': 'scale',
  'layoutDirection': 'textDirection',
  'flightKey': 'flightKey',
  'tooltip': 'tooltip',
  'draggable.data': 'draggable.data',
  // Not modelled by v2 yet: kept under reserved paths.
  'semanticLabel': 'semantics.label',
  'semanticSelected': 'semantics.selected',
  'semanticChildren': 'semantics.children',
  'node_enabled': 'enabled',
  'loopAnimationEnabled': 'loops.*.enabled',
};

/// A text node's keys.
const Map<String, String> _textKeys = {
  'data': 'props.text',
  'textColor': 'props.style.color',
  'fontWeight': 'props.style.fontWeight',
  'fontSize': 'props.style.fontSize',
  'fontFamily': 'props.style.fontFamily',
  'letterSpacing': 'props.style.letterSpacing',
  'lineHeight': 'props.style.height',
  'textDecoration': 'props.style.decoration',
  'textAlign': 'props.textAlign',
  'maxLines': 'props.maxLines',
};

/// Keys whose v2 prop has another name, by v1 type.
const Map<String, Map<String, String>> _byType = {
  // CanvasNode.blockBackVariable: keeps the user on the screen on back.
  'canvas': {'blockBack': 'props.blockBack'},
  'icon': {'icon': 'props.icon.name', 'iconName': 'props.icon.name', 'iconColor': 'props.color', 'color': 'props.color'},
  'row': {'spacing': 'props.spacing', 'runSpacing': 'props.runSpacing'},
  'column': {'spacing': 'props.spacing', 'runSpacing': 'props.runSpacing'},
  'variance': {'currentVariantId': 'props.current', 'variant': 'props.current'},
  'progressBar': {'currentValue': 'props.value', 'progressColor': 'props.color'},
  'loadingIndicator': {'color': 'props.color', 'value': 'props.value'},
  'textField': {
    'inputValue': 'props.initialValue',
    'text': 'props.initialValue',
    'fillColor': 'props.decoration.fillColor',
    'hintText': 'props.decoration.hintText',
    'labelText': 'props.decoration.labelText',
    'error': 'props.decoration.errorText',
  },
  'dropdown': {'data': 'props.items'},
  // A grid's column count from data (GridViewNode.crossAxisCountVariable).
  'gridView': {'crossAxisCount': 'props.crossAxisCount'},
  'checkbox': {'value': 'props.value'},
  'switch': {'value': 'props.value'},
  'radio': {'value': 'props.value', 'groupValue': 'props.groupValue'},
  'tabBar': {'selectedIndex': 'props.initialIndex'},
  'navigationBar': {'selectedIndex': 'props.selectedIndex'},
};

final RegExp _barePath = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*(\[\d+\])*(\.[a-zA-Z][a-zA-Z0-9_]*(\[\d+\])*)*$');
final RegExp _iconName = RegExp(r'^[a-z0-9_]+$');

/// A v1 binding's value as a v2 expression, or null when it had no effect
/// in v1. v1 read a value without `${` as a variable path (`dLen` is
/// `${dLen}`); one that isn't a path (`74.2`) read nothing. An icon name
/// written as is (`block_rounded`) showed that icon when no variable had
/// the name.
String? v2BindExpression(String? path, String value) {
  if (value.contains(r'${')) return value;
  final t = value.trim();
  // A drag track reads a number written as is (`"track.step": "0.5"`).
  if (path != null && path.startsWith('drag.track.') && _number.hasMatch(t)) return t;
  if (!_barePath.hasMatch(t)) return null;
  if (path == 'props.icon.name' && _iconName.hasMatch(t)) return "\${= coalesce($t, '$t')}";
  return '\${$t}';
}
