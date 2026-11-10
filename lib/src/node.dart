import 'package:meta/meta.dart';

import 'behaviours.dart';
import 'bindings.dart' show BindPaths;
import 'components.dart';
import 'decoration.dart';
import 'json.dart';
import 'layout.dart';
import 'props.dart';
import 'triggers.dart';
import 'values/paint.dart' show listEquals;
import 'widgets/canvas.dart';
import 'widgets/widgets.dart';

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
    this.behaviours = Behaviours.none,
    this.component,
    this.extra = const {},
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
  /// (stored flat in the node's JSON, under [Behaviours.keys]).
  final Behaviours behaviours;

  /// The component this node is the main node of, or the top node of an
  /// instance of (DESIGN.md §4.2).
  final ComponentLink? component;

  /// Keys this version doesn't model, round-tripped.
  final Json extra;

  /// The declaration, or null for a type this version doesn't know.
  WidgetSpec? get spec => Widgets.of(type);

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
        behaviours: behaviours,
        component: link,
        extra: extra,
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
    Behaviours? behaviours,
    ComponentLink? component,
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
        behaviours: behaviours ?? this.behaviours,
        component: component ?? this.component,
        extra: extra ?? this.extra,
      );

  static const _keys = {
    'id', 'type', 'name', 'key', 'children', 'slots', 'visible', 'opacity', 'layout', 'decoration', 'props', 'bind', //
    'actions', 'component',
  };

  /// This node with [patch] (a JSON merge patch over its JSON, as an
  /// interaction state's) applied.
  Node patched(Json patch) => Node.fromJson(mergePatch(toJson(), patch), id: id) ?? this;

  /// Decodes a node; [id] wins over the JSON's own (the document map key).
  /// Returns null only when there's no type.
  static Node? fromJson(Object? json, {String? id}) {
    final m = readMap(json);
    final type = readString(m?['type']);
    if (m == null || type == null || type.isEmpty) return null;
    final spec = Widgets.of(type);
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
      bind: {
        if (bind != null)
          for (final e in bind.entries)
            if (e.value is String) e.key: e.value as String,
      },
      actions: Reaction.listFromJson(m['actions']),
      behaviours: Behaviours.fromJson(m),
      component: ComponentLink.fromJson(m['component']),
      extra: {
        for (final e in m.entries)
          if (!_keys.contains(e.key) && !Behaviours.keys.contains(e.key)) e.key: e.value,
      },
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
    behaviours.writeTo(j);
    if (component != null) j['component'] = component!.toJson();
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
          other.behaviours == behaviours &&
          other.component == component &&
          jsonEquality.equals(other.extra, extra);

  @override
  int get hashCode => Object.hash(id, type, name, Object.hashAll(children), layout, decoration, props);

  @override
  String toString() => 'Node($type $id${name.isEmpty ? '' : ' "$name"'})';
}
