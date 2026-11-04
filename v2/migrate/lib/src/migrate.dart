// v1 (codelessly_api 6.x) → v2 JSON. Reads v1 with its own decoder, so v1's
// defaults, boxes and derived values are exactly what v1's SDK saw; writes
// plain v2 JSON (see CodelesslyAPI/v2/DESIGN.md).
import 'dart:math' as math;

import 'package:codelessly_api/codelessly_api.dart';

import 'behaviours.dart';
import 'bindings.dart';
import 'logic.dart';
import 'page_schema.dart';
import 'types/registry.dart';

typedef Json = Map<String, Object?>;

/// What a migration did, for coverage tracking.
class MigrationReport {
  int nodes = 0;

  /// v2 type → count.
  final Map<String, int> types = {};

  /// v1 keys kept verbatim under `extra.v1`, by `type.key`: what isn't
  /// mapped to v2 yet.
  final Map<String, int> unmapped = {};

  /// Nodes whose type has no v2 declaration yet (props kept raw).
  final Map<String, int> unportedTypes = {};

  /// Nodes v1 itself couldn't decode, by id → error.
  final Map<String, String> undecodable = {};

  /// v1 binding keys with no v2 binding path (kept under their v1 key), by
  /// `type.key`.
  final Map<String, int> unmappedBindings = {};

  /// v1 bindings that had no effect in v1 (text that is neither a variable
  /// path nor holds `${...}`), dropped, by `type.key`.
  final Map<String, int> ineffectiveBindings = {};

  void merge(MigrationReport o) {
    nodes += o.nodes;
    o.types.forEach((k, v) => types.update(k, (x) => x + v, ifAbsent: () => v));
    o.unmapped.forEach((k, v) => unmapped.update(k, (x) => x + v, ifAbsent: () => v));
    o.unportedTypes.forEach((k, v) => unportedTypes.update(k, (x) => x + v, ifAbsent: () => v));
    undecodable.addAll(o.undecodable);
    o.unmappedBindings.forEach((k, v) => unmappedBindings.update(k, (x) => x + v, ifAbsent: () => v));
    o.ineffectiveBindings.forEach((k, v) => ineffectiveBindings.update(k, (x) => x + v, ifAbsent: () => v));
  }
}

/// Types v2 declares. Anything else migrates with its v1 props kept raw.
const Set<String> portedV1Types = {'canvas', 'frame', 'rectangle', 'rowColumn', 'text', 'icon', 'spacer', 'variance'};

/// Converts a stored v1 page document (`id → node JSON`, plus `rootNode`) to
/// a v2 layout document.
///
/// The layout's v1 [variables] and [conditions] (canvas id → (id → JSON), as
/// the publish model and the editor store them) become its `variables` and
/// `conditions` keys (see logic.dart).
Json migrateDocument(
  Map<String, Object?> v1Document, {
  String id = '',
  MigrationReport? report,
  Object? variables,
  Object? conditions,
}) {
  final wrapped = <String, dynamic>{'document': {...v1Document}};
  MigrationHandler.migrateJson(wrapped);
  final doc = (wrapped['document'] as Map).cast<String, Object?>();

  final rep = report ?? MigrationReport();
  final nodes = <String, BaseNode>{};
  for (final e in doc.entries) {
    final v = e.value;
    if (v is! Map || v['type'] == null || v['type'] == 'root') continue;
    try {
      final n = NodeJsonConverter().fromJson(v);
      if (n != null) nodes[e.key] = n;
    } catch (error) {
      // Undecodable in v1 too: v1's editor dropped it on load.
      rep.undecodable[e.key] = '$error';
    }
  }
  final parents = <String, String>{};
  for (final n in nodes.values) {
    for (final c in ownedChildren(n)) {
      parents[c] = n.id;
      nodes[c]?.parentID = n.id;
    }
  }
  final roots = [
    for (final r in readStrings((doc['rootNode'] as Map?)?['children']))
      if (nodes.containsKey(r)) r,
  ];
  for (final r in roots) {
    nodes[r]!.parentID = kRootNode;
  }

  final out = <String, Object?>{};
  for (final n in nodes.values) {
    final parent = nodes[parents[n.id]];
    out[n.id] = V1Node(n, parent, nodes, rep).run();
  }
  return {
    'schema': 2,
    if (id.isNotEmpty) 'id': id,
    'roots': roots,
    'nodes': out,
    ...migrateLayoutLogic(variables: variables, conditions: conditions, nodes: nodes, report: rep),
  };
}

