import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'behaviors.dart';
import 'bindings.dart' show BindPaths;
import 'catalog.dart';
import 'components.dart';
import 'decoration.dart';
import 'json.dart';
import 'layout.dart';
import 'props.dart';
import 'media.dart';
import 'node_patch.dart';
import 'breakpoints.dart';
import 'triggers.dart';
import 'values/paint.dart' show Effect, EffectType, listEquals;
import 'widgets/canvas.dart';

/// One node: a widget declaration's values, placed in a tree by id.
///
/// Immutable, with value equality over every field, so "did this node
/// change?" is `==`. It holds no parent pointer (the document derives the
/// parent index) and no computed geometry.
@immutable
final class Node {
  const Node({
    required this.id,
    required this.type,
    this.name = '',
    this.key = '',
    this.children = const [],
    this.slots = const {},
    this.visible = true,
    this.opacity = 1,
    this.layout = const Layout(),
    this.decoration = Decoration.none,
    this.props = Props.empty,
    this.bind = const {},
    this.actions = const [],
    this.behaviors = Behaviors.none,
    this.component,
    this.media = const [],
    this.extra = const {},
    this.catalog,
  });

  final String id;

  /// The widget type: a key of [Widgets].
  final String type;
  final String name;

  /// The node's name within the tree it was inserted with, unique in that
  /// tree (`"content"`): a stable handle the tree's own actions and states
  /// name it by before it has an id, kept so an export gives the tree back
  /// with its keys. Empty for none; it doesn't affect rendering.
  final String key;

  /// Ordered children.
  final List<String> children;

  /// Named children, by slot.
  final Map<String, String> slots;
  final bool visible;
  final double opacity;
  final Layout layout;
  final Decoration decoration;
  final Props props;

  /// Bound properties: a binding path (`visible`, `props.text`,
  /// `layout.width`, `decoration.fills.<paintId>`; see [BindPaths] and
  /// DESIGN.md §5.1) → an expression (`${user.name}`, `${= qty * 2}`).
  final Map<String, String> bind;

  /// Reactions: trigger → the chain of actions it runs.
  final List<Reaction> actions;

  /// Motion, loops, transitions, ink, interaction states, drag and drop...
  /// (stored flat in the node's JSON, under [Behaviors.keys]).
  final Behaviors behaviors;

  /// The component this node is the main node of, or the top node of an
  /// instance of (DESIGN.md §4.2).
  final ComponentLink? component;

  /// Its own fields by screen size, as CSS media queries: rules whose
  /// conditions (`minWidth`, `maxWidth`: px or a breakpoint name;
  /// `orientation`) hold patch the node, in order.
  final List<MediaRule> media;

  /// This node as shown on a screen [width] × [height]: its [media] rules
  /// that hold, merged over it in order. Itself when none holds.
  Node atScreen(double width, double? height, Breakpoints breakpoints) {
    if (media.isEmpty) return this;
    final patch = mediaPatchAt(media, width, height, breakpoints, props: spec?.props);
    return patch == null ? this : patched(patch);
  }

  /// Keys this version doesn't model, round-tripped.
  final Json extra;

  /// The catalog this node was decoded with; null for a node built in code
  /// (its [spec] is then [Catalog.current]'s). Not part of its value: two
  /// nodes with the same fields are equal whatever catalog read them.
  final Catalog? catalog;

  /// The declaration, or null for a type the node's catalog doesn't declare.
  WidgetSpec? get spec => (catalog ?? Catalog.current).widget(type);

  /// Every child id: slots, then the ordered children, then (for a
  /// variance) each variant's children.
  Iterable<String> get childIds sync* {
    yield* slots.values;
    yield* children;
    if (type == VarianceProps.spec.type) {
      for (final v in props.get(VarianceProps.variants)) {
        for (final c in readStrings(v['children'])) {
          if (!children.contains(c)) yield c;
        }
      }
    }
  }

  T prop<T>(PropDef<T> def) => props.get(def);

  Node withProp<T>(PropDef<T> def, T value) => copyWith(props: props.set(def, value));

