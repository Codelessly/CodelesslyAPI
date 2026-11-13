// Sections and components by reference (docs/design/06-sections-and-components.md).
//
// A component is a document: one non-canvas root, its nodes, and a `widget`
// declaration (the catalog's widget JSON plus `events`). A page (or another
// component) uses it with a call: one node whose `type` is the component's
// type name, whose `props` are the declared parameters, whose `children` /
// `slots` fill the declared slots and whose `event` reactions handle the
// declared events. A section is a component used once. Ids stay local to
// each document: nothing stored names a node in another document.
//
// Flutter: a definition is a widget class, its `widget.props` the
// constructor's parameters, a `slot` node where `build` places `child`,
// `children` or a `Widget title` parameter, `componentEvent` a call of an
// `onChanged`-style callback.
import 'dart:convert';

import 'package:meta/meta.dart';

import 'behaviors.dart';
import 'catalog.dart';
import 'catalog_json.dart';
import 'document.dart';
import 'json.dart';
import 'logic.dart';
import 'node.dart';
import 'props.dart';
import 'theme.dart';
import 'variables.dart';

/// Where a definition places what a call passes: the `children` slot (the
/// call's `children`) or a named one (the call's `slots[name]`). With nothing
/// passed it shows its own children (the default). Outside a definition it
/// shows its children. Flutter: `child` / `children` / a `Widget title`
/// parameter, placed in `build`.
abstract final class SlotProps {
  /// The slot's name: `children` (the call's children) or one of the
  /// component's declared `widget.slots`.
  static const name = PropDef<String>(
    'name',
    Codecs.string,
    kChildrenSlot,
    doc: 'children (the call\'s children) or a declared slot name.',
  );

  static const spec = WidgetSpec(
    'slot',
    props: [name],
    children: ChildModel.list,
    doc:
        'Inside a component: where the call\'s children (or one named slot) go; its own children show when the call passes none.',
  );
}

/// The slot a call's `children` fill.
const String kChildrenSlot = 'children';

/// The keys a component document reads beyond a layout document's.
const Set<String> componentDocumentKeys = {kWidgetKey, kPreviewsKey};

/// The document key of a component's declaration.
const String kWidgetKey = 'widget';

/// The document key of a component's previews.
const String kPreviewsKey = 'previews';

/// Whether [type] is written as a component's type name: UpperCamelCase,
/// like a Dart class (`PlanCard`). Core types are lowerCamelCase (`row`),
/// plugin types `vendor.name`.
bool isComponentTypeName(String type) => _componentName.hasMatch(type);
final RegExp _componentName = RegExp(r'^[A-Z][A-Za-z0-9]*$');

/// A named parameter set a component renders with alone (Flutter's
/// `@Preview(name:, size:)`): `{"name": "Team, annual", "size": [432, 760],
/// "props": {...}}`.
@immutable
final class ComponentPreview {
  const ComponentPreview({this.name = '', this.width, this.height, this.props = const {}});

  final String name;

  /// The size to render at; null: the root's design size.
  final double? width, height;

  /// The parameters, as a call's `props` (literal JSON).
  final Json props;

  static ComponentPreview? fromJson(Object? json) {
    final m = readMap(json);
    if (m == null) return null;
    final size = readList(m['size']);
    return ComponentPreview(
      name: readString(m['name']) ?? '',
      width: size != null && size.length == 2 ? readDouble(size[0]) : null,
      height: size != null && size.length == 2 ? readDouble(size[1]) : null,
      props: readMap(m['props']) ?? const {},
    );
  }

  Json toJson() => {
    if (name.isNotEmpty) 'name': name,
    if (width != null && height != null) 'size': [writeDouble(width!), writeDouble(height!)],
    if (props.isNotEmpty) 'props': props,
  };
}

/// A layout document read as a component definition.
extension ComponentDocument on LayoutDocument {
  /// Its declaration (`widget`), or null when it isn't a component.
  WidgetSpec? get widget =>
      (_widgets[this] ??= (extra[kWidgetKey] == null ? null : widgetSpecFromJson(extra[kWidgetKey]),)).$1;
  static final Expando<(WidgetSpec?,)> _widgets = Expando();

  /// Whether it is a component definition: a `widget` declaration with a
  /// type, and exactly one root.
  bool get isComponent => widget != null && roots.length == 1;

  /// The component's type name (its `widget.type`); null when it isn't one.
  String? get componentType => isComponent ? widget!.type : null;

  /// The definition's root node id.
  String? get componentRoot => isComponent ? roots.first : null;

  /// Its previews (`previews`).
  List<ComponentPreview> get previews => [...?readList(extra[kPreviewsKey])?.map(ComponentPreview.fromJson).nonNulls];

  /// Its own variables: one set per instance (keyed by its root, as a
  /// canvas's are).
  List<Variable> get componentVariables => componentRoot == null ? const [] : logic.variablesOf(componentRoot!);