List<String> ownedChildren(BaseNode node) {
  if (node is VarianceNode) {
    final seen = <String>{};
    return [for (final c in node.allVariantsChildren) if (seen.add(c)) c];
  }
  return node.childrenOrEmpty;
}

List<String> readStrings(Object? v) => [if (v is List) ...v.whereType<String>()];

/// [v] rounded for storage (4 decimals; integral values as ints).
num roundNum(num v) {
  final r = (v * 10000).roundToDouble() / 10000;
  return r == r.roundToDouble() && r.abs() < 1e15 ? r.toInt() : r;
}

/// The v2 type of a v1 node.
String v2TypeOf(BaseNode n) => switch (n) {
      CanvasNode() => 'canvas',
      // Row/columns, and the screen-body placeholder that is one.
      RowColumnMixin(rowColumnType: RowColumnType.row) => 'row',
      RowColumnMixin() => 'column',
      FrameNode() || FreeformPlaceholderNode() => 'stack',
      RectangleNode() when n.childrenOrEmpty.isNotEmpty => 'stack',
      RectangleNode() => 'box',
      _ => n.type,
    };

/// Whether [parent] lays its children out freeform (stack semantics).
bool isFreeformParent(BaseNode parent) =>
    parent is FrameNode ||
    parent is FreeformPlaceholderNode ||
    parent is RectangleNode ||
    parent is VarianceNode ||
    (typeMigrations[parent.type]?.freeformChildren ?? false);

/// How one v1 node type (its `type`) migrates. Registered per widget group
/// in lib/src/types.
class TypeMigration {
  const TypeMigration({
    required this.type,
    required this.props,
    this.decorated = false,
    this.children,
    this.slots,
    this.freeformChildren = false,
    this.flexChildren = false,
  });

  /// The v2 type of a node of this v1 type.
  final String Function(BaseNode n) type;

  /// The v2 props; read v1 values with [V1Node.take] so they aren't left
  /// under `v1`.
  final Json Function(V1Node m) props;

  /// Has a box decoration (fills, strokes, radius, effects) in v2.
  final bool decorated;

  /// The v2 ordered children; default the v1 children.
  final List<String> Function(V1Node m)? children;

  /// The v2 named slots.
  final Map<String, String> Function(V1Node m)? slots;

  /// Its children are placed freeform (they get layout.x/y).
  final bool freeformChildren;

  /// Its children are laid out as a row/column's (they get layout.align).
  final bool flexChildren;
}

/// One v1 node being migrated: its decoded v1 node, raw JSON, parent and
/// document, and the helpers type handlers ([TypeMigration]) use.
class V1Node {
  V1Node(this.n, this.parent, this.nodes, this.report, {this.states = true})
      : raw = Map<String, Object?>.from(n.toJson());

  /// Whether its interaction states are converted (off while migrating a
  /// state's targets).
  final bool states;

  final BaseNode n;
  final BaseNode? parent;
  final Map<String, BaseNode> nodes;
  final MigrationReport report;
  final Json raw;
  final Set<String> used = {
    'id', 'type', 'parentID', 'basicBoxLocal', 'outerBoxLocal', 'retainedOuterBoxLocal', 'innerBoxLocal', //
    'name', 'children',
  };

  /// The v1 value of [key], marked as migrated (not left under `v1`).
  Object? take(String key) {
    used.add(key);
    return raw[key];
  }