  /// This node linked to a component, or unlinked (null).
  Node withComponent(ComponentLink? link) => Node(
        id: id,
        type: type,
        name: name,
        key: key,
        children: children,
        slots: slots,
        visible: visible,
        opacity: opacity,
        layout: layout,
        decoration: decoration,
        props: props,
        bind: bind,
        actions: actions,
        behaviors: behaviors,
        component: link,
        media: media,
        extra: extra,
        catalog: catalog,
      );

  Node copyWith({
    String? id,
    String? type,
    String? name,
    String? key,
    List<String>? children,
    Map<String, String>? slots,
    bool? visible,
    double? opacity,
    Layout? layout,
    Decoration? decoration,
    Props? props,
    Map<String, String>? bind,
    List<Reaction>? actions,
    Behaviors? behaviors,
    ComponentLink? component,
    List<MediaRule>? media,
    Json? extra,
  }) =>
      Node(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        key: key ?? this.key,
        children: children ?? this.children,
        slots: slots ?? this.slots,
        visible: visible ?? this.visible,
        opacity: opacity ?? this.opacity,
        layout: layout ?? this.layout,
        decoration: decoration ?? this.decoration,
        props: props ?? this.props,
        bind: bind ?? this.bind,
        actions: actions ?? this.actions,
        behaviors: behaviors ?? this.behaviors,
        component: component ?? this.component,
        media: media ?? this.media,
        extra: extra ?? this.extra,
        catalog: catalog,
      );

  static const _keys = {
    'id', 'type', 'name', 'key', 'children', 'slots', 'visible', 'opacity', 'layout', 'decoration', 'props', 'bind', //
    'actions', 'component', 'media',
  };

  /// This node with [patch] (a JSON merge patch over its JSON, as an
  /// interaction state's) applied, as its declarations read it: a value of
  /// a union type (a size, a position, a paint...) written in another form
  /// is replaced, not merged ([mergeNodePatch]).
  Node patched(Json patch) =>
      Node.fromJson(mergeNodePatch(toJson(), patch, props: spec?.props), id: id, catalog: catalog) ?? this;

  /// Decodes a node with [catalog] (default: [Catalog.current]); [id] wins
  /// over the JSON's own (the document map key). Returns null only when
  /// there's no type. A type the catalog doesn't declare keeps its props
  /// raw ([Props.unknown]).
  static Node? fromJson(Object? json, {String? id, Catalog? catalog}) {
    final c = catalog ?? Catalog.current;
    return identical(c, Catalog.current) ? _fromJson(json, id, c) : Catalog.run(c, () => _fromJson(json, id, c));
  }