  /// The call nodes in it: nodes whose type is one of [types] (component
  /// type names).
  Iterable<Node> callsTo(Set<String> types) => nodes.values.where((n) => types.contains(n.type));
}

/// Component definitions by type name: the project's (or a document's)
/// library, and the catalog a page's calls decode with.
@immutable
final class ComponentLibrary {
  ComponentLibrary(Map<String, LayoutDocument> definitions) : definitions = Map.unmodifiable(definitions);

  static final ComponentLibrary empty = ComponentLibrary(const {});

  /// Every definition, by its type name.
  final Map<String, LayoutDocument> definitions;

  /// The definitions of [documents] (those that are components, by their
  /// `widget.type`; a later one of the same type wins).
  factory ComponentLibrary.of(Iterable<LayoutDocument> documents) => ComponentLibrary({
    for (final d in documents)
      if (d.componentType case final String t) t: d,
  });

  LayoutDocument? operator [](String type) => definitions[type];
  bool get isEmpty => definitions.isEmpty;

  /// Their declarations as a catalog: what a page is decoded with (over the
  /// host's) so its calls' props are typed.
  late final Catalog catalog = Catalog(id: 'components', widgets: [for (final d in definitions.values) d.widget!]);

  /// The component types each definition calls, directly.
  late final Map<String, Set<String>> calls = {
    for (final e in definitions.entries)
      e.key: {
        for (final n in e.value.nodes.values)
          if (definitions.containsKey(n.type)) n.type,
      },
  };

  /// Every cycle of definitions calling each other (directly or through
  /// others), each as the path of types from where it starts back to it
  /// (`[A, B, A]`), once per cycle.
  late final List<List<String>> cycles = componentCycles(calls);

  /// The definitions [document] needs: the types it calls and every type
  /// they call, transitively (its closure), in a stable order.
  List<String> closureOf(LayoutDocument document) {
    final out = <String>[];
    final seen = <String>{};
    void visit(String t) {
      if (!seen.add(t)) return;
      out.add(t);
      for (final c in calls[t] ?? const <String>{}) {
        visit(c);
      }
    }

    for (final n in document.nodes.values) {
      if (definitions.containsKey(n.type)) visit(n.type);
    }
    return out;
  }
}

/// Every cycle in the call graph [calls] (type → the types it calls), each
/// as the path from its first type back to it (`[A, B, A]`), reported once
/// (from the type that sorts first in it).
List<List<String>> componentCycles(Map<String, Set<String>> calls) {
  final out = <List<String>>[];
  final seen = <String>{};
  final onPath = <String>[];
  final state = <String, int>{}; // 1: on the path, 2: done
  void visit(String t) {
    state[t] = 1;
    onPath.add(t);
    for (final c in (calls[t] ?? const <String>{}).toList()..sort()) {
      if (state[c] == 1) {
        final cycle = [...onPath.sublist(onPath.indexOf(c)), c];
        // One report per cycle, rotated to start at its smallest type.
        final ring = cycle.sublist(0, cycle.length - 1);
        var start = 0;
        for (var i = 1; i < ring.length; i++) {
          if (ring[i].compareTo(ring[start]) < 0) start = i;
        }
        final rotated = [...ring.sublist(start), ...ring.sublist(0, start), ring[start]];
        if (seen.add(rotated.join('/'))) out.add(rotated);
      } else if (state[c] == null) {
        visit(c);
      }
    }
    onPath.removeLast();
    state[t] = 2;
  }

  for (final t in calls.keys.toList()..sort()) {
    if (state[t] == null) visit(t);
  }
  return out;
}

/// The layout fields a call gives the instance's root: its size and
/// placement. The root keeps its own `padding` (the inside is the
/// definition's).
const Set<String> callLayoutKeys = {
  'width', 'height', 'flex', 'squeezable', 'constraints', 'margin', 'x', 'y', 'align', 'rotation', 'aspectRatio', //
  'widthFactor', 'heightFactor', 'order', 'basis',
};

/// The node fields a call may not carry: the inside belongs to the
/// definition (`call_field_not_allowed`).
const Set<String> callForbiddenKeys = {'decoration'};

/// The instance's root as shown at its call ([root] and [call] each as
/// shown in their own scope): one box with the call's size and placement
/// (its layout but for padding), `visible` the AND of both, `opacity` their
/// product, the call's pointer reactions after the root's and the call's
/// behaviors over the root's, key by key.
Node seamCall(Node root, Node call) {
  final layout = call.layout.copyWith(padding: root.layout.padding);
  final reactions = [...root.actions, ...call.actions.where((r) => r.trigger.type.name != 'event')];
  var out = root.copyWith(
    layout: layout,
    visible: root.visible && call.visible,
    opacity: root.opacity * call.opacity,
    actions: reactions.length == root.actions.length ? root.actions : reactions,
  );
  if (call.behaviors != Behaviors.none) {
    final j = <String, Object?>{};
    root.behaviors.writeTo(j);
    call.behaviors.writeTo(j);
    out = out.copyWith(behaviors: Behaviors.fromJson(j));
  }
  return out;
}

