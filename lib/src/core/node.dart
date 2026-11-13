import 'package:meta/meta.dart';

import 'behaviors.dart';
import 'bindings.dart' show BindPaths;
import 'catalog.dart';
import 'components.dart';
import 'decoration.dart';
import 'json.dart';
import 'layout.dart';
import 'props.dart';
import 'responsive.dart';
import 'breakpoints.dart';
import 'triggers.dart';
import 'values/paint.dart' show listEquals;
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
    this.responsive = const [],
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

  /// Its own fields per breakpoint: patches over this node, each applied
  /// while the screen's breakpoint meets its condition (`equals`,
  /// `largerThan`, `smallerThan`, `between` a named breakpoint), in order.
  final List<ResponsivePatch> responsive;

  /// This node as shown at breakpoint [current] of [breakpoints]: its
  /// [responsive] patches that hold, merged over it in order. Itself when
  /// none holds.
  Node atBreakpoint(Breakpoint current, Breakpoints breakpoints) {
    if (responsive.isEmpty) return this;
    final patch = responsivePatchAt(responsive, current, breakpoints);
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
        responsive: responsive,
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
    List<ResponsivePatch>? responsive,
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
        responsive: responsive ?? this.responsive,
        extra: extra ?? this.extra,
        catalog: catalog,
      );

  static const _keys = {
    'id', 'type', 'name', 'key', 'children', 'slots', 'visible', 'opacity', 'layout', 'decoration', 'props', 'bind', //
    'actions', 'component', 'responsive',
  };

  /// This node with [patch] (a JSON merge patch over its JSON, as an
  /// interaction state's) applied.
  Node patched(Json patch) => Node.fromJson(mergePatch(toJson(), patch), id: id, catalog: catalog) ?? this;

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
      opacity: (readDouble(m['opacity']) ?? 1).clamp(0, 1).toDouble(),
      layout: Layout.fromJson(m['layout']),
      // A type without a box decoration keeps only its blurs (they act on
      // whatever it paints).
      decoration: spec == null || spec.decorated
          ? Decoration.fromJson(m['decoration'])
          : Decoration(effects: [...Decoration.fromJson(m['decoration']).effects.where((e) => !e.isShadow)]),
      props: Props.fromJson(spec, m['props']),
      bind: Behaviors.migrateBind({
        if (bind != null)
          for (final e in bind.entries)
            if (e.value is String) e.key: e.value as String,
      }, m),
      actions: Reaction.listFromJson(m['actions']),
      behaviors: Behaviors.fromJson(m),
      component: ComponentLink.fromJson(m['component']),
      responsive: ResponsivePatch.listFromJson(m['responsive']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key) && !Behaviors.keys.contains(e.key) && !Behaviors.legacyKeys.contains(e.key)) e.key: e.value,
      },
      catalog: catalog,
    );
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
    if (responsive.isNotEmpty) j['responsive'] = [for (final p in responsive) p.toJson()];
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
          listEquals(other.responsive, responsive) &&
          jsonEquality.equals(other.extra, extra);

  @override
  int get hashCode => Object.hash(id, type, name, Object.hashAll(children), layout, decoration, props);

  @override
  String toString() => 'Node($type $id${name.isEmpty ? '' : ' "$name"'})';
}