  static Node? _fromJson(Object? json, String? id, Catalog catalog) {
    final m = readMap(json);
    final type = readString(m?['type']);
    if (m == null || type == null || type.isEmpty) return null;
    final spec = catalog.widget(type);
    final slots = readMap(m['slots']);
    final bind = readMap(m['bind']);
    final motion = readMap(m['motion']);
    // A legacy motion's opacity and blur are the node's: its opacity
    // (multiplied in) and a layer blur.
    final motionOpacity = readDouble(motion?['opacity'])?.clamp(0.0, 1.0);
    final binds = Behaviors.migrateBind({
      if (bind != null)
        for (final e in bind.entries)
          if (e.value is String) e.key: e.value as String,
    }, m);
    var decoration = spec == null || spec.decorated
        ? Decoration.fromJson(m['decoration'])
        : Decoration(effects: [...Decoration.fromJson(m['decoration']).effects.where((e) => !e.isShadow)]);
    if (motion != null && (motion.containsKey('blur') || (bind?.containsKey('motion.blur') ?? false))) {
      const id = AnimationPresets.motionBlurId;
      final blur = math.max(0.0, readDouble(motion['blur']) ?? 0);
      decoration = decoration.copyWith(effects: [
        ...decoration.effects.where((e) => e.id != id),
        Effect(type: EffectType.layerBlur, id: id, blurRadius: blur),
      ]);
    }
    return Node(
      id: id ?? readString(m['id']) ?? '',
      type: type,
      name: readString(m['name']) ?? '',
      key: readString(m['key']) ?? '',
      children: readStrings(m['children']),
      slots: {
        if (slots != null)
          for (final e in slots.entries)
            if (e.value is String) e.key: e.value as String,
      },
      visible: readBool(m['visible']) ?? true,
      opacity: ((readDouble(m['opacity']) ?? 1).clamp(0, 1) * (motionOpacity ?? 1)).toDouble(),
      layout: Layout.fromJson(m['layout']),
      // A type without a box decoration keeps only its blurs (they act on
      // whatever it paints).
      decoration: decoration,
      props: Props.fromJson(spec, m['props']),
      bind: _migrateOpacityBind(binds, readDouble(m['opacity']) ?? 1, motionOpacity ?? 1),
      actions: Reaction.listFromJson(m['actions']),
      behaviors: Behaviors.fromJson(m),
      component: ComponentLink.fromJson(m['component']),
      media: MediaRule.listFromJson(m['media']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key) && !Behaviors.keys.contains(e.key) && !Behaviors.legacyKeys.contains(e.key)) e.key: e.value,
      },
      catalog: catalog,
    );
  }

  /// [bind] with a legacy `motion.opacity` binding as the node's
  /// `opacity`: the two multiplied ([own] and [motion] are the static
  /// values), or the motion's alone when the node's is 1 and unbound.
  static Map<String, String> _migrateOpacityBind(Map<String, String> bind, double own, double motion) {
    final m = bind['motion.opacity'];
    final node = bind['opacity'];
    if (m == null) {
      // The node's bound opacity times the motion's static one.
      final f = node == null || motion == 1 ? null : Behaviors.formulaOf(node);
      return f == null ? bind : {...bind, 'opacity': '\${= ($f) * ${writeDouble(motion)}}'};
    }
    final out = {...bind}..remove('motion.opacity');
    if (node == null && own == 1) {
      out['opacity'] = m;
      return out;
    }
    final a = node == null ? writeDouble(own).toString() : Behaviors.formulaOf(node);
    final b = Behaviors.formulaOf(m);
    out['opacity'] = a == null || b == null ? m : '\${= ($a) * ($b)}';
    return out;
  }

  Json toJson() {
    final j = <String, Object?>{'id': id, 'type': type};
    if (name.isNotEmpty) j['name'] = name;
    if (key.isNotEmpty) j['key'] = key;
    if (children.isNotEmpty) j['children'] = children;
    if (slots.isNotEmpty) j['slots'] = slots;
    if (!visible) j['visible'] = false;
    if (opacity != 1) j['opacity'] = writeDouble(opacity);
    j['layout'] = layout.toJson();
    if (!decoration.isNone) j['decoration'] = decoration.toJson();
    if (!props.isEmpty) j['props'] = props.toJson(spec);
    if (bind.isNotEmpty) j['bind'] = bind;
    if (actions.isNotEmpty) j['actions'] = [for (final r in actions) r.toJson()];
    behaviors.writeTo(j);
    if (component != null) j['component'] = component!.toJson();
    if (media.isNotEmpty) j['media'] = [for (final r in media) r.toJson()];
    j.addAll(extra);
    return j;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          other.id == id &&
          other.type == type &&
          other.name == name &&
          other.key == key &&
          jsonEquality.equals(other.children, children) &&
          jsonEquality.equals(other.slots, slots) &&
          other.visible == visible &&
          other.opacity == opacity &&
          other.layout == layout &&
          other.decoration == decoration &&
          other.props == props &&
          jsonEquality.equals(other.bind, bind) &&
          listEquals(other.actions, actions) &&
          other.behaviors == behaviors &&
          other.component == component &&
          listEquals(other.media, media) &&
          jsonEquality.equals(other.extra, extra);

  @override
  int get hashCode => Object.hash(id, type, name, Object.hashAll(children), layout, decoration, props);

  @override
  String toString() => 'Node($type $id${name.isEmpty ? '' : ' "$name"'})';
}