  Json run() {
    final handler = typeMigrations[n.type];
    final type = handler?.type(n) ?? v2TypeOf(n);
    report.nodes++;
    report.types.update(type, (v) => v + 1, ifAbsent: () => 1);
    final ported =
        handler != null || n is RowColumnMixin || n is FreeformPlaceholderNode || portedV1Types.contains(n.type);
    final out = <String, Object?>{'type': type};
    if (n.name.isNotEmpty) out['name'] = n.name;

    // Children.
    if (n is CanvasNode) {
      // A canvas's own flex alignment is unused (its body is laid out).
      take('mainAxisAlignment');
      take('crossAxisAlignment');
      take('properties');
      final body = (n as CanvasNode).properties.bodyId;
      if (nodes.containsKey(body)) out['slots'] = {'body': body};
    } else if (handler?.children != null || handler?.slots != null) {
      final kids = handler!.children?.call(this) ?? const [];
      if (kids.isNotEmpty) out['children'] = kids;
      final slots = handler.slots?.call(this) ?? const {};
      if (slots.isNotEmpty) out['slots'] = slots;
    } else {
      final kids = ownedChildren(n);
      if (kids.isNotEmpty) out['children'] = kids;
    }

    if (take('visible') == false) out['visible'] = false;
    if (n is BlendMixin) {
      take('opacity');
      final o = (n as BlendMixin).opacity;
      if (o < 1) out['opacity'] = roundNum(o.clamp(0, 1));
    }
    out['layout'] = _layout();
    if (const {'stack', 'box', 'row', 'column', 'canvas', 'variance'}.contains(type) || !ported || (handler?.decorated ?? false)) {
      final d = decoration();
      if (d.isNotEmpty) out['decoration'] = d;
    }
    // A group's handler first: some v1 types it ports carry core mixins
    // (an accordion is a RowColumnMixin).
    final props = handler != null
        ? handler.props(this)
        : switch (n) {
            CanvasNode() => _canvasProps(),
            RowColumnMixin() => _flexProps(),
            FrameNode() || RectangleNode() || FreeformPlaceholderNode() => _stackProps(),
            TextNode() => _textProps(),
            IconNode() => _iconProps(),
            VarianceNode() => _varianceProps(),
            _ => <String, Object?>{},
          };
    // Behaviours (motion, loops, transitions, ink, states...), before an
    // unported type's own fields go along raw.
    final behaviours = migrateBehaviours(this, states: states);
    // Blurs act on whatever the node paints: a type without a box
    // decoration keeps them (only them) in its decoration.
    bool blur(Effect e) => e.type == EffectType.layerBlur || e.type == EffectType.backgroundBlur;
    // (Shadows are the type's own to map; while it doesn't, they're left.)
    if (!out.containsKey('decoration') &&
        n is BlendMixin &&
        (used.contains('effects') || (n as BlendMixin).effects.every(blur))) {
      take('effects');
      final blurs = [
        for (final e in (n as BlendMixin).effects)
          if (blur(e)) effect(e),
      ];
      if (blurs.isNotEmpty) out['decoration'] = {'effects': blurs};
    }
    if (!ported) {
      report.unportedTypes.update(n.type, (v) => v + 1, ifAbsent: () => 1);
      // Not declared in v2 yet: its own v1 fields go along raw, as props.
      for (final e in raw.entries) {
        if (!used.contains(e.key) && !_common.contains(e.key)) {
          props[e.key] = e.value;
          used.add(e.key);
        }
      }
    }
    if (props.isNotEmpty) out['props'] = props;

    final vars = take('variables');
    // Derived (which variables a text reads): v2 reads the text itself.
    take('multipleVariables');
    if (vars is Map && vars.isNotEmpty) {
      final bind = <String, Object?>{};
      for (final e in vars.entries) {
        if (e.value is! String) continue;
        final path = v2BindPath(n, type, '${e.key}');
        if (path == null) report.unmappedBindings.update('${n.type}.${e.key}', (v) => v + 1, ifAbsent: () => 1);
        final raw = e.value as String;
        // A fixed direction is the node's own (below).
        final expression = path == 'textDirection' && !raw.contains(r'${') ? raw : v2BindExpression(path, raw);
        if (expression == null) {
          report.ineffectiveBindings.update('${n.type}.${e.key}', (v) => v + 1, ifAbsent: () => 1);
          continue;
        }
        bind[path ?? '${e.key}'] = expression;
      }
      // A fixed direction (not a binding) is the node's own.
      if (bind['textDirection'] case final String d when !d.contains(r'${')) {
        bind.remove('textDirection');
        final rtl = const {'rtl', 'right-to-left', 'righttoleft', 'true'}.contains(d.trim().toLowerCase());
        final ltr = const {'ltr', 'left-to-right', 'lefttoright', 'false'}.contains(d.trim().toLowerCase());
        if (rtl || ltr) behaviours['textDirection'] = rtl ? 'rtl' : 'ltr';
      }
      if (bind.isNotEmpty) out['bind'] = bind;
    }
    final reactions = take('reactions');
    if (reactions is List && reactions.isNotEmpty) out['actions'] = reactions;

    out.addAll(behaviours);

    final leftover = <String, Object?>{
      for (final e in raw.entries)
        if (!used.contains(e.key)) e.key: e.value,
    };
    if (leftover.isNotEmpty) {
      out['v1'] = leftover;
      for (final k in leftover.keys) {
        report.unmapped.update('${n.type}.$k', (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return out;
  }

  static const _common = {'variables', 'reactions', 'multipleVariables'};

  // --- layout ---------------------------------------------------------------

  static String fit(SizeFit f) => switch (f) {
        SizeFit.fixed || SizeFit.locked => 'fixed',
        SizeFit.expanded => 'fill',
        SizeFit.flexible => 'flexible',
        SizeFit.shrinkWrap => 'hug',
      };

  static Object axisSize(SizeFit f, double v) => fit(f) == 'fixed' ? roundNum(v) : {fit(f): roundNum(v)};

  static Object insets(EdgeInsetsModel e) =>
      e.l == e.t && e.t == e.r && e.r == e.b ? roundNum(e.l) : [roundNum(e.l), roundNum(e.t), roundNum(e.r), roundNum(e.b)];

  Json _layout() {
    for (final k in const [
      'horizontalFit', 'verticalFit', 'flex', 'squeezable', 'constraints', 'margin', 'padding', 'edgePins', //
      'positioningMode', 'alignment', 'rotation', 'layoutAspectRatio',
    ]) {
      take(k);
    }
    final box = n.basicBoxLocal;
    final l = <String, Object?>{
      'width': axisSize(n.horizontalFit, box.width),
      'height': axisSize(n.verticalFit, box.height),
    };
    if (n.flex != 1) l['flex'] = n.flex;
    if (n.squeezable) l['squeezable'] = true;
    final c = n.constraints;
    if (!c.isEmpty) {
      l['constraints'] = {
        if (c.minWidth != null) 'minWidth': roundNum(c.minWidth!),
        if (c.maxWidth != null) 'maxWidth': roundNum(c.maxWidth!),
        if (c.minHeight != null) 'minHeight': roundNum(c.minHeight!),
        if (c.maxHeight != null) 'maxHeight': roundNum(c.maxHeight!),
      };
    }
    if (n.margin != EdgeInsetsModel.zero) l['margin'] = insets(n.margin);
    final padding = n.resolvedPadding();
    if (padding != EdgeInsetsModel.zero) l['padding'] = insets(padding);
    if (n.rotationDegrees != 0) l['rotation'] = roundNum(n.rotationDegrees);
    final ratio = n.layoutAspectRatio;
    if (ratio != null && ratio.isFinite && ratio > 0) l['aspectRatio'] = ratio;

    final p = parent;
    final align = n.alignment.data;
    if ((p is RowColumnMixin || (typeMigrations[p?.type]?.flexChildren ?? false)) && align != null) l['align'] = [roundNum(align.x), roundNum(align.y)];
    if (p != null && isFreeformParent(p)) {
      final x = _axis(p, horizontal: true), y = _axis(p, horizontal: false);
      if (!(x.length == 1 && x['start'] == 0)) l['x'] = x;
      if (!(y.length == 1 && y['start'] == 0)) l['y'] = y;
    } else if (p == null || p is CanvasNode) {
      // Top-level canvases and canvas bodies: where v1 stored them.
      final o = n.basicBoxLocal;
      if (o.x != 0) l['x'] = {'start': roundNum(o.x)};
      if (o.y != 0) l['y'] = {'start': roundNum(o.y)};
    }
    return l;
  }

  /// v1's freeform placement for one axis (PassiveStackTransformer
  /// `_axisPlacement`), resolved once into a v2 position.
  Json _axis(BaseNode parent, {required bool horizontal}) {
    final n = this.n;
    final outer = n.outerBoxLocal;
    final inner = parent.innerBoxLocal;
    final scrollAxis = parent is ScrollableMixin && (parent).isScrollable
        ? (parent).scrollDirection
        : null;
    final isScrollAxis = scrollAxis != null && (scrollAxis == AxisC.horizontal) == horizontal;
    final extent = horizontal ? outer.width : outer.height;
    final parentExtent = horizontal ? inner.width : inner.height;
    final fit = horizontal ? n.horizontalFit : n.verticalFit;
    final expands = fit == SizeFit.expanded &&
        (horizontal ? n.resolvedConstraints.maxWidth : n.resolvedConstraints.maxHeight) == null;
    final wraps = fit == SizeFit.shrinkWrap;
    final pins = n.edgePins;
    final startPin = switch (horizontal ? pins.left : pins.top) {
      final double pin => pin - (horizontal ? inner.edgeLeft : inner.edgeTop),
      null => null,
    };
    final endPin = switch (horizontal ? pins.right : pins.bottom) {
      final double pin => pin - (horizontal ? inner.edgeRight : inner.edgeBottom),
      null => null,
    };
    final placedByPins = endPin != null || n.positioningMode == PositioningMode.pin;
    final double start;
    if (placedByPins && startPin != null) {
      start = startPin;
    } else if (placedByPins && endPin != null) {
      start = parentExtent - endPin - extent;
    } else {
      start = horizontal ? outer.x - inner.edgeLeft : outer.y - inner.edgeTop;
    }
    Json at(double s) => {'start': roundNum(s)};
    Json aligned(double a) => {'align': roundNum(a)};

    if (n.alignment.data case final AlignmentData a) return aligned(horizontal ? a.x : a.y);
    if (expands || isScrollAxis) return at(start);
    final parentWraps = (horizontal ? parent.horizontalFit : parent.verticalFit) == SizeFit.shrinkWrap;
    if (startPin != null && endPin != null && !wraps) return {'start': roundNum(startPin), 'end': roundNum(endPin)};
    if (startPin != null && endPin != null && !parentWraps) {
      final pinned = math.max(0, startPin) + math.max(0, endPin);
      if (pinned > 0) return aligned(2 * math.max(0, startPin) / pinned - 1);
    }
    if (endPin != null && startPin == null) return {'end': roundNum(endPin)};
    if (endPin == null && !parentWraps && n.positioningMode == PositioningMode.align) {
      // Keeps its share of the free space (measured at design size).
      if (parentExtent - extent > 0) return {'relative': roundNum(start)};
    }
    return at(start);
  }

  // --- decoration -----------------------------------------------------------

  static String rgb(ColorRGB c) => Color8.hex(255, c.r, c.g, c.b);
  static String rgba(ColorRGBA c) => Color8.hex((c.a * 255).toInt(), c.r, c.g, c.b);

  /// [p] as a v2 paint; [node] is the node it fills (an image fill placed
  /// by hand is resolved against its design size).
  static Json? paint(PaintModel p, [BaseNode? node]) {
    final type = switch (p.type) {
      PaintType.solid => 'solid',
      PaintType.gradientLinear => 'linear',
      PaintType.gradientRadial => 'radial',
      PaintType.gradientAngular => 'sweep',
      PaintType.gradientDiamond => 'diamond',
      PaintType.image => 'image',
      _ => null,
    };
    if (type == null) return null;
    final j = <String, Object?>{};
    if (type != 'solid') j['type'] = type;
    j['id'] = p.id;
    if (!p.visible) j['visible'] = false;
    if (p.opacity != 1) j['opacity'] = p.opacity;
    if (p.blendMode != BlendModeC.srcOver) j['blendMode'] = p.blendMode.name;
    if (p.color case final ColorRGB c) j['color'] = rgb(c);
    if (p.gradientStops case final List<ColorStop> stops when stops.isNotEmpty) {
      j['stops'] = [for (final s in stops) {'position': s.position, 'color': rgba(s.color)}];
    }
    if (p.gradientTransform case final List<num> t when t.isNotEmpty) j['transform'] = t;
    if (p.gradientTileMode != GradientTileMode.clamp) j['tileMode'] = p.gradientTileMode.name;
    if (type == 'image') j['image'] = imagePaint(p, node);
    return j;
  }

  /// An image paint as SDK 8.x drew it (`buildFill`, `UltimateImageBuilder`):
  /// the cropped image when there is one, its fit, alignment, repeat, pixel
  /// scale (`min(scaleX, scaleY)`), flips, tint and saturation.
  static Json imagePaint(PaintModel p, [BaseNode? node]) {
    final pj = Map<String, Object?>.from(p.toJson());
    final scale = math.min(p.scaleX, p.scaleY).abs();
    final image = <String, Object?>{
      if ((p.croppedImageURL ?? p.downloadUrl) case final String url) 'url': url,
      if (p.assetID case final String a) 'assetId': a,
      if (p.fit.name != 'cover') 'fit': p.fit.name,
      if (p.alignment.data case final AlignmentData a) 'alignment': [a.x, a.y],
      if (p.imageRepeat.name != 'noRepeat') 'repeat': p.imageRepeat.name,
      if (scale != 1 && scale != 0) 'scale': roundNum(scale),
      if (p.imageTint case final ColorRGBA t) 'tint': rgba(t),
      if (p.scaleX < 0) 'flipX': true,
      if (p.scaleY < 0) 'flipY': true,
      if (p.saturation != 1) 'saturation': roundNum(p.saturation),
      if (node != null) ...?_imageRect(p, node),
    };
    // Editor settings: the crop the cropped image was made with, the source
    // image and its size, names.
    for (final k in const [
      'imageTransform', 'cropData', 'imageName', 'imageHash', 'downloadUrl', 'croppedImageURL', 'sourceWidth', //
      'sourceHeight', 'hasImageBytes',
    ]) {
      if (pj[k] != null && pj[k] != false) image[k] = pj[k];
    }
    return image;
  }

  /// SDK 8.x places an image by hand (a stack, not the image's alignment)
  /// where Flutter can't align it (`isCustomPositionRequiredForImage`): at
  /// its source size over its scale, aligned in the node's design box.
  static Json? _imageRect(PaintModel p, BaseNode node) {
    final box = node.basicBoxLocal;
    // The image's width and height as buildFill gives them: none when the
    // node hugs (then it isn't placed by hand).
    final double? w = switch (node.horizontalFit) {
      SizeFit.shrinkWrap => null,
      SizeFit.expanded => double.infinity,
      _ => box.width,
    };
    final double? h = switch (node.verticalFit) {
      SizeFit.shrinkWrap => null,
      SizeFit.expanded => double.infinity,
      _ => box.height,
    };
    final sw = p.sourceWidth, sh = p.sourceHeight;
    if (w == null || h == null || sw == null || sh == null) return null;
    if (!p.fit.supportsAlignment || p.alignment.isStandard) return null;
    bool close(double v) => v.abs() <= 1e-8;
    var custom = p.isNonUniformScale;
    if (!custom && (p.fit == Fit.fitWidth || p.fit == Fit.fitHeight)) custom = close(sw / sh - w / h);
    if (!custom) custom = sw / p.scaleX.abs() == w || sh / p.scaleY.abs() == h;
    if (!custom) return null;
    final double cw = switch (p.fit) {
      Fit.fitWidth => box.width,
      Fit.fitHeight => sw / sh * box.height,
      _ => sw / p.scaleX.abs(),
    };
    final double ch = switch (p.fit) {
      Fit.fitHeight => box.height,
      Fit.fitWidth => box.width / (sw / sh),
      _ => sh / p.scaleY.abs(),
    };
    // convertAlignmentToPosition.
    final a = p.alignment.data;
    double place(double parent, double child, double align) {
      final delta = parent - child;
      final same = close(delta);
      final d = (same ? child : delta) / 2;
      return d + (align - (same ? 1 : 0)) * d;
    }

    return {
      'rect': [
        roundNum(place(box.width, cw, a?.x ?? 0)),
        roundNum(place(box.height, ch, a?.y ?? 0)),
        roundNum(cw),
        roundNum(ch),
      ],
    };
  }

  static Json? effect(Effect e) {
    final j = <String, Object?>{'type': e.type.name};
    if (!e.visible) j['visible'] = false;
    if (e.type == EffectType.dropShadow || e.type == EffectType.innerShadow) {
      j['color'] = rgba(e.color ?? ColorRGBA.black);
      final o = e.offset;
      if (o != null && (o.x != 0 || o.y != 0)) j['offset'] = [o.x, o.y];
      if ((e.spread ?? 0) != 0) j['spreadRadius'] = e.spread;
    }
    if (e.radius != 0) j['blurRadius'] = e.radius;
    if (e.blendMode != null && e.blendMode != BlendModeC.srcOver) j['blendMode'] = e.blendMode!.name;
    return j;
  }

  Json decoration() {
    final d = <String, Object?>{};
    final n = this.n;
    if (n is GeometryMixin) {
      final g = n;
      for (final k in const ['fills', 'strokes', 'strokeWeight', 'strokeAlign', 'strokeSide', 'dashPattern', 'strokeCap']) {
        take(k);
      }
      final fills = [...g.fills.map((p) => paint(p, n)).nonNulls];
      if (fills.isNotEmpty) d['fills'] = fills;
      final strokes = [...g.strokes.map(paint).nonNulls];
      if (strokes.isNotEmpty) {
        d['strokes'] = strokes;
        if (g.strokeWeight != 1) d['strokeWidth'] = g.strokeWeight;
        if (g.strokeAlign != StrokeAlignC.inside) d['strokeAlign'] = g.strokeAlign.name;
        if (g.strokeSide != StrokeSide.all) d['strokeSides'] = g.strokeSide.name;
        if (g.dashPattern.isNotEmpty) d['dashPattern'] = g.dashPattern;
        if (g.strokeCap.name != 'butt') d['strokeCap'] = g.strokeCap.name;
      }
    }
    if (n is DefaultShapeNode) {
      take('foregroundFills');
      final fg = [...n.foregroundFills.map(paint).nonNulls];
      if (fg.isNotEmpty) d['foregroundFills'] = fg;
      take('effects');
      final effects = [...n.effects.map(effect).nonNulls];
      if (effects.isNotEmpty) d['effects'] = effects;
    }
    if (n is CornerMixin) {
      take('cornerRadius');
      final r = (n).cornerRadius;
      final tl = r.tl.x, tr = r.tr.x, br = r.br.x, bl = r.bl.x;
      if (tl != 0 || tr != 0 || br != 0 || bl != 0) {
        d['radius'] = tl == tr && tr == br && br == bl ? roundNum(tl) : [roundNum(tl), roundNum(tr), roundNum(br), roundNum(bl)];
      }
    }
    if (n is ClipMixin) {
      take('clipsContent');
      if ((n).clipsContent) d['clip'] = 'hardEdge';
    }
    if (n is BlendMixin) {
      take('blendMode');
      final b = (n).blendMode;
      if (b != BlendModeC.srcOver) d['blendMode'] = b.name;
    }
    return d;
  }

  // --- props ----------------------------------------------------------------

  Json scrollProps() {
    final n = this.n;
    final p = <String, Object?>{};
    if (n is! ScrollableMixin) return p;
    for (final k in const ['isScrollable', 'scrollDirection', 'reverse', 'physics', 'shouldAlwaysScroll']) {
      take(k);
    }
    final s = n;
    // The scroll settings of a node that doesn't scroll are inert.
    if (!s.isScrollable) return p;
    p['scrollable'] = true;
    if (s.scrollDirection != AxisC.vertical) p['scrollDirection'] = s.scrollDirection.name;
    if (s.reverse) p['reverse'] = true;
    final physics = switch (s.physics) {
      ScrollPhysicsC.bouncingScrollPhysics => 'bouncing',
      ScrollPhysicsC.clampingScrollPhysics => 'clamping',
      ScrollPhysicsC.neverScrollableScrollPhysics => 'never',
      ScrollPhysicsC.rangeMaintainingScrollPhysics => 'rangeMaintaining',
      _ => null,
    };
    if (physics != null) p['physics'] = physics;
    if (s.shouldAlwaysScroll) p['alwaysScroll'] = true;
    // A row/column may let its scrolled children's shadows paint past it.
    if (n is RowColumnNode) {
      take('clipsScrollContent');
      if (!n.clipsScrollContent && !n.clipsContent) p['clipBehavior'] = 'none';
    }
    return p;
  }

  Json _flexProps() {
    final rc = n as RowColumnMixin;
    for (final k in const ['rowColumnType', 'mainAxisAlignment', 'crossAxisAlignment', 'spacing', 'wrap', 'runSpacing']) {
      take(k);
    }
    final p = <String, Object?>{};
    if (rc.mainAxisAlignment != MainAxisAlignmentC.start) p['mainAxisAlignment'] = rc.mainAxisAlignment.name;
    if (rc.crossAxisAlignment != CrossAxisAlignmentC.center) p['crossAxisAlignment'] = rc.crossAxisAlignment.name;
    if (rc.spacing != 0) p['spacing'] = roundNum(rc.spacing);
    if (rc.wrap) p['wrap'] = true;
    if (rc.runSpacing != 0) p['runSpacing'] = roundNum(rc.runSpacing);
    return {...p, ...scrollProps()};
  }

  Json _stackProps() {
    final p = scrollProps();
    final n = this.n;
    if (n is RectangleNode) {
      take('path');
      take('strokeJoin');
      take('strokeMiterLimit');
      if (n.hasPath) {
        p['path'] = n.path;
        if (n.strokeJoin.name != 'miter') p['strokeJoin'] = n.strokeJoin.name;
        if (n.strokeMiterLimit != 4) p['strokeMiterLimit'] = roundNum(n.strokeMiterLimit);
      }
    }
    return p;
  }

  Json _canvasProps() {
    take('scaleMode');
    final c = n as CanvasNode;
    return {if (c.scaleMode.name != 'responsive') 'scaleMode': c.scaleMode.name};
  }

  Json _iconProps() {
    final i = n as IconNode;
    take('properties');
    final icon = i.properties.icon;
    final p = <String, Object?>{};
    final iconJson = icon.icon?.toJson();
    p['icon'] = {
      'source': icon.type.name,
      ...?iconJson,
      'image': ?icon.iconImage,
      if (icon.show == false) 'show': false,
      // Material Symbols axes, and an image icon's pixel scale.
      'fill': ?icon.fill,
      'weight': ?icon.weight,
      'grade': ?icon.grade,
      'opticalSize': ?icon.opticalSize,
      'size': ?icon.size,
      if (icon.scale != 1) 'scale': icon.scale,
    };
    if (icon.color case final ColorRGBA c) p['color'] = rgba(c);
    return p;
  }

  Json _varianceProps() {
    final v = n as VarianceNode;
    take('variants');
    take('currentVariantId');
    return {
      'variants': [for (final variant in v.variants) Map<String, Object?>.from(variant.toJson())],
      'current': v.currentVariantId,
    };
  }

  Json _textProps() {
    final t = n as TextNode;
    for (final k in const [
      'data', 'textMixedProps', 'textAlignHorizontal', 'textAlignVertical', 'maxLines', 'overflow',
      'tabularFigures', 'selectable',
    ]) {
      take(k);
    }
    final p = <String, Object?>{'text': t.data};
    final runs = [
      for (final r in t.textMixedProps) {'start': r.start, 'end': r.end, 'style': textStyle(r), if (r.link.isNotEmpty) 'link': r.link},
    ];
    if (runs.isNotEmpty) p['runs'] = runs;
    final align = switch (t.textAlignHorizontal) {
      TextAlignHorizontalEnum.left || TextAlignHorizontalEnum.start => null,
      TextAlignHorizontalEnum.end => 'end',
      TextAlignHorizontalEnum.center => 'center',
      TextAlignHorizontalEnum.right => 'right',
      TextAlignHorizontalEnum.justified => 'justify',
    };
    if (align != null) p['textAlign'] = align;
    if (t.textAlignVertical != TextAlignVerticalEnum.top) p['textAlignVertical'] = t.textAlignVertical.name;
    if (t.maxLines != null) p['maxLines'] = t.maxLines;
    if (t.overflow == TextOverflowC.scaleDown) {
      p['scaleDown'] = true;
    } else if (t.overflow != TextOverflowC.clip) {
      p['overflow'] = t.overflow.name;
    }
    final raw = this.raw;
    final base = <String, Object?>{
      if (raw['tabularFigures'] == true) 'tabularFigures': true,
    };
    // Node drop shadows are text shadows (retrieveTextStyle).
    take('effects');
    final shadows = [
      for (final e in t.effects)
        if (e.type == EffectType.dropShadow && e.visible) effect(e),
    ];
    if (shadows.isNotEmpty) base['shadows'] = shadows;
    if (base.isNotEmpty) p['style'] = base;
    if (raw['selectable'] == true) p['selectable'] = true;
    return p;
  }

  /// A v1 text run's style, as SDK v1's `retrieveTextStyleFromProp` built it.
  static Json textStyle(TextProp r) {
    final s = <String, Object?>{};
    final f = r.fontName;
    s['fontFamily'] = f.family;
    s['fontWeight'] = _weight(f);
    if (f.style.toLowerCase().contains('italic')) s['fontStyle'] = 'italic';
    s['fontSize'] = r.fontSize;
    // The first paint with a color, opacity applied (retrievePropColor).
    for (final fill in r.fills) {
      if (fill.color case final ColorRGB c) {
        s['color'] = Color8.hex((fill.opacity * 255).toInt(), c.r, c.g, c.b);
        break;
      }
    }
    final ls = switch (r.letterSpacing.unit) {
      LetterSpacingUnitEnum.pixels => r.letterSpacing.value,
      LetterSpacingUnitEnum.percent => r.letterSpacing.value * r.fontSize / 100,
    };
    if (ls != 0) s['letterSpacing'] = ls;
    final lh = r.lineHeight;
    final double? height = lh.value == null || lh.value! <= 0
        ? null
        : switch (lh.unit) {
            LineHeightUnitEnum.pixels => lh.value! / r.fontSize,
            LineHeightUnitEnum.percent => lh.value! / 100,
            LineHeightUnitEnum.auto => null,
          };
    if (height != null) s['height'] = height;
    if (r.textDecoration != TextDecorationEnum.none) {
      s['decoration'] = r.textDecoration == TextDecorationEnum.strikethrough ? 'lineThrough' : r.textDecoration.name;
    }
    if (r.decorationColor case final ColorRGBA c) s['decorationColor'] = rgba(c);
    if (r.decorationThickness case final double t) s['decorationThickness'] = t;
    if (r.decorationStyle.name != 'solid') s['decorationStyle'] = r.decorationStyle.name;
    return s;
  }

  static int _weight(FontName f) {
    if (f.weight case final FontWeightNumeric w) return int.parse(w.name.substring(1));
    final style = f.style.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    if (style.contains('thin')) return 100;
    if (style.contains('extralight')) return 200;
    if (style.contains('light')) return 300;
    if (style.contains('normal')) return 400;
    if (style.contains('medium')) return 500;
    if (style.contains('semibold')) return 600;
    if (style.contains('extrabold')) return 800;
    if (style.contains('ultrabold')) return 900;
    if (style.contains('bold')) return 700;
    if (style.contains('black')) return 900;
    return 400;
  }
}

/// 8-bit color conversion exactly as SDK v1 did it (`(c * 255).toInt()`).
abstract final class Color8 {
  static String hex(int a, double r, double g, double b) {
    String c(int v) => v.clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#${c(a)}${c((r * 255).toInt())}${c((g * 255).toInt())}${c((b * 255).toInt())}';
  }
}