/// A site's manifest (`site.json`), loader-agnostic: which documents are its
/// pages and components (as references the loader resolves: file paths
/// relative to the manifest, publish ids...), its project variables (read by
/// bare name in every document), breakpoints and any keys it doesn't model.
///
/// ```json
/// {"schema": 2, "pages": ["pages/pricing.json"], "components": ["components/PlanCard.json"],
///  "variables": [{"name": "plans", "type": "list", "value": [...]}],
///  "breakpoints": [{"id": "mobile", "minWidth": 0}, {"id": "desktop", "minWidth": 1024}]}
/// ```
///
/// Flutter: an app's `lib/`: the `pubspec`, `main.dart`'s routes and
/// globals. Without `components`, a loader takes every component document
/// it finds beside the pages (a directory's `components/`).
@immutable
final class SiteManifest {
  const SiteManifest({
    this.pages = const [],
    this.components = const [],
    this.variables = const [],
    this.breakpoints,
    this.theme = ThemeTokens.none,
    this.extra = const {},
  });

  /// The file name a directory's manifest has.
  static const String fileName = 'site.json';

  /// References to its pages, in order.
  final List<String> pages;

  /// References to its component documents (empty: the loader's default).
  final List<String> components;

  /// Project variables: every page and component reads them by name.
  final List<Variable> variables;

  /// The project's breakpoints, as JSON (`Breakpoints.fromJson`); null: the
  /// defaults.
  final Object? breakpoints;

  /// The project's theme: its named colors and text styles (the type scale
  /// and palette every page and component names: `"color": "ember"`,
  /// `"style": "title"`), its roles (`primary`, `surface`...) and the media
  /// rules that change them by screen size. Published as the project's
  /// theme.
  final ThemeTokens theme;

  /// Keys it doesn't model (fonts...), kept.
  final Json extra;

  static const Set<String> keys = {'schema', 'pages', 'components', 'variables', 'breakpoints', 'theme'};

  static SiteManifest fromJson(Object? json) {
    final m = readMap(json) ?? const {};
    return SiteManifest(
      pages: readStrings(m['pages']),
      components: readStrings(m['components']),
      variables: Variable.listFromJson(m['variables']),
      breakpoints: m['breakpoints'],
      theme: ThemeTokens.fromJson(m['theme']),
      extra: {
        for (final e in m.entries)
          if (!keys.contains(e.key)) e.key: e.value,
      },
    );
  }

  Json toJson() => {
    'schema': kSchemaVersion,
    if (pages.isNotEmpty) 'pages': pages,
    if (components.isNotEmpty) 'components': components,
    if (variables.isNotEmpty) 'variables': [for (final v in variables) v.toJson()],
    'breakpoints': ?breakpoints,
    if (!theme.isEmpty) 'theme': theme.toJson(),
    ...extra,
  };
}

/// A site in memory: its manifest, pages and component library, whatever
/// loaded them (files, a publish, an editor's store).
@immutable
final class Site {
  Site({
    this.manifest = const SiteManifest(),
    Map<String, LayoutDocument> pages = const {},
    ComponentLibrary? components,
  }) : pages = Map.unmodifiable(pages),
       components = components ?? ComponentLibrary.empty;

  final SiteManifest manifest;

  /// Pages by their reference (or id).
  final Map<String, LayoutDocument> pages;
  final ComponentLibrary components;

  /// [base] with the components' declarations over it: what the site's
  /// documents decode with.
  Catalog catalogOver(Catalog base) => components.isEmpty ? base : base + components.catalog;
}

/// [value] (JSON) as text with every object's keys sorted, no whitespace,
/// and a whole double written as an integer (`1.0` → `1`): one text for one
/// value, whatever order a store kept its keys in. What a published
/// component's digest is over, and how validation compares subtrees.
String canonicalJson(Object? value) {
  final out = StringBuffer();
  void write(Object? v) {
    switch (v) {
      case Map():
        final keys = [for (final k in v.keys) '$k']..sort();
        out.write('{');
        for (var i = 0; i < keys.length; i++) {
          if (i > 0) out.write(',');
          out.write(jsonEncode(keys[i]));
          out.write(':');
          write(v[keys[i]]);
        }
        out.write('}');
      case List():
        out.write('[');
        for (var i = 0; i < v.length; i++) {
          if (i > 0) out.write(',');
          write(v[i]);
        }
        out.write(']');
      case double() when v.isFinite && v == v.truncateToDouble() && v.abs() < 9007199254740992:
        out.write(v.toInt());
      default:
        out.write(jsonEncode(v));
    }
  }

  write(value);
  return out.toString();
}
